module PhysicalTrees

__precompile__(true)

using Unitful, UnitfulAstro
using Distributed, ParallelDataTransfer


import Base: +, -, show, real, iterate, length, similar
import Unitful.Units

using PhysicalParticles
import PhysicalParticles: extent
#using SimulationProfiles


export
    # Base
    +, -, show, real, iterate, length, similar,

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

    # Setup
    setup, 
    init_octree, octree_type, split_data, clear_octree

    abstract type AbstractTree{T} end
    abstract type AbstractTree2D{T} <: AbstractTree{T} end
    abstract type AbstractTree3D{T} <: AbstractTree{T} end

    @inline real(p::T) where T <: AbstractTree = p

    abstract type AbstractOctree{T} end
    abstract type AbstractOctree2D{T} <: AbstractOctree{T} end
    abstract type AbstractOctree3D{T} <: AbstractOctree{T} end

    @inline real(p::T) where T <: AbstractOctree = p

    abstract type AbstractOctreeNode{T} end
    abstract type AbstractOctreeNode2D{T} <: AbstractOctreeNode{T} end
    abstract type AbstractOctreeNode3D{T} <: AbstractOctreeNode{T} end

    @inline real(p::T) where T <: AbstractOctreeNode = p

    similar(d::Dict{T,S}) where T where S = Dict{T,S}()

    include("Config.jl")
    include("Peano.jl")
    include("TreeNodes.jl")
    include("Trees.jl")
    include("Iterators.jl")

    include("setup/extent.jl")
    include("setup/topnodes.jl")
    include("setup/init.jl")
    include("setup/OctreeSetup.jl")
end