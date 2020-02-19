@testset "Rebuild" begin
    @everywhere pids for i in eachindex(Main.PhysicalTrees.registry[$(tree.id)].data)
        Main.PhysicalTrees.registry[$(tree.id)].data[i].Pos *= 0.5
    end

    rebuild(tree)
    
    update_node_len(tree)
end