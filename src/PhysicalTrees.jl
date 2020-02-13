module PhysicalTrees

__precompile__(true)

using Unitful, UnitfulAstro
using Distributed
using DataStructures


import Base: +, -, show, real, iterate, length, append!, sum
import Unitful.Units
import Distributed: procs

using PhysicalParticles
import PhysicalParticles: extent

using ParallelOperations
import ParallelOperations: sendto, getfrom, bcast, scatter, reduce, gather, allgather, allreduce, allsum

#using SimulationProfiles


export
    AbstractTree, AbstractTree2D, AbstractTree3D,
    AbstractOctree2D, AbstractOctree3D,
    AbstractOctreeNode, AbstractOctreeNode2D, AbstractOctreeNode3D,
    # Base
    +, -, show, real, iterate, length, sum,

    # Parallel
    procs, sendto, getfrom, bcast, scatter, reduce, gather, allgather, allreduce, allsum,


    # Configs
    OctreeConfig,

    # Tree node
    OctreeNode, OctreeNode2D,
    TopNode,
    DomainNode,
    ExtNode,

    # Tree
    Octree, Octree2D,

    # Peano
    peanokey,

    # Setup
    octree,
    init_octree, split_data,
    unregister_octree

    abstract type AbstractTree{T} end
    abstract type AbstractTree2D{T} <: AbstractTree{T} end
    abstract type AbstractTree3D{T} <: AbstractTree{T} end

    @inline real(p::T) where T <: AbstractTree = p
    @inline length(p::T) where T <: AbstractTree = 1

    abstract type AbstractOctree2D{T} <: AbstractTree2D{T} end
    abstract type AbstractOctree3D{T} <: AbstractTree3D{T} end


    abstract type AbstractOctreeNode{T} end
    abstract type AbstractOctreeNode2D{T} <: AbstractOctreeNode{T} end
    abstract type AbstractOctreeNode3D{T} <: AbstractOctreeNode{T} end

    @inline real(p::T) where T <: AbstractOctreeNode = p
    @inline length(p::T) where T <: AbstractOctreeNode = 1

    include("Parallel.jl")
    
    include("octree/config.jl")
    include("octree/peano.jl")
    include("octree/nodes.jl")
    include("octree/octrees.jl")
    include("octree/iterators.jl")

    include("octree/init.jl")
    include("octree/domain.jl")
    include("octree/build.jl")
    include("octree/update.jl")

    include("octree/setup.jl")
    include("octree/search.jl")


    include("PrettyPrinting.jl")
    include("Analyse.jl")
end