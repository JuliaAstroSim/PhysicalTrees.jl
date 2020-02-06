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

AstroParticleData = [Star() for i in 1:6]
assign_points(AstroParticleData, :Pos, AstroPVectorData)

AstroPVectorData2D = [PVector(1.0, 1.0, u"kpc"), PVector(-1.0, -1.0, u"kpc"),
                      PVector(1.0, 0.0, u"kpc"), PVector(-1.0, 0.0, u"kpc"),
                      PVector(0.0, 0.0, u"kpc"), PVector(-1.0, 1.0, u"kpc")]

AstroParticleData2D = [Star2D() for i in 1:6]
assign_points(AstroParticleData2D, :Pos, AstroPVectorData2D)

UnitlessPVectorData = [PVector(1.0, 1.0, 1.0), PVector(-1.0, -1.0, -1.0),
                       PVector(1.0, 0.0, -1.0), PVector(-1.0, 0.0, 1.0),
                       PVector(0.0, 0.0, -1.0), PVector(-1.0, 0.0, 0.0)]

UnitlessParticleData = [Massless() for i in 1:6]
assign_points(UnitlessParticleData, :Pos, UnitlessPVectorData)

UnitlessPVectorData2D = [PVector(1.0, 1.0), PVector(-1.0, -1.0),
                         PVector(1.0, 0.0), PVector(-1.0, 0.0),
                         PVector(0.0, 0.0), PVector(-1.0, 1.0)]

UnitlessParticleData2D = [Massless2D() for i in 1:6]
assign_points(UnitlessParticleData2D, :Pos, UnitlessPVectorData2D)

@info "Building tree"

#! Test single first, since some error info could not be fetched from remote
tree1 = octree(AstroPVectorData, pids = [1])
t1 = octree(UnitlessPVectorData, pids = [1])

tree = octree(AstroPVectorData)
t = octree(UnitlessPVectorData)

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
