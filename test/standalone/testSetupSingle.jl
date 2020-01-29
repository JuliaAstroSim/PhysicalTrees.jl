@info "Initializing"
include("../../src/PhysicalTrees.jl")
using .PhysicalTrees
using Distributed
using Unitful, UnitfulAstro

using PhysicalParticles

@info "Loading data"
data = [PVector(1.0, 1.0, 1.0, u"kpc"), PVector(-1.0, -1.0, -1.0, u"kpc"),
        PVector(1.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 1.0, u"kpc"),
        PVector(0.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 0.0, u"kpc")]

@info "Building tree"
tree = octree(data)
println(tree)

"""
@show PhysicalTrees.registry[Pair(1,1)]
"""