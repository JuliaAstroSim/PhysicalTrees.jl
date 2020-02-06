using Test
using Unitful, UnitfulAstro
using Distributed

using PhysicalParticles
using ParallelOperations

pids = addprocs(4)
@everywhere using PhysicalTrees

@info "Initializing data"
AstroPVectorData = [PVector(1.0, 1.0, 1.0, u"kpc"), PVector(-1.0, -1.0, -1.0, u"kpc"),
                    PVector(1.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 1.0, u"kpc"),
                    PVector(0.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 0.0, u"kpc")]

AstroParticleData = [Star() for i in 1:6]
assign_points(AstroParticleData, :Pos, AstroPVectorData)

AstroPVectorData2D = [PVector(1.0, 1.0, u"kpc"), PVector(-1.0, -1.0, u"kpc"),
                      PVector(1.0, 0.0, u"kpc"), PVector(-1.0, 0.0, u"kpc"),
                      PVector(0.0, 0.0, u"kpc"), PVector(-1.0, 1.0, u"kpc")]

AstroParticleData2D = [Star2D() for i in 1:6]
assign_points(AstroParticleData2D, :Pos, AstroPVectorData2D)

UnitlessPVectorData = [PVector(1.0, 1.0, 1.0), PVector(-1.0, -1.0, -1.0),
                       PVector(1.0, 0.0, -1.0), PVector(-1.0, 0.0, 1.0),
                       PVector(0.0, 0.0, -1.0), PVector(-1.0, 0.0, 0.0)]

UnitlessParticleData = [Massless() for i in 1:6]
assign_points(UnitlessParticleData, :Pos, UnitlessPVectorData)

UnitlessPVectorData2D = [PVector(1.0, 1.0), PVector(-1.0, -1.0),
                         PVector(1.0, 0.0), PVector(-1.0, 0.0),
                         PVector(0.0, 0.0), PVector(-1.0, 1.0)]

UnitlessParticleData2D = [Massless2D() for i in 1:6]
assign_points(UnitlessParticleData2D, :Pos, UnitlessPVectorData2D)

# Core
include("testParallel.jl")
include("testPeano.jl")

# Stability
include("testEmpty.jl")
include("testUnits.jl")

rmprocs(pids)