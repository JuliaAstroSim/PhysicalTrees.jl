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

function split_topnode_local_kernel(tree::PhysicalOctree, node::Int64, startkey::Int128)
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
                split_topnode_local_kernel(tree, sub, topnodes[sub].StartKey)
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

function split_topnode_local(tree::PhysicalOctree)
    split_topnode_local_kernel(tree, 1, Int128(0))

    count_leaves(tree)
end

function key_sort_bcast(tree::PhysicalOctree)
    key_counts = sortslices([tree.StartKeys tree.Counts], dims=1)
    tree.StartKeys = key_counts[:, 1]
    tree.Counts = key_counts[:, 2]

    bcast(tree, :StartKeys, tree.StartKeys)
    bcast(tree, :Counts, tree.Counts)
end

function reinit_topnode(tree::PhysicalOctree)
    tree.NTopLeaves = 0

    tree.topnodes = [TopNode(bits = tree.config.PeanoBits3D) for i=1:tree.config.ToptreeAllocSection]
    tree.topnodes[1].Count = tree.NumTotal
    tree.topnodes[1].Blocks = tree.NTopLeaves

    tree.NTopnodes = 1
end

function split_topnode_kernel(tree::PhysicalOctree, node::Int64, startkey::Int128)
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
            topnodes[sub].Blocks = 0
            topnodes[sub].Daughter = -1
            topnodes[sub].StartKey = startkey + i * topnodes[sub].Size
            topnodes[sub].Pstart = topnodes[node].Pstart

            tree.NTopnodes += 1
        end

        for p in topnodes[node].Pstart : topnodes[node].Pstart + topnodes[node].Blocks - 1
            if p == 849
                @show topnodes[node].Pstart + topnodes[node].Blocks - 1
            end
            bin = floor(Int64, (tree.StartKeys[p] - startkey) / (topnodes[node].Size / 8))
            if bin < 0 || bin > 7
                @show (tree.StartKeys[p] - startkey) / (topnodes[node].Size / 8)
                @show p
                @show topnodes[node]
                error("something odd has happened here. bin = ", bin)
            end

            sub = topnodes[node].Daughter + bin
            if topnodes[sub].Blocks == 0
                topnodes[sub].Pstart = p
            end
            topnodes[sub].Count += tree.Counts[p]
            topnodes[sub].Blocks += 1
        end

        for i in 0:7
            sub = topnodes[node].Daughter + i
            if topnodes[sub].Count > tree.NumTotal / (tree.config.TopnodeFactor * length(tree.pids))
                split_topnode_kernel(tree, sub, topnodes[sub].StartKey)
            end
        end
    end # if topnodes[node].size >
end

function walk_toptree(tree::PhysicalOctree, no::Int64)
    if tree.topnodes[no].Daughter == -1
        tree.NTopLeaves += 1
        tree.topnodes[no].Leaf = tree.NTopLeaves
    else
        for i in 0:7
            tree.NTopLeaves = walk_toptree(tree, tree.topnodes[no].Daughter + i)
        end
    end
end

function split_topnode(tree::PhysicalOctree)
    split_topnode_kernel(tree, 1, Int128(0))

    walk_toptree(tree, 1)
end

function sum_cost(tree::PhysicalOctree)
    topnodes = tree.topnodes
    data = tree.data
    tree.DomainWork = zeros(Float64, tree.NTopLeaves)
    tree.DomainCount = zeros(Int64, tree.NTopLeaves)
    for i in 1:tree.NumLocal
        no = 1
        while topnodes[no].Daughter >= 0
            no = trunc(Int64, topnodes[no].Daughter + (tree.peano_keys[i] - topnodes[no].StartKey) / (topnodes[no].Size / 8))
        end
        no = topnodes[no].Leaf

        tree.DomainWork[no] += 1.0
        tree.DomainCount[no] += 1
    end
end

function find_split_kernel(tree::PhysicalOctree, cpustart::Int64, ncpu::Int64, First::Int64, Last::Int64)
    ncpu_leftOfSplit = trunc(Int64, ncpu / 2)
    load = 0

    for i in First:Last
        load += tree.DomainCount[i]
    end

    split = First + ncpu_leftOfSplit
    load_leftOfSplit = 0

    for i in First:split-1
        load_leftOfSplit += tree.DomainCount[i]
    end

    # find the best split point in terms of work-load balance
    while split < Last - (ncpu - ncpu_leftOfSplit - 1) && split > 1
        maxAvgLoad_CurrentSplit = max(load_leftOfSplit / ncpu_leftOfSplit, (load - load_leftOfSplit) / (ncpu - ncpu_leftOfSplit))
        maxAvgLoad_NewSplit = max((load_leftOfSplit + tree.DomainCount[split]) / ncpu_leftOfSplit,
                                  (load - load_leftOfSplit - tree.DomainCount[split]) / (ncpu - ncpu_leftOfSplit))
        if maxAvgLoad_NewSplit <= maxAvgLoad_CurrentSplit
            load_leftOfSplit += tree.DomainCount[split]
            split += 1
        else
            break
        end
    end

    load_leftOfSplit = 0
    for i in First:split-1
        load_leftOfSplit += tree.DomainCount[i]
    end

    # check whether this solution is possible given the restrictions on the maximum load

    #if load_leftOfSplit > maxload * ncpu_leftOfSplit || (load - load_leftOfSplit) > maxload * (ncpu - ncpu_leftOfSplit)
    #    return false
    #end

    if ncpu_leftOfSplit >= 2
        ok_left = find_split_kernel(tree, cpustart, ncpu_leftOfSplit, First, split-1)
    else
        ok_left = true
    end

    if ncpu - ncpu_leftOfSplit >= 2
        ok_right = find_split_kernel(tree, cpustart + ncpu_leftOfSplit, ncpu - ncpu_leftOfSplit, split, Last)
    else
        ok_right = true
    end

    if ok_left && ok_right
        # found a viable split
        if ncpu_leftOfSplit == 1
            for i in First:split-1
                tree.DomainTask[i] = cpustart
            end

            tree.list_load[cpustart] = load_leftOfSplit;
	        tree.DomainStartList[cpustart] = First;
	        tree.DomainEndList[cpustart] = split-1;
        end

        if ncpu - ncpu_leftOfSplit == 1
            for i in split:Last
                tree.DomainTask[i] = cpustart + ncpu_leftOfSplit
            end

            tree.list_load[cpustart + ncpu_leftOfSplit] = load - load_leftOfSplit;
            tree.DomainStartList[cpustart + ncpu_leftOfSplit] = split;
            tree.DomainEndList[cpustart + ncpu_leftOfSplit] = Last;
        end

        return true
    end

    return false
end

function find_split(tree::PhysicalOctree)
    npids = length(tree.pids)

    tree.DomainStartList = zeros(Int64, npids)
    tree.DomainEndList = zeros(Int64, npids)
    tree.list_load = zeros(Int64, npids)
    tree.list_work = zeros(Float64, npids)

    tree.DomainTask = zeros(Int64, tree.NTopLeaves)

    find_split_kernel(tree, 1, npids, 1, tree.NTopLeaves)

    tree.DomainMyStart = tree.DomainStartList[findfirst(x->x==myid(), tree.pids)]
    tree.DomainMyEnd = tree.DomainEndList[findfirst(x->x==myid(), tree.pids)]
end

function find_split_kernel()
    
end

function shift_split(tree::PhysicalOctree)
    
end

function split_domain(tree::PhysicalOctree)
    bcast(tree, init_peano)
    bcast(tree, init_topnode)

    bcast(tree, split_topnode_local)

    allsum(tree, :NTopnodes)
    allsum(tree, :NTopLeaves)

    tree.StartKeys = reduce(vcat, gather(tree, :StartKeys))
    tree.Counts = reduce(vcat, gather(tree, :Counts))
    key_sort_bcast(tree)

    bcast(tree, reinit_topnode)

    bcast(tree, split_topnode)

    tree.DomainFac = getfrom(tree, first(tree.pids), :DomainFac)
    tree.NTopnodes = getfrom(tree, first(tree.pids), :NTopnodes)
    tree.NTopLeaves = getfrom(tree, first(tree.pids), :NTopLeaves)

    bcast(tree, sum_cost)

    tree.DomainWork = sum(gather(tree, :DomainWork))
    tree.DomainCount = sum(gather(tree, :DomainCount))
    bcast(tree, :DomainWork, tree.DomainWork)
    bcast(tree, :DomainCount, tree.DomainWork)

    bcast(tree, find_split)
    tree.DomainStartList = getfrom(tree, first(tree.pids), :DomainStartList)
    tree.DomainEndList = getfrom(tree, first(tree.pids), :DomainEndList)

    bcast(tree, shift_split)
end