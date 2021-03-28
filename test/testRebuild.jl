@testset "Rebuild" begin
    @everywhere pids for k in keys(Main.PhysicalTrees.registry[$(tree.id)].data)
        for i in eachindex(Main.PhysicalTrees.registry[$(tree.id)].data[k])
            Pos = Main.PhysicalTrees.registry[$(tree.id)].data[k][i].Pos
            Main.PhysicalTrees.registry[$(tree.id)].data[k][i] = setproperties!!(Main.PhysicalTrees.registry[$(tree.id)].data[k][i], Pos = 0.5 * Pos)
        end
    end

    rebuild(tree)
end

@testset "Redistribute" begin
    t = octree(AstroParticleData, pids = [2,3])
    t = redistribute(t, [4,5])
    @test sum(t.pids) == 9

    t = octree(AstroParticleData, pids = [1,2])
    t = redistribute(t, [1,3])
    @test sum(t.pids) == 4
end