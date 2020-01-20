@info "Initializing"
include("../src/PhysicalTrees.jl")
using .PhysicalTrees
using Distributed

using PhysicalParticles

@info "Loading data"
data = [Star() for i = 1:9]

@info "Building tree"
tree = setup(data)

"""
@show PhysicalTrees.registry[Pair(1,1)]
"""