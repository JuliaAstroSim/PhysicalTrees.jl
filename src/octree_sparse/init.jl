"""
    init_octree(data, units, config::OctreeConfig, pids::Array{Int64,1})

Preprocess data (find the extent), set up empty trees on `pids`, and return the instance on master process.
"""
function init_octree(data, units, config::OctreeConfig, pids::Array{Int64,1})
    id = next_treeid()

    # Find the extent and enlarge a little to make sure that all particles fall inside the domain
    e = extent(data)
    SideLength = e.SideLength * config.ExtentMargin
    e = setproperties!!(e, SideLength = SideLength, Corner = e.Center - PVector(SideLength, SideLength, SideLength) * 0.5)

    type = datadimension(data) # to avoid empty arrays
    NumTotal = countdata(data)

    # Send to remote workers
    @sync @distributed for i in 1:length(pids)
        d = split_data(data, i, length(pids))
        Distributed.remotecall_eval(PhysicalTrees, pids[i], :(init_octree($id, false, $units, $config, $e, $d, $NumTotal, $pids, $type)))
    end

    if haskey(registry, id) # Master process is already included in pids, set it as holder
        registry[id].isholder = true
    else # Not included. Need to init an empty tree
        init_octree(id, true, units, config, e, empty(data), NumTotal, pids, type)
    end

    return registry[id]
end

"""
    unregister(tree::AbstractTree)

Empty distributed registers of `tree`, memory would be released in the next GC routine.
"""
function unregister(tree::AbstractTree)
    Distributed.remotecall_eval(PhysicalTrees, tree.pids, :(pop!(registry, $(tree.id))))
    if haskey(registry, tree.id) # This holder is included in pids
        pop!(registry, tree.id)
    end
end
