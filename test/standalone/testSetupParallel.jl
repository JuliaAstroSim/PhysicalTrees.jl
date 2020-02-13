@info "Initializing"
using Distributed
using Unitful, UnitfulAstro
pids = addprocs(4)

@everywhere using PhysicalParticles
@everywhere include("PhysicalTrees.jl/src/PhysicalTrees.jl")
@everywhere using .PhysicalTrees

@info "Loading data"
AstroPVectorData = [PVector(1.0, 1.0, 1.0, u"kpc"), PVector(-1.0, -1.0, -1.0, u"kpc"),
                    PVector(1.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 1.0, u"kpc"),
                    PVector(0.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 0.0, u"kpc")]

AstroParticleData = [Star(uAstro) for i in 1:6]
assign_particles(AstroParticleData, :Pos, AstroPVectorData)

AstroPVectorData2D = [PVector(1.0, 1.0, u"kpc"), PVector(-1.0, -1.0, u"kpc"),
                      PVector(1.0, 0.0, u"kpc"), PVector(-1.0, 0.0, u"kpc"),
                      PVector(0.0, 0.0, u"kpc"), PVector(-1.0, 1.0, u"kpc")]

AstroParticleData2D = [Star2D(uAstro) for i in 1:6]
assign_particles(AstroParticleData2D, :Pos, AstroPVectorData2D)

UnitlessPVectorData = [PVector(1.0, 1.0, 1.0), PVector(-1.0, -1.0, -1.0),
                       PVector(1.0, 0.0, -1.0), PVector(-1.0, 0.0, 1.0),
                       PVector(0.0, 0.0, -1.0), PVector(-1.0, 0.0, 0.0)]

UnitlessParticleData = [Massless() for i in 1:6]
assign_particles(UnitlessParticleData, :Pos, UnitlessPVectorData)

UnitlessPVectorData2D = [PVector(1.0, 1.0), PVector(-1.0, -1.0),
                         PVector(1.0, 0.0), PVector(-1.0, 0.0),
                         PVector(0.0, 0.0), PVector(-1.0, 1.0)]

UnitlessParticleData2D = [Massless2D() for i in 1:6]
assign_particles(UnitlessParticleData2D, :Pos, UnitlessPVectorData2D)

@info "Building tree"

#! Test single first, since some error info could not be fetched from remote
tree1 = octree(AstroPVectorData, pids = [1])
println(tree1)

t1 = octree(UnitlessPVectorData, pids = [1])
println(t1)

tree2 = octree(AstroParticleData, pids = [1])
println(tree2)

t2 = octree(UnitlessParticleData, pids = [1])
println(t2)

tree3 = octree(AstroParticleData)
println(tree3)

t3 = octree(UnitlessParticleData)
println(t3)

d = randn_pvector(10)
t4 = octree(d, pids = [1])
t5 = octree(d)

#=
@everywhere workers() @show PhysicalTrees.registry[Pair(1,1)].data
@everywhere workers() @show length(PhysicalTrees.registry[Pair(1,1)].topnodes)
@everywhere workers() @show PhysicalTrees.registry[Pair(1,1)].DeleteIDs
@everywhere workers() @show PhysicalTrees.registry[Pair(1,1)].sendbuffer
@everywhere workers() @show PhysicalTrees.registry[Pair(1,1)].recvbuffer
@everywhere workers() @show PhysicalTrees.registry[Pair(1,1)].treenodes
@everywhere workers() @show length(PhysicalTrees.registry[Pair(1,1)].treenodes)
@everywhere workers() @show PhysicalTrees.registry[Pair(1,1)].MomentsToSend
@everywhere workers() @show length(PhysicalTrees.registry[Pair(1,1)].MomentsToSend)
=#
