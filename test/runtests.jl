using Test
using Unitful, UnitfulAstro
using Distributed

using PhysicalParticles
using ParallelOperations

pids = addprocs(4)
@everywhere using PhysicalTrees

AstroData = [PVector(1.0, 1.0, 1.0, u"kpc"), PVector(-1.0, -1.0, -1.0, u"kpc"),
             PVector(1.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 1.0, u"kpc"),
             PVector(0.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 0.0, u"kpc")]

UnitlessData = [PVector(1.0, 1.0, 1.0), PVector(-1.0, -1.0, -1.0),
                PVector(1.0, 0.0, -1.0), PVector(-1.0, 0.0, 1.0),
                PVector(0.0, 0.0, -1.0), PVector(-1.0, 0.0, 0.0)]

AstroTreeParallel = octree(AstroData, pids = pids)
AstroTreeSingle = octree(AstroData, pids = [1])

tree = AstroTreeParallel

# Core
include("testParallel.jl")
include("testExtent.jl")
include("testPeano.jl")

# Stability
include("testEmpty.jl")

rmprocs(pids)