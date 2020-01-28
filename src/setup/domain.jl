function init_peano(tree::PhysicalOctree)
    uLength = tree.config.units[1]
    tree.DomainFac = ustrip(Float64, uLength^-1, 1.0 / tree.extent.SideLength) * (1 << tree.config.PeanoBits3D)
    tree.peano_keys = peanokey(tree.data, tree.extent.Corner, tree.DomainFac, uLength, tree.config.PeanoBits3D)
    tree.NumLocal = datalength(tree.data)

    sortpeano(tree)
end

function init_topnode(tree::PhysicalOctree)
    tree.topnodes = [TopNode(bits = tree.config.PeanoBits3D) for i=1:tree.config.ToptreeAllocSection]
    tree.NTopnodes = 1
    tree.topnodes[1].Count = tree.NumLocal
end

function reinit_topnode(tree::PhysicalOctree)
    tree.topnodes = [TopNode(bits = tree.config.PeanoBits3D) for i=1:tree.config.ToptreeAllocSection]
    tree.topnodes[1].Count = tree.NumTotal
    tree.topnodes[1].Blocks = tree.NTopnodes

    tree.NTopnodes = 1
end

function split_local_topnode_kernel(tree::PhysicalOctree, node::Int64, startkey::Int128)
    topnodes = tree.topnodes
    if topnodes[node].Size >= 8
        topnodes[node].Daughter = tree.NTopnodes + 1
        for i in 0:7
            if tree.NTopnodes >= length(topnodes) - 8
                if length(topnodes) <= tree.config.MaxTopnode
                    append!(topnodes, [TopNode(bits = tree.config.PeanoBits3D) for i=1:tree.config.ToptreeAllocSection])
                else
                    error("Running out of topnodes, please increase the MaxTopNodes in Config")
                end
            end

            sub = topnodes[node].Daughter + i
            topnodes[sub].Size = topnodes[node].Size / 8
            topnodes[sub].Count = 0
            topnodes[sub].Daughter = -1
            topnodes[sub].StartKey = startkey + i * topnodes[sub].Size
            topnodes[sub].Pstart = topnodes[node].Pstart

            tree.NTopnodes += 1
        end

        for p in topnodes[node].Pstart : topnodes[node].Pstart + topnodes[node].Count - 1
            bin = floor(Int64, (tree.peano_keys[p] - startkey) / (topnodes[node].Size / 8))
            if bin < 0 || bin > 7
                error("something odd has happened here. bin = ", bin)
            end

            sub = topnodes[node].Daughter + bin
            if topnodes[sub].Count == 0
                topnodes[sub].Pstart = p
            end
            topnodes[sub].Count += 1
        end

        for i in 0:7
            sub = topnodes[node].Daughter + i
            if topnodes[sub].Count > tree.NumTotal / (tree.config.TopnodeFactor * length(tree.pids)^2)
                split_local_topnode_kernel(tree, sub, topnodes[sub].StartKey)
            end
        end
    end # if topnodes[node].size >
end

function count_leaves(tree::PhysicalOctree)
    topnodes = tree.topnodes
    StartKeys = tree.StartKeys
    Counts = tree.Counts
    for i in 1:tree.NTopnodes
        if topnodes[i].Daughter == -1
            tree.NTopLeaves += 1
            push!(StartKeys, topnodes[i].StartKey)
            push!(Counts, topnodes[i].Count)
        end
    end
end

function split_local_topnode(tree::PhysicalOctree)
    split_local_topnode_kernel(tree, 1, Int128(0))

    count_leaves(tree)
end

function split_topnode_kernel(tree::PhysicalOctree)
    
end

function split_topnode(tree::PhysicalOctree)
    
end

function split_domain(tree::PhysicalOctree)
    bcast(tree, init_peano)
    bcast(tree, init_topnode)

    bcast(tree, split_local_topnode)
    allsum(tree, :NTopLeaves)

    bcast(tree, split_topnode)
end