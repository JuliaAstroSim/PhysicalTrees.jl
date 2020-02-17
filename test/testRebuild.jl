@testset "Rebuild" begin
    oldtree = deepcopy(tree)

    @everywhere pids for i in eachindex(Main.PhysicalTrees.registry[$(tree.id)].data)
        Main.PhysicalTrees.registry[$(tree.id)].data[i] *= 0.5
    end

    rebuild(tree)
    newtree = tree

    @info "old tree"
    #dump(oldtree)

    @info "rebuilt tree"
    #dump(newtree)
end