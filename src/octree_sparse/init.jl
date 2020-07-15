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
        registry[id] = setproperties!!(registry[id], isholder = true)
    else # Not included, so to init a new tree
        init_octree(id, true, units, config, e, empty(data), NumTotal, pids, type)
    end

    return registry[id]
end

function unregister(tree::AbstractTree)
    Distributed.remotecall_eval(PhysicalTrees, tree.pids, :(pop!(registry, $(tree.id))))
    if haskey(registry, tree.id) # This holder is included in pids
        pop!(registry, tree.id)
    end
end
