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
                        
                        error("Running out of tree nodes in creating empty nodes, please increase TreeAllocFactor")
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

function insert_data(tree::PhysicalOctree)
    
end

function insert_data_pseudo(tree::PhysicalOctree)
    
end

function build(tree::PhysicalOctree)
    bcast(tree, init_treenodes)
    bcast(tree, insert_data)
    bcast(tree, insert_data_pseudo)
end