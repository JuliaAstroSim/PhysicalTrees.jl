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

AstroParticleData = StructArray(Star(uAstro) for i in 1:6)
assign_particles(AstroParticleData, :Pos, AstroPVectorData)

AstroPVectorData2D = [PVector(1.0, 1.0, u"kpc"), PVector(-1.0, -1.0, u"kpc"),
                      PVector(1.0, 0.0, u"kpc"), PVector(-1.0, 0.0, u"kpc"),
                      PVector(0.0, 0.0, u"kpc"), PVector(-1.0, 1.0, u"kpc")]

AstroParticleData2D = StructArray(Star2D(uAstro) for i in 1:6)
assign_particles(AstroParticleData2D, :Pos, AstroPVectorData2D)

UnitlessPVectorData = [PVector(1.0, 1.0, 1.0), PVector(-1.0, -1.0, -1.0),
                       PVector(1.0, 0.0, -1.0), PVector(-1.0, 0.0, 1.0),
                       PVector(0.0, 0.0, -1.0), PVector(-1.0, 0.0, 0.0)]

UnitlessParticleData = StructArray(Star() for i in 1:6)
assign_particles(UnitlessParticleData, :Pos, UnitlessPVectorData)

UnitlessPVectorData2D = [PVector(1.0, 1.0), PVector(-1.0, -1.0),
                         PVector(1.0, 0.0), PVector(-1.0, 0.0),
                         PVector(0.0, 0.0), PVector(-1.0, 1.0)]

UnitlessParticleData2D = StructArray(Star2D() for i in 1:6)
assign_particles(UnitlessParticleData2D, :Pos, UnitlessPVectorData2D)

# Test data structure

tD = octree(UnitlessParticleData, pids = pids)
tree = octree(AstroParticleData, pids = pids)


# Core
include("testParallel.jl")
include("testPeano.jl")

# Tree

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