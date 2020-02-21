function extent(tree::AbstractTree)
    if tree.isholder
        d = gather(tree, extent, :data)
        e = Array{AbstractExtent, 1}()
        for p in d
            if !isnothing(p)
                push!(e, p)
            end
        end
        return extent(e)
    else
        if isempty(tree.data)
            return nothing
        else
            return extent(tree.data)
        end
    end
end

"""
function split_data(data::Array, i::Int64, N::Int64)

    split data to N sections, return the ith section
"""
function split_data(data::Array, i::Int64, N::Int64)
    if i > N || i <= 0
        error("Wrong section index! 1 <= i <= N, i ∈ Integer")
    end

    if length(data) == 0
        return empty(data)
    end

    len = length(data)
    sec = div(len, N)
    if len % N == 0
        head = (i - 1) * sec + 1
        return data[head : head + sec - 1]
    else
        if i <= len % N
            head = (i - 1) * (sec + 1) + 1
            return data[head : head + sec] # add one element
        else
            head = len - (N - i + 1) * sec + 1 # from tail
            return data[head : head + sec - 1]
        end
    end
end

function init_octree(data::Array, units, config::OctreeConfig, pids::Array{Int64,1})
    id = next_treeid()
    e = extent(data)
    e.SideLength *= config.ExtentMargin
    type = datadimension(data) # to avoid empty arrays
    NumTotal = length(data)

    @sync @distributed for i in 1:length(pids)
        d = split_data(data, i, length(pids))
        Distributed.remotecall_eval(PhysicalTrees, pids[i], :(init_octree($id, false, $units, $config, $e, $d, $NumTotal, $pids, $type)))
    end

    if haskey(registry, id) # This holder is included in pids
        registry[id].isholder = true
    else # Not included, so to init a new tree
        init_octree(id, true, units, config, e, empty(data), NumTotal, pids, type)
    end

    return registry[id]
end

function unregister_octree(tree::AbstractTree)
    Distributed.remotecall_eval(PhysicalTrees, tree.pids, :(pop!(registry, $(tree.id))))
    if haskey(registry, tree.id) # This holder is included in pids
        pop!(registry, tree.id)
    end
end
