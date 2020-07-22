function octree(data,
               ;
               units = uAstro,
               config = OctreeConfig(length(data)),
               pids = workers(),)
    tree = init_octree(data, units, config, pids)

    begin_timer(tree, "tree_domain")
    split_domain(tree)
    end_timer(tree, "tree_domain")
    
    begin_timer(tree, "tree_build")
    build(tree)
    end_timer(tree, "tree_build")
    
    begin_timer(tree, "tree_update")
    update(tree)
    end_timer(tree, "tree_update")

    return tree
end

function rebuild(tree::Octree)
    begin_timer(tree, "tree_domain")
    global_extent(tree)
    split_domain(tree)
    end_timer(tree, "tree_domain")
    
    begin_timer(tree, "tree_build")
    build(tree)
    end_timer(tree, "tree_build")
    
    begin_timer(tree, "tree_update")
    update(tree)
    end_timer(tree, "tree_update")
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

    tree.id = newid
    tree.pids = pids
end

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
        registry[newid].id = newid # This would affect the old one either, so we cannot simply unregister tree
        registry[newid].pids = pids
        pop!(registry, oldid)
    end


    return registry[newid]
end