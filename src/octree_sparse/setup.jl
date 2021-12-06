"""
    octree(data)

Build an octree from `data`, which is either point data or particle data.

# Keywords

| Keyword | Usage | Default value |
| `units` | Set internal units | `uAstro` |
| `config` | | `OctreeConfig(length(data))` |
| `pids` | Array of workers to distribute the tree. The master process could be included | workers() |

# Main workflow

1. `init_octree`
2. `split_domain`
3. `build`
4. `update`
"""

function octree(data,
               ;
               units = uAstro,
               config = OctreeConfig(length(data)),
               pids = workers(),)
    tree = init_octree(StructArray(data), units, config, pids)
    split_domain(tree)
    build(tree)
    update(tree)
    return tree
end

function rebuild(tree::Octree)
    global_extent(tree)
    split_domain(tree)
    build(tree)
    update(tree)
    return tree
end

function update_DomainTask_pids(tree::Octree, pids::Array{Int64,N}, newid::Pair{Int64, Int64}) where N
    DomainTask = tree.domain.DomainTask
    oldpids = tree.pids
    for i in eachindex(tree.pids)
        for j in eachindex(DomainTask)
            if DomainTask[j] == tree.pids[i]
                DomainTask[j] = pids[i]
            end
        end
    end

    tree = setproperties!!(tree, id = newid, pids = pids)
end

#=
"""
    redistribute(tree::Octree, pids::Array{Int64,N})

When restarting a simulation, the octree might be redistributed on different workers compared to the original simulation,
thus causing wrong domain indexing.
`redistribute` would transfer tree data to correct workers.
"""
function redistribute(tree::Octree, pids::Array{Int64,N}) where N
    if length(tree.pids) != length(pids)
        error("The tree has to be redistributed to equallly numbered processes!")
    end

    oldid = tree.id
    if oldid.first in tree.pids
        if !(oldid.first in pids)
            error("Holder cannot be changed!")
        end
    end

    newid = next_treeid()

    # Transfer data
    for i in 1:length(tree.pids)
        transfer(tree.pids[i], pids[i], :(registry[$oldid]), :(registry[$newid]), PhysicalTrees, PhysicalTrees)
    end
    @everywhere tree.pids pop!(PhysicalTrees.registry, $oldid)

    # Fix pid
    @everywhere pids PhysicalTrees.update_DomainTask_pids(PhysicalTrees.registry[$newid], $pids, $newid)

    # If the holder is not in pids, its id has not beed updated in the transfering
    if !(oldid.first in tree.pids)
        registry[newid] = registry[oldid]

        # This would affect the old one either, so we cannot simply unregister tree
        registry[newid] = setproperties!!(registry[newid], id = newid, pids = pids)
        pop!(registry, oldid)
    end

    return registry[newid]
end
=#