using Test
using Unitful, UnitfulAstro
using Distributed

using PhysicalParticles
using ParallelOperations

pids = addprocs(2)
addprocs(2)
@everywhere using PhysicalTrees, BangBang

@info "Initializing data"
AstroPVectorData = [PVector(1.0, 1.0, 1.0, u"kpc"), PVector(-1.0, -1.0, -1.0, u"kpc"),
                    PVector(1.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 1.0, u"kpc"),
                    PVector(0.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 0.0, u"kpc")]

AstroParticleData = [Star(uAstro) for i in 1:6]
assign_particles(AstroParticleData, :Pos, AstroPVectorData)

AstroPVectorData2D = [PVector(1.0, 1.0, u"kpc"), PVector(-1.0, -1.0, u"kpc"),
                      PVector(1.0, 0.0, u"kpc"), PVector(-1.0, 0.0, u"kpc"),
                      PVector(0.0, 0.0, u"kpc"), PVector(-1.0, 1.0, u"kpc")]

AstroParticleData2D = [Star2D(uAstro) for i in 1:6]
assign_particles(AstroParticleData2D, :Pos, AstroPVectorData2D)

UnitlessPVectorData = [PVector(1.0, 1.0, 1.0), PVector(-1.0, -1.0, -1.0),
                       PVector(1.0, 0.0, -1.0), PVector(-1.0, 0.0, 1.0),
                       PVector(0.0, 0.0, -1.0), PVector(-1.0, 0.0, 0.0)]

UnitlessParticleData = [Star() for i in 1:6]
assign_particles(UnitlessParticleData, :Pos, UnitlessPVectorData)

UnitlessPVectorData2D = [PVector(1.0, 1.0), PVector(-1.0, -1.0),
                         PVector(1.0, 0.0), PVector(-1.0, 0.0),
                         PVector(0.0, 0.0), PVector(-1.0, 1.0)]

UnitlessParticleData2D = [Star2D() for i in 1:6]
assign_particles(UnitlessParticleData2D, :Pos, UnitlessPVectorData2D)

# Test data structure
tPV = octree(AstroPVectorData, pids = pids)
tP = octree(AstroParticleData, pids = pids)
tUPV = octree(UnitlessPVectorData, pids = pids)
tUP = octree(UnitlessParticleData, pids = pids)

tD = octree(Dict(:stars => UnitlessParticleData), pids = pids)
tree = octree(Dict(:stars => AstroParticleData), pids = pids)


# Core
include("testParallel.jl")
include("testPeano.jl")

# Tree
include("testUpdate.jl")

# Stability
include("testEdge.jl")
include("testEmpty.jl")
include("testUnits.jl")
include("testCloser.jl")

include("testRebuild.jl")

@testset "Unregister" begin
    id = tree.id
    unregister(tree)
    @test !haskey(PhysicalTrees.registry, id)
end

rmprocs(pids)