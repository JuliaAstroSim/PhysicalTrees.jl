using Test
using Unitful, UnitfulAstro
using Distributed

using PhysicalParticles
using ParallelOperations

pids = addprocs(4)
@everywhere using PhysicalTrees

# Core
include("testParallel.jl")
include("testExtent.jl")
include("testPeano.jl")

# Stability
include("testEmpty.jl")