@testset "Rebuild" begin
    @everywhere tree.pids Main.PhysicalTrees.registry[$(tree.id)].data.Pos .*= 0.5

    @test !isnothing(rebuild(tree))
end
#=
@testset "Redistribute" begin
    t = octree(AstroParticleData, pids = [2,3])
    n = redistribute(t, [4,5])
    @test sum(n.pids) == 9

    t = octree(AstroParticleData, pids = [1,2])
    n = redistribute(t, [1,3])
    @test sum(n.pids) == 4
end
=#