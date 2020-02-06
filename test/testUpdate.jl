@testset "Octree Update" begin
    @test PhysicalTrees.getmass(PVector(), nothing) == 0.0
    @test PhysicalTrees.getmass(PVector(u"m"), u"Msun") == 0.0u"Msun"
    @test PhysicalTrees.getpos(PVector()) == PVector()
    @test PhysicalTrees.getvel(PVector(), nothing) == PVector()
    @test PhysicalTrees.getvel(PVector(u"m"), u"m/s") == PVector(u"m/s")

    @test PhysicalTrees.getmass(Massless(), nothing) == 0.0
    @test PhysicalTrees.getmass(Star(), u"Msun") == 0.0u"Msun"
    @test PhysicalTrees.getpos(Massless()) == PVector()
    @test PhysicalTrees.getvel(Massless(), nothing) == PVector()
    @test PhysicalTrees.getvel(Star(), u"m/s") == PVector(u"m/s")
end