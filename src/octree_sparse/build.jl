"""
    allocate_tree_if_necessary(tree::Octree)

If `nextfreenode` getting close to the length of `treenodes`, append `treenodes` with `TreeAllocSection` empty nodes
"""
function allocate_tree_if_necessary(tree::Octree)
    if tree.nextfreenode >= length(tree.treenodes) - 8
        if length(tree.treenodes) <= tree.config.MaxTreenode
            append!(tree.treenodes, [OctreeNode(tree.units) for i in 1:tree.config.TreeAllocSection])
        else
            error("Running out of tree nodes in creating empty nodes, please increase MaxTreenode in Config")
        end
    end
end

"""
    create_empty_treenodes(tree::Octree, no::Int64, top::Int64, bits::Int64, x::Int64, y::Int64, z::Int64)

Create an octree with empty nodes in the same structure with toptree
"""
function create_empty_treenodes(tree::Octree, no::Int64, top::Int64, bits::Int64, x::Int64, y::Int64, z::Int64)
    topnodes = tree.domain.topnodes
    treenodes = tree.treenodes

    allocate_tree_if_necessary(tree)

    if topnodes[top].Daughter >= 0
        for i = 0:1
            for j = 0:1
                for k = 0:1
                    sub = Int64(7 & peanokey((x << 1) + i, (y << 1) + j, (z << 1) + k, bits = bits))
                    count = 1 + i + 2 * j + 4 * k

                    treenodes[no].DaughterID[count] = tree.nextfreenode
                    treenodes[tree.nextfreenode] = setproperties!!(treenodes[tree.nextfreenode], SideLength = 0.5 * treenodes[no].SideLength,
                                                       Center = treenodes[no].Center + PVector((2 * i - 1) * 0.25 * treenodes[no].SideLength,
                                                                                               (2 * j - 1) * 0.25 * treenodes[no].SideLength,
                                                                                               (2 * k - 1) * 0.25 * treenodes[no].SideLength),
                                                                                               ID = tree.nextfreenode,
                                                                                               Father = no)

                    if topnodes[topnodes[top].Daughter + sub].Daughter == -1
                        # this table gives for each leaf of the top-level tree the corresponding node of the gravitational tree
                        tree.domain.DomainNodeIndex[topnodes[topnodes[top].Daughter + sub].Leaf] = tree.nextfreenode
                    end

                    tree.NTreenodes += 1
                    tree.nextfreenode += 1

                    create_empty_treenodes(tree,
                                            tree.nextfreenode - 1, tree.domain.topnodes[top].Daughter + sub,
                                            bits + 1, 2 * x + i, 2 * y + j, 2 * z + k)
                end
            end
        end
    end
end

function init_treenodes(tree::Octree)
    tree.domain.DomainNodeIndex = zeros(Int64, tree.domain.NTopLeaves)

    tree.treenodes = [OctreeNode(tree.units) for i in 1:tree.config.TreeAllocSection]
    tree.treenodes[1] = setproperties!!(tree.treenodes[1], Center = tree.extent.Center,
                                                           SideLength = tree.extent.SideLength)

    tree.NTreenodes = 1
    tree.nextfreenode = 2

    create_empty_treenodes(tree, 1, 1, 1, 0, 0, 0)
end

"""
    find_subnode(Pos::PVector, Center::PVector)
    find_subnode(p::AbstractParticle, Center::AbstractPoint)

From the `Center` cut the domain into eight regions, and index from 1 to 8.
Return the domain index that `Pos` of `p.Pos` lies in.

# Domain indexing

| X-axis | Y-axis | Z-axis | Indexing |
| ------ | ------ | ------ | -------- |
| - | - | - | 1 |
| + | - | - | 2 |
| - | + | - | 3 |
| + | + | - | 4 |
| - | - | + | 5 |
| + | - | + | 6 |
| - | + | + | 7 |
| + | + | + | 8 |
"""
function find_subnode(Pos::PVector, Center::PVector)
    subnode = 1
    if Pos.x > Center.x
        subnode += 1
    end
    if Pos.y > Center.y
        subnode += 2
    end
    if Pos.z > Center.z
        subnode += 4
    end
    return subnode
end

find_subnode(p::AbstractParticle, Center::AbstractPoint) = find_subnode(p.Pos, Center)

"""
    check_inbox(Pos::PVector, Center::PVector, SideLength::Number)

Chech whether `Pos` is inside the box, which is centered at `Center` with sidelength `SideLength`
"""
function check_inbox(Pos::PVector, Center::PVector, SideLength::Number)
    half_len = SideLength * 0.5
    if Pos.x < Center.x - half_len || Pos.x > Center.x + half_len ||
        Pos.y < Center.y - half_len || Pos.y > Center.y + half_len ||
        Pos.z < Center.z - half_len || Pos.z > Center.z + half_len
        return false
    end
    return true
end

function isclosepoints(len::Quantity, u::Units, threshold::Float64)
    if ustrip(u, len) < threshold
        return true
    else
        return false
    end
end

function isclosepoints(len::Float64, ::Nothing, threshold::Float64)
    if len < threshold
        return true
    else
        return false
    end
end

function subnodeCenter(tree::Octree, parent::Int, subnode::Int)
    treenodes = tree.treenodes
    lenhalf = 0.25 * treenodes[parent].SideLength

    if (subnode - 1) & 1 > 0
        centerX = treenodes[parent].Center.x + lenhalf
    else
        centerX = treenodes[parent].Center.x - lenhalf
    end

    if (subnode - 1) & 2 > 0
        centerY = treenodes[parent].Center.y + lenhalf
    else
        centerY = treenodes[parent].Center.y - lenhalf
    end

    if (subnode - 1) & 4 > 0
        centerZ = treenodes[parent].Center.z + lenhalf
    else
        centerZ = treenodes[parent].Center.z - lenhalf
    end

    return PVector(centerX, centerY, centerZ)
end

"""
    assign_new_tree_leaf(tree::Octree, parent::Int)

When trying to insert into a leaf witch already has been assigned with a particle,
first generate a new internal node at this point and copy the old data to a new subnode,
then continue to insert the new data in the next routine.
"""
function assign_new_tree_leaf(tree::Octree, parent::Int)
    treenodes = tree.treenodes
    epsilon = tree.config.epsilon
    uLength = getuLength(tree.units)

    MassOld = treenodes[parent].Mass
    MassCenterOld = treenodes[parent].MassCenter
    
    subnode = find_subnode(MassCenterOld, treenodes[parent].Center)
    SubnodeCenter = subnodeCenter(tree, parent, subnode)

    treenodes[parent].DaughterID[subnode] = tree.nextfreenode # No conflict

    treenodes[parent] = setproperties!!(treenodes[parent], IsAssigned = false,
                                                           Mass = MassOld * 0.0,
                                                           MassCenter = MassCenterOld * 0.0)
    # Move old particle data to the new node
    allocate_tree_if_necessary(tree)
    treenodes[tree.nextfreenode] = setproperties!!(treenodes[tree.nextfreenode], IsAssigned = true, ParticleID = treenodes[parent].ParticleID,
                                                                                 Center = SubnodeCenter,
                                                                                 Mass = MassOld,
                                                                                 MassCenter = MassCenterOld,
                                                                                 Father = parent,
                                                                                 ID = tree.nextfreenode,
                                                                                 SideLength = 0.5 * treenodes[parent].SideLength
                                                                                 )

    #@show "MOVE", subnode, parent, treenodes[parent]

    # Resume trying to insert the new particle at the newly created internal node

    tree.NTreenodes += 1
    tree.nextfreenode += 1

    allocate_tree_if_necessary(tree)

    #return tree.nextfreenode
end

"""
    assign_data_to_tree_leaf(tree::Octree, index::Int, p::AbstractParticle)
    assign_data_to_tree_leaf(tree::Octree, index::Int, p::AbstractPoint)

When inserting to an empty node, simply copy data and change `IsAssigned` to `true`
"""
function assign_data_to_tree_leaf(tree::Octree, index::Int, p::AbstractParticle)
    #@show "assign", index, tree.nextfreenode, p
    tree.treenodes[index] = setproperties!!(tree.treenodes[index], Mass = p.Mass,
                                                                   MassCenter = p.Pos,
                                                                   IsAssigned = true,
                                                                   ParticleID = p.ID,
                                                                   #ID = index,
                                                                   #Father = parent
                                                                   )
end

function assign_data_to_tree_leaf(tree::Octree, index::Int, p::AbstractPoint)
    tree.treenodes[index] = setproperties!!(tree.treenodes[index],
                                            MassCenter = p, 
                                            IsAssigned = true,
                                            ID = index,
                                            Father = parent)
end

"""
    insert_data(tree::Octree)

Insert all data to the octree one by one.
"""
function insert_data(tree::Octree)
    DomainCorner = tree.extent.Corner
    data = tree.data
    topnodes = tree.domain.topnodes
    treenodes = tree.treenodes
    epsilon = tree.config.epsilon
    uLength = getuLength(tree.units)
    for p in Iterators.flatten(values(data))
        key = peanokey(p, DomainCorner, tree.domain.DomainFac)

        no = 1
        while topnodes[no].Daughter >= 0
            @inbounds no = trunc(Int64, topnodes[no].Daughter + div((key - topnodes[no].StartKey) , div(topnodes[no].Size , 8)))
        end
        no = topnodes[no].Leaf
        index = tree.domain.DomainNodeIndex[no]

        subnode = 0
        parent = -1
        while true
            #! Assigned nodes do not have internal daughter leaves
            if !treenodes[index].IsAssigned
                # Internal node
                subnode = find_subnode(p, treenodes[index].Center)
                if isclosepoints(treenodes[index].SideLength / 2.0, uLength, 1.0e-3 * epsilon)
                    subnode = trunc(Int64, 8.0 * rand()) + 1
                    println("Close particle filling into a random node: ", p.ID)
                    #@show "CLOSE", treenodes[index].SideLength, subnode
                    #p.GravCost += 1
                    if subnode >= 9
                        subnode = 8
                    end
                end

                nn = treenodes[index].DaughterID[subnode]

                if nn > 0 # Daughter node is already occupied
                    parent = index
                    index = nn
                elseif sum(treenodes[index].DaughterID) > 0
                    # The target Daughter is not assigned, but this is a branch node
                    # So, attach a new node
                    treenodes[index].DaughterID[subnode] = tree.nextfreenode
                    allocate_tree_if_necessary(tree)
                    assign_data_to_tree_leaf(tree, tree.nextfreenode, p)

                    SubnodeCenter = subnodeCenter(tree, index, subnode)
                    treenodes[tree.nextfreenode] = setproperties!!(treenodes[tree.nextfreenode], Center = SubnodeCenter,
                                                                    SideLength = 0.5 * treenodes[index].SideLength,
                                                                    Father = index,
                                                                    ID = tree.nextfreenode)
                    #@show "BRANCH", treenodes[tree.nextfreenode]
                    tree.NTreenodes += 1
                    tree.nextfreenode += 1
                    break
                else
                    # version 1 - here we have found an empty slot where we can attach the new particle as a leaf
                    # version 2 - we copy information of the particle to this leaf node
                    assign_data_to_tree_leaf(tree, index, p)
                    break
                end
                # in the next loop, the particle will be settled
            else
                # We try to insert into a leaf witch already has been assigned with a particle
                # Need to generate a new internal node at this point
                # Copy the old data to a new subnode
                assign_new_tree_leaf(tree, index)

                # continue to insert the new data
                subnode = find_subnode(p, treenodes[tree.nextfreenode].Center)
            end
        end
    end
end

"""
    insert_data_pseudo(tree::Octree)

Insert remote toptree leaves.
"""
function insert_data_pseudo(tree::Octree)
    tree.domain.DomainMoment = [DomainNode(tree.units) for i in 1:tree.domain.NTopLeaves]

    MaxTreenode = tree.config.MaxTreenode
    treenodes = tree.treenodes
    for i in 1:tree.domain.NTopLeaves
        @inbounds tree.domain.DomainMoment[i] = setproperties!!(tree.domain.DomainMoment[i], Mass = 0.0 * tree.domain.DomainMoment[i].Mass,
                                                                    MassCenter = treenodes[tree.domain.DomainNodeIndex[i]].Center)
    end

    for i in 1:tree.domain.NTopLeaves
        if i < tree.domain.DomainMyStart || i > tree.domain.DomainMyEnd
            index = 1

            while true
                if index > 0
                    if index > MaxTreenode
                        @show index
                        error("Error in DomainMoment indexing #01")
                    end

                    subnode = find_subnode(tree.domain.DomainMoment[i].MassCenter, treenodes[index].Center)
                    nn = treenodes[index].DaughterID[subnode]

                    if nn > 0
                        index = nn
                    else
                        # here we have found an empty slot where we can attach the pseudo particle as a leaf
                        #! Assigned nodes could have pseudo leaves
                        treenodes[index].DaughterID[subnode] = MaxTreenode + i
                        break
                    end
                else
                    @show index
                    error("Error in DomainMoment indexing #02, index = ", index)
                end
            end
        end
    end
end

"""
    build(tree::Octree)

Procedures to build an octree:
1. Allocate tree node memories and initialize
2. Insert local data
3. Insert remote toptree leaves
"""
function build(tree::Octree)
    bcast(tree, init_treenodes)
    bcast(tree, insert_data)
    bcast(tree, insert_data_pseudo)
end