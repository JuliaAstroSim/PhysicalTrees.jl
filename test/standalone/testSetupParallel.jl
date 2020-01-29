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

@everywhere workers() @show PhysicalTrees.registry[Pair(1,1)].sendbuffer
println()
@everywhere workers() @show PhysicalTrees.registry[Pair(1,1)].recvbuffer

#=
@everywhere workers() @show PhysicalTrees.registry[Pair(1,1)].data
@everywhere workers() @show length(PhysicalTrees.registry[Pair(1,1)].topnodes)
@everywhere workers() @show PhysicalTrees.registry[Pair(1,1)].DeleteIDs
@everywhere workers() @show PhysicalTrees.registry[Pair(1,1)].sendbuffer
@everywhere workers() @show PhysicalTrees.registry[Pair(1,1)].recvbuffer

julia> @everywhere workers() @show PhysicalTrees.registry[Pair(1,1)].sendbuffer
      From worker 3:    (PhysicalTrees.registry[Pair(1, 1)]).sendbuffer = Dict(4 => [PVector(1.0 kpc, 0.0 kpc, -1.0 kpc) => 3458764542811682304],2 => [],3 => [],5 => [PVector(-1.0 kpc, 0.0 kpc, 1.0 kpc) => 8070450544442588086])
      From worker 4:    (PhysicalTrees.registry[Pair(1, 1)]).sendbuffer = Dict(4 => [],2 => [PVector(0.0 kpc, 0.0 kpc, -1.0 kpc) => 699988051536585910],3 => [],5 => [])
      From worker 2:    (PhysicalTrees.registry[Pair(1, 1)]).sendbuffer = Dict(4 => [PVector(1.0 kpc, 1.0 kpc, 1.0 kpc) => 5929310623038323126],2 => [],3 => [],5 => [])
      From worker 5:    (PhysicalTrees.registry[Pair(1, 1)]).sendbuffer = Dict(4 => [],2 => [PVector(-1.0 kpc, 0.0 kpc, 0.0 kpc) => 988218430104226102],3 => [],5 => [])

julia> @everywhere workers() @show PhysicalTrees.registry[Pair(1,1)].recvbuffer
      From worker 3:    (PhysicalTrees.registry[Pair(1, 1)]).recvbuffer = Dict(4 => [],2 => [],3 => [],5 => [])
      From worker 4:    (PhysicalTrees.registry[Pair(1, 1)]).recvbuffer = Dict(4 => [],2 => [],3 => [PVector(1.0 kpc, 0.0 kpc, -1.0 kpc) => 3458764542811682304],5 => [])
      From worker 5:    (PhysicalTrees.registry[Pair(1, 1)]).recvbuffer = Dict(4 => [],2 => [],3 => [PVector(-1.0 kpc, 0.0 kpc, 1.0 kpc) => 8070450544442588086],5 => [])
      From worker 2:    (PhysicalTrees.registry[Pair(1, 1)]).recvbuffer = Dict(4 => [],2 => [],3 => [],5 => [PVector(-1.0 kpc, 0.0 kpc, 0.0 kpc) => 988218430104226102])
=#
