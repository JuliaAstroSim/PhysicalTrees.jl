@testset "Rebuild" begin
    @everywhere pids for i in eachindex(Main.PhysicalTrees.registry[$(tree.id)].data)
        Pos = Main.PhysicalTrees.registry[$(tree.id)].data[i].Pos
        Main.PhysicalTrees.registry[$(tree.id)].data[i] = setproperties!!(Main.PhysicalTrees.registry[$(tree.id)].data[i], Pos = 0.5 * Pos)
    end

    rebuild(tree)
end

@testset "Redistribute" begin
    t = octree(AstroPVectorData, pids = [2,3])
    t = redistribute(t, [4,5])
    @test sum(t.pids) == 9

    t = octree(AstroPVectorData, pids = [1,2])
    t = redistribute(t, [1,3])
    @test sum(t.pids) == 4
end