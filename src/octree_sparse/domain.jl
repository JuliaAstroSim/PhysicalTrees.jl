"""
    init_peano(tree::Octree)

1. Count local number of data
2. Compute `domain.DomainFac`
3. Compute peano keys of local data
4. Sort peano keys and store in `domain.peano_keys`
"""
function init_peano(tree::Octree)
    tree.NumLocal = length(tree.data)

    tree.domain.DomainFac = (1 << tree.config.PeanoBits3D) / tree.extent.SideLength

    peano = peanokey(tree.data, tree.extent.Corner, tree.domain.DomainFac, tree.config.PeanoBits3D)
    sort!(peano, by = x -> x.first)
    tree.domain.peano_keys = peano
end

"""
    init_topnode(tree::Octree)

Allocate `domain.topnodes`, set up the first topnode and count `NTopnodes` from 1
"""
function init_topnode(tree::Octree)
    tree.domain.topnodes = [TopNode(bits = tree.config.PeanoBits3D) for i in 1:tree.config.ToptreeAllocSection]
    tree.domain.NTopnodes = 1
    tree.domain.topnodes[1] = setproperties!!(tree.domain.topnodes[1], Count = Int128(tree.NumLocal))
end

function split_topnode_local_kernel(tree::Octree, node::Int64, startkey::Int128)
    topnodes = tree.domain.topnodes
    if topnodes[node].Size >= 8
        topnodes[node] = setproperties!!(topnodes[node], Daughter = tree.domain.NTopnodes + 1)

        # Set up daughter topnodes
        daughtersize = div(topnodes[node].Size , 8)
        for i in 0:7
            if tree.domain.NTopnodes >= length(topnodes) - 8
                if length(topnodes) <= tree.config.MaxTopnode
                    append!(topnodes, [TopNode(bits = tree.config.PeanoBits3D) for i in 1:tree.config.ToptreeAllocSection])
                else
                    error("Running out of topnodes, please increase the MaxTopNodes (= ", tree.config.MaxTopnode,") in Config")
                end
            end

            sub = topnodes[node].Daughter + i

            #! Notice: StartKey depends on Size, so they should not be computed at the same time
            newstartkey = startkey + i * daughtersize
            topnodes[sub] = setproperties!!(topnodes[sub], Size = daughtersize,
                                                           Count = Int128(0),
                                                           Daughter = -1,
                                                           StartKey = newstartkey,
                                                           Pstart = topnodes[node].Pstart)

            tree.domain.NTopnodes += 1
        end

        # Count particles located in daughter topnodes
        for p in topnodes[node].Pstart : topnodes[node].Pstart + topnodes[node].Count - 1
            bin = floor(Int64, (tree.domain.peano_keys[p].first - startkey) / (topnodes[node].Size / 8))
            if bin < 0 || bin > 7
                error("something odd has happened here. node = ", node, ", bin = ", bin, ", startkey = ", startkey, " p = ", p, )
            end

            sub = topnodes[node].Daughter + bin
            if topnodes[sub].Count == 0
                topnodes[sub] = setproperties!!(topnodes[sub], Pstart = p)
            end
            topnodes[sub] = setproperties!!(topnodes[sub], Count = topnodes[sub].Count + 1)
        end

        for i in 0:7
            sub = topnodes[node].Daughter + i
            if topnodes[sub].Count > tree.NumTotal / (tree.config.TopnodeFactor * length(tree.pids)^2)
                split_topnode_local_kernel(tree, sub, topnodes[sub].StartKey)
            end
        end
    end # if topnodes[node].size >= 8
end

"""
    count_leaves(tree::Octree)

Count local toptree leaves
"""
function count_leaves(tree::Octree)
    topnodes = tree.domain.topnodes
    sc = tree.domain.sc
    empty!(sc)
    tree.domain.NTopLeaves = 0
    for i in 1:tree.domain.NTopnodes
        if topnodes[i].Daughter == -1
            tree.domain.NTopLeaves += 1
            push!(sc, SC(topnodes[i].StartKey, topnodes[i].Count))
        end
    end
end

function split_topnode_local(tree::Octree)
    split_topnode_local_kernel(tree, 1, Int128(0))

    count_leaves(tree)
end

#TODO Parallel sorting?
function key_sort_bcast(tree::Octree)
    sc = tree.domain.sc
    sort!(sc, by = x->x.StartKey)

    bcast(tree, :domain, :sc, tree.domain.sc)
end

function reinit_topnode(tree::Octree)
    tree.domain.topnodes = [TopNode(bits = tree.config.PeanoBits3D) for i in 1:tree.config.ToptreeAllocSection]
    tree.domain.topnodes[1] = setproperties!!(tree.domain.topnodes[1], Count = Int128(tree.NumTotal))
    tree.domain.topnodes[1] = setproperties!!(tree.domain.topnodes[1], Blocks = Int128(tree.domain.NTopLeaves))
    
    tree.domain.NTopLeaves = 0

    tree.domain.NTopnodes = 1
end

function split_topnode_kernel(tree::Octree, node::Int64, startkey::Int128)
    topnodes = tree.domain.topnodes
    if topnodes[node].Size >= 8
        topnodes[node] = setproperties!!(topnodes[node], Daughter = tree.domain.NTopnodes + 1)

        # Set up daughter topnodes
        daughtersize = div(topnodes[node].Size , 8)
        for i in 0:7
            if tree.domain.NTopnodes >= length(topnodes) - 8
                if length(topnodes) <= tree.config.MaxTopnode
                    append!(topnodes, [TopNode(bits = tree.config.PeanoBits3D) for i in 1:tree.config.ToptreeAllocSection])
                else
                    error("Running out of topnodes, please increase the MaxTopnode in Config")
                end
            end

            sub = topnodes[node].Daughter + i
            newstartkey = startkey + i * daughtersize
            topnodes[sub] = setproperties!!(topnodes[sub], Size = daughtersize,
                                                           Count = Int128(0),
                                                           Blocks = Int128(0),
                                                           Daughter = -1,
                                                           StartKey = newstartkey,
                                                           Pstart = topnodes[node].Pstart)

            tree.domain.NTopnodes += 1
        end

        # Count particles located in daughter topnodes
        for p in topnodes[node].Pstart : topnodes[node].Pstart + topnodes[node].Blocks - 1
            #if p == 849
            #    @show topnodes[node].Pstart + topnodes[node].Blocks - 1
            #end
            bin = floor(Int64, (tree.domain.sc[p].StartKey - startkey) / (topnodes[node].Size / 8))
            if bin < 0 || bin > 7
                @show (tree.domain.sc[p].StartKey - startkey) / (topnodes[node].Size / 8)
                @show p
                @show topnodes[node]
                error("something odd has happened here. bin = ", bin)
            end

            sub = topnodes[node].Daughter + bin
            if topnodes[sub].Blocks == 0
                topnodes[sub] = setproperties!!(topnodes[sub], Pstart = p)
            end
            topnodes[sub] = setproperties!!(topnodes[sub], Count = tree.domain.sc[p].Count + topnodes[sub].Count,
                                                           Blocks = topnodes[sub].Blocks + 1)
        end

        for i in 0:7
            sub = topnodes[node].Daughter + i
            if topnodes[sub].Count > tree.NumTotal / (tree.config.TopnodeFactor * length(tree.pids))
                split_topnode_kernel(tree, sub, topnodes[sub].StartKey)
            end
        end
    end # if topnodes[node].size >= 8
end

"""
    walk_toptree(tree::Octree, no::Int64)

Count toptree leaves and store leaf id
"""
function walk_toptree(tree::Octree, no::Int64)
    if tree.domain.topnodes[no].Daughter == -1
        tree.domain.NTopLeaves += 1
        tree.domain.topnodes[no] = setproperties!!(tree.domain.topnodes[no], Leaf = tree.domain.NTopLeaves)
    else
        for i in 0:7
            walk_toptree(tree, tree.domain.topnodes[no].Daughter + i)
        end
    end
end

function split_topnode(tree::Octree)
    split_topnode_kernel(tree, 1, Int128(0))

    walk_toptree(tree, 1)
end

function sum_cost(tree::Octree)
    topnodes = tree.domain.topnodes
    tree.domain.DomainWork = zeros(Float64, tree.domain.NTopLeaves)
    tree.domain.DomainCount = zeros(Int64, tree.domain.NTopLeaves)
    for i in 1:tree.NumLocal
        no = 1
        while topnodes[no].Daughter >= 0
            no = trunc(Int64, topnodes[no].Daughter + (tree.domain.peano_keys[i].first - topnodes[no].StartKey) / (topnodes[no].Size / 8))
        end
        no = topnodes[no].Leaf

        tree.domain.DomainWork[no] += 1.0
        tree.domain.DomainCount[no] += 1
    end
end

function find_split_kernel(tree::Octree, cpustart::Int64, ncpu::Int64, First::Int64, Last::Int64)
    ncpu_leftOfSplit = trunc(Int64, ncpu / 2)
    load = 0

    for i in First:Last
        load += tree.domain.DomainCount[i]
    end

    split = First + ncpu_leftOfSplit
    load_leftOfSplit = 0

    for i in First:split-1
        load_leftOfSplit += tree.domain.DomainCount[i]
    end

    # find the best split point in terms of work-load balance
    while split < Last - (ncpu - ncpu_leftOfSplit - 1) && split > 1
        maxAvgLoad_CurrentSplit = max(load_leftOfSplit / ncpu_leftOfSplit, (load - load_leftOfSplit) / (ncpu - ncpu_leftOfSplit))
        maxAvgLoad_NewSplit = max((load_leftOfSplit + tree.domain.DomainCount[split]) / ncpu_leftOfSplit,
                                  (load - load_leftOfSplit - tree.domain.DomainCount[split]) / (ncpu - ncpu_leftOfSplit))
        if maxAvgLoad_NewSplit <= maxAvgLoad_CurrentSplit
            load_leftOfSplit += tree.domain.DomainCount[split]
            split += 1
        else
            break
        end
    end

    load_leftOfSplit = 0
    for i in First:split-1
        load_leftOfSplit += tree.domain.DomainCount[i]
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
                tree.domain.DomainTask[i] = tree.pids[cpustart]
            end

            tree.domain.list_load[cpustart] = load_leftOfSplit;
	        tree.domain.DomainStartList[cpustart] = First;
	        tree.domain.DomainEndList[cpustart] = split-1;
        end

        if ncpu - ncpu_leftOfSplit == 1
            for i in split:Last
                tree.domain.DomainTask[i] = tree.pids[cpustart + ncpu_leftOfSplit]
            end

            tree.domain.list_load[cpustart + ncpu_leftOfSplit] = load - load_leftOfSplit;
            tree.domain.DomainStartList[cpustart + ncpu_leftOfSplit] = split;
            tree.domain.DomainEndList[cpustart + ncpu_leftOfSplit] = Last;
        end

        return true
    end

    return false
end

function find_split(tree::Octree)
    npids = length(tree.pids)

    tree.domain.DomainStartList = zeros(Int64, npids)
    tree.domain.DomainEndList = zeros(Int64, npids)
    tree.domain.list_load = zeros(Int64, npids)
    tree.domain.list_work = zeros(Float64, npids)

    tree.domain.DomainTask = zeros(Int64, tree.domain.NTopLeaves)

    find_split_kernel(tree, 1, npids, 1, tree.domain.NTopLeaves)

    tree.domain.DomainMyStart = tree.domain.DomainStartList[findfirst(x->x==myid(), tree.pids)]
    tree.domain.DomainMyEnd = tree.domain.DomainEndList[findfirst(x->x==myid(), tree.pids)]
end

function shift_split_kernel(tree::Octree)
    
end

function shift_split(tree::Octree)
    
end

"""
    fill_domain_buffer(tree::Octree)

Send particle alongside its peano key to the designated process.
"""
function fill_domain_buffer(tree::Octree)
    topnodes = tree.domain.topnodes
    DomainTask = tree.domain.DomainTask

    empty!(tree.domain.local_to_go)
    empty!(tree.sendbuffer)
    empty!(tree.recvbuffer)

    for p in tree.pids
        tree.domain.local_to_go[p] = 0
        tree.sendbuffer[p] = Array{Pair{Int128, Any}, 1}()
        tree.recvbuffer[p] = Array{Pair{Int128, Any}, 1}()
    end

    newdata = tree.data[1:0]
    newpeano = empty(tree.domain.peano_keys)

    for i in 1:tree.NumLocal
        no = 1
        while topnodes[no].Daughter >= 0
            no = trunc(Int64, topnodes[no].Daughter + (tree.domain.peano_keys[i].first - topnodes[no].StartKey) / (topnodes[no].Size / 8))
        end
        no = topnodes[no].Leaf

        if DomainTask[no] != myid() # To send
            tree.domain.local_to_go[DomainTask[no]] += 1
            push!(tree.sendbuffer[DomainTask[no]], Pair(tree.domain.peano_keys[i].first, tree.domain.peano_keys[i].second.x))
        else # leaves here
            push!(newdata, tree.domain.peano_keys[i].second.x)
            push!(newpeano, tree.domain.peano_keys[i])
        end
    end

    tree.data = newdata
    tree.domain.peano_keys = newpeano
end

function clear_domain_buffer(tree::Octree)
    data = tree.data
    peano_keys = tree.domain.peano_keys

    for d in Iterators.flatten(values(tree.recvbuffer))
        push!(peano_keys, Pair(d.first, Ref(d.second)))
        push!(data, d.second)
    end

    tree.NumLocal = length(data)

    empty!(tree.sendbuffer)
    empty!(tree.recvbuffer)
end

function split_domain(tree::Octree)
    # Initialization, compute local peano keys and allocate array of local topnodes
    bcast(tree, init_peano)
    bcast(tree, init_topnode)

    # Split local topnodes according to work load, collect block info
    bcast(tree, split_topnode_local)

    NTopnodes = sum(tree, :domain, :NTopnodes)
    bcast(tree, :domain, :NTopnodes, NTopnodes)
    NTopLeaves = sum(tree, :domain, :NTopLeaves)
    bcast(tree, :domain, :NTopLeaves, NTopLeaves)

    tree.domain.sc = reduce(vcat, gather(tree, :domain, :sc))
    key_sort_bcast(tree)

    # Now build a global topnode tree and split again according to collected global counts
    bcast(tree, reinit_topnode)
    bcast(tree, split_topnode)

    if myid() == tree.pids[1] || length(tree.pids) == 1
        sample_id = tree.pids[1]
    else
        sample_id = tree.pids[2]
    end
    tree.domain.DomainFac = getfrom(tree, sample_id, :domain, :DomainFac)
    tree.domain.NTopnodes = getfrom(tree, sample_id, :domain, :NTopnodes)
    tree.domain.NTopLeaves = getfrom(tree, sample_id, :domain, :NTopLeaves)

    # Sum work load, now we are ready to split computation domain
    bcast(tree, sum_cost)

    tree.domain.DomainWork = sum(gather(tree, :domain, :DomainWork))
    tree.domain.DomainCount = sum(gather(tree, :domain, :DomainCount))
    bcast(tree, :domain, :DomainWork, tree.domain.DomainWork)
    bcast(tree, :domain, :DomainCount, tree.domain.DomainWork)

    bcast(tree, find_split)
    tree.domain.DomainStartList = getfrom(tree, sample_id, :domain, :DomainStartList)
    tree.domain.DomainEndList = getfrom(tree, sample_id, :domain, :DomainEndList)

    bcast(tree, shift_split)

    # Send particles and peano keys to designated processes 
    bcast(tree, fill_domain_buffer)
    bcast(tree, send_buffer)
    bcast(tree, clear_domain_buffer)
end