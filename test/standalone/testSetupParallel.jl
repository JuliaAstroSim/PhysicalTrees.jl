@info "Initializing"
using Distributed
using Unitful, UnitfulAstro
addprocs(4)

@everywhere using PhysicalParticles
@everywhere include("PhysicalTrees.jl/src/PhysicalTrees.jl")
@everywhere using .PhysicalTrees

@info "Loading data"
data = [PVector(1.0, 1.0, 1.0, u"kpc"), PVector(-1.0, -1.0, -1.0, u"kpc"),
        PVector(1.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 1.0, u"kpc"),
        PVector(0.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 0.0, u"kpc")]

@info "Building tree"
tree = octree(data)

#=
@everywhere workers() @show PhysicalTrees.registry[Pair(1,1)].data
@everywhere workers() @show length(PhysicalTrees.registry[Pair(1,1)].topnodes)

=#
