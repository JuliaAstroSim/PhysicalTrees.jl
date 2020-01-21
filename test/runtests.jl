using Test
using Unitful, UnitfulAstro
using Distributed

using PhysicalParticles

using PhysicalTrees

include("testSetupSingle.jl")
include("testParallel.jl")
include("testPeano.jl")