@info "Initializing"
using Distributed
addprocs(2)

@everywhere using PhysicalParticles
@everywhere include("PhysicalTrees.jl/src/PhysicalTrees.jl")
@everywhere using .PhysicalTrees

@info "Loading data"
data = [Star() for i = 1:9]

@info "Building tree"
tree = setup(data)

e = reduce(extent, gather(extent, tree, :data))