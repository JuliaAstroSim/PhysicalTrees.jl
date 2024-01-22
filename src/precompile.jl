@setup_workload begin
    @compile_workload begin
        #TODO 2D octree

        # 3D octree
        AstroPVectorData = [PVector(1.0, 1.0, 1.0, u"kpc"), PVector(-1.0, -1.0, -1.0, u"kpc"),
                    PVector(1.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 1.0, u"kpc"),
                    PVector(0.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 0.0, u"kpc")]
        AstroParticleData = StructArray(Star(uAstro) for i in 1:6)
        assign_particles(AstroParticleData, :Pos, AstroPVectorData)
        tree = octree(AstroParticleData)

        UnitlessPVectorData = [PVector(1.0, 1.0, 1.0), PVector(-1.0, -1.0, -1.0),
                       PVector(1.0, 0.0, -1.0), PVector(-1.0, 0.0, 1.0),
                       PVector(0.0, 0.0, -1.0), PVector(-1.0, 0.0, 0.0)]
        UnitlessParticleData = StructArray(Star() for i in 1:6)
        assign_particles(UnitlessParticleData, :Pos, UnitlessPVectorData)
        tD = octree(UnitlessParticleData)
    end
end
