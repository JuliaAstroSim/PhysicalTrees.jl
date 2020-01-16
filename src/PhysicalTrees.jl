module PhysicalTrees

__precompile__(true)

using Unitful, UnitfulAstro
using Distributed, ParallelDataTransfer

using PhysicalParticles
#using SimulationProfiles

import Base: +, -, show, real, iterate, length, similar
import Unitful.Units

export
    # Base
    +, -, show, real, iterate, length, similar,

    # Configs
    OctreeConfig,

    # Tree node
    OctreeNode,

    # Tree
    Octree,

    # Setup
    setup

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