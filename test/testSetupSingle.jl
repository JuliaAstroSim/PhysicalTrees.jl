@info "Initializing"
include("../src/PhysicalTrees.jl")
using .PhysicalTrees
using Distributed

using PhysicalParticles

@info "Loading data"
data = [Star() for i = 1:9]

@info "Building tree"
setup(data)