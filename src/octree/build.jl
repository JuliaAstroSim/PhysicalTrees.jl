function create_empty_treenodes(tree::PhysicalOctree, no::Int64, top::Int64, bits::Int64, x::Int64, y::Int64, z::Int64)
    topnodes = tree.topnodes
    treenodes = tree.treenodes
    MaxData = tree.config.MaxData
    if topnodes[top].Daughter >= 0
        for i = 0:1
            for j = 0:1
                for k = 0:1
                    sub = Int64(7 & peanokey((x << 1) + i, (y << 1) + j, (z << 1) + k, bits = bits))
                    count = 1 + i + 2 * j + 4 * k

                    treenodes[no].DaughterID[count] = tree.nextfreenode + MaxData
                    treenodes[tree.nextfreenode].SideLength = 0.5 * treenodes[no].SideLength

                    treenodes[tree.nextfreenode].Center = treenodes[no].Center + PVector((2 * i - 1) * 0.25 * treenodes[no].SideLength,
                                                                                                    (2 * j - 1) * 0.25 * treenodes[no].SideLength,
                                                                                                    (2 * k - 1) * 0.25 * treenodes[no].SideLength)

                    if topnodes[topnodes[top].Daughter + sub].Daughter == -1
                        # this table gives for each leaf of the top-level tree the corresponding node of the gravitational tree
                        tree.DomainNodeIndex[topnodes[topnodes[top].Daughter + sub].Leaf] = tree.nextfreenode + MaxData
                    end

                    tree.NTreenodes += 1
                    tree.nextfreenode += 1

                    if tree.nextfreenode >= length(treenodes) - 8
                        if length(treenodes) <= tree.config.MaxTreenode
                            append!(treenodes, [PhysicalOctreeNode() for i in 1:tree.config.TreeAllocSection])
                        else
                            error("Running out of tree nodes in creating empty nodes, please increase MaxTreenode in Config")
                        end
                    end

                    create_empty_treenodes(tree,
                                            tree.nextfreenode - 1, tree.topnodes[top].Daughter + sub,
                                            bits + 1, 2 * x + i, 2 * y + j, 2 * z + k)
                end
            end
        end
    end
end

function init_treenodes(tree::PhysicalOctree)
    tree.DomainNodeIndex = zeros(Int64, tree.NTopLeaves)

    tree.treenodes = [PhysicalOctreeNode() for i in 1:tree.config.TreeAllocSection]
    tree.treenodes[1].Center = tree.extent.Center
    tree.treenodes[1].SideLength = tree.extent.SideLength

    tree.NTreenodes = 1
    tree.nextfreenode = 2

    create_empty_treenodes(tree, 1, 1, 1, 0, 0, 0)
end

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

find_subnode(p::AbstractParticle, Center::AbstractPoint) = find_subnode(p, Center)

function check_inbox(Pos::PVector, Center::PVector, SideLength::Quantity)
    half_len = SideLength * 0.5
    if Pos.x < Center.x - half_len || Pos.x > Center.x + half_len ||
        Pos.y < Center.y - half_len || Pos.y > Center.y + half_len ||
        Pos.z < Center.z - half_len || Pos.z > Center.z + half_len
        return false
    end
    return true
end

function insert_data(tree::PhysicalOctree)
    DomainCorner = tree.extent.Corner
    data = tree.data
    topnodes = tree.topnodes
    treenodes = tree.treenodes
    MaxData = tree.config.MaxData
    epsilon = tree.config.epsilon
    for i in 1:length(data)
        key = peanokey(data[i], DomainCorner, tree.DomainFac, u"kpc")

        no = 1
        while topnodes[no].Daughter >= 0
            @inbounds no = trunc(Int64, topnodes[no].Daughter + (key - topnodes[no].StartKey) / (topnodes[no].Size / 8))
        end
        no = topnodes[no].Leaf
        index = tree.DomainNodeIndex[no]
        if index == 0
            error("index == 0 for ", data[i])
        end
        # println(index, " ", distance(treenodes[index - MaxData].Center, data[i].Pos), " ", treenodes[index - MaxData].SideLength, " ",
        #                     check_inbox(data[i].Pos, treenodes[index - MaxData].Center, treenodes[index - MaxData].SideLength))

        subnode = 0
        parent = -1
        while true
            if index > MaxData
                # Internal node
                subnode = find_subnode(data[i], treenodes[index - MaxData].Center)
                nn = treenodes[index - MaxData].DaughterID[subnode]

                if nn > 0
                    parent = index
                    index = nn
                else
                    # here we have found an empty slot where we can attach the new particle as a leaf
                    treenodes[index - MaxData].DaughterID[subnode] = i
                    break
                end
                # in the next loop, the particle will be settled
            else
                # We try to insert into a leaf with a single particle
                # Need to generate a new internal node at this point
                treenodes[parent - MaxData].DaughterID[subnode] = tree.nextfree + MaxData

                treenodes[tree.nextfree].SideLength = 0.5 * treenodes[parent - MaxData].SideLength
                lenhalf = 0.25 * treenodes[parent - MaxData].SideLength

                if (subnode - 1) & 1 > 0
                    centerX = treenodes[parent - MaxData].Center.x + lenhalf
                else
                    centerX = treenodes[parent - MaxData].Center.x - lenhalf
                end

                if (subnode - 1) & 2 > 0
                    centerY = treenodes[parent - MaxData].Center.y + lenhalf
                else
                    centerY = treenodes[parent - MaxData].Center.y - lenhalf
                end

                if (subnode - 1) & 4 > 0
                    centerZ = treenodes[parent - MaxData].Center.z + lenhalf
                else
                    centerZ = treenodes[parent - MaxData].Center.z - lenhalf
                end

                subnode = find_subnode(data[index], treenodes[tree.nextfree].Center)

                if treenodes[tree.nextfree].SideLength < 1.0e-3 * epsilon
                    subnode = trunc(Int64, 8.0 * rand()) + 1
                    data[i].GravCost += 1
                    if subnode >= 9
                        subnode = 8
                    end
                end

                treenodes[tree.nextfree].DaughterID[subnode] = index

                # Resume trying to insert the new particle at the newly created internal node
                index = tree.nextfree + MaxData

                tree.NodeCount += 1
                tree.nextfree += 1

                if tree.nextfreenode >= length(treenodes) - 8
                    if length(treenodes) <= tree.config.MaxTreenode
                        append!(treenodes, [PhysicalOctreeNode() for i in 1:tree.config.TreeAllocSection])
                    else
                        error("Running out of tree nodes in creating empty nodes, please increase MaxTreenode in Config")
                    end
                end
            end
        end
    end
end

function insert_data_pseudo(tree::PhysicalOctree)
    tree.DomainMoment = [DomainNode() for i in 1:tree.NTopLeaves]

    MaxData = tree.config.MaxData
    MaxTreenode = tree.config.MaxTreenode
    treenodes = tree.treenodes
    for i in 1:tree.NTopLeaves
        @inbounds tree.DomainMoment[i].Mass = 0.0u"Msun"
        @inbounds tree.DomainMoment[i].MassCenter = treenodes[tree.DomainNodeIndex[i] - MaxData].Center
    end

    for i in 1:tree.NTopLeaves
        if i < tree.DomainMyStart || i > tree.DomainMyEnd
            index = MaxData + 1

            while true
                if index > MaxData
                    if index > MaxData + MaxTreenode
                        @show index
                        error("Error in DomainMoment indexing #01")
                    end

                    subnode = find_subnode(tree.DomainMoment[i].MassCenter, treenodes[index - MaxData].Center)
                    nn = treenodes[index - MaxData].DaughterID[subnode]

                    if nn > 0
                        index = nn
                    else
                        # here we have found an empty slot where we can attach the pseudo particle as a leaf
                        treenodes[index - MaxData].DaughterID[subnode] = MaxData + MaxTreenode + i
                        break
                    end
                else
                    @show index
                    error("Error in DomainMoment indexing #02, index = ", index, ", MaxData = ", MaxData)
                end
            end
        end
    end
end

function build(tree::PhysicalOctree)
    bcast(tree, init_treenodes)
    bcast(tree, insert_data)
    bcast(tree, insert_data_pseudo)
end