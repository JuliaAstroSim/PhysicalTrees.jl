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
import ParallelOperations: bcast, scatter, reduce, gather, allgather, allreduce

#using SimulationProfiles


export
    # Base
    +, -, show, real, iterate, length, sum,

    # Parallel
    procs, bcast, scatter, reduce, gather, allgather, allreduce,

    # Traits
    treetype,
    Physical2D, Physical3D,
    Unitless2D, Unitless3D,

    # Configs
    OctreeConfig,

    # Tree node
    OctreeNode, OctreeNode2D,
    PhysicalOctreeNode, PhysicalOctreeNode2D,
    TopNode,
    DomainNode,
    ExtNode,

    # Tree
    Octree, Octree2D,
    PhysicalOctree, PhysicalOctree2D,

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

    include("Traits.jl")
    include("Parallel.jl")
    include("Config.jl")
    include("Peano.jl")
    include("TreeNodes.jl")
    include("Trees.jl")
    include("Iterators.jl")

    include("PrettyPrinting.jl")

    include("setup/extent.jl")
    include("setup/topnodes.jl")
    include("setup/init.jl")
    include("setup/domain.jl")
    include("setup/build.jl")
    include("setup/update.jl")
    include("setup/OctreeSetup.jl")

    include("Analyse.jl")
end