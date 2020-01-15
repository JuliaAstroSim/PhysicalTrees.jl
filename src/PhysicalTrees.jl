module PhysicalTrees

__precompile__(true)

using Unitful, UnitfulAstro
using Distributed

using PhysicalParticles
#using SimulationProfiles

import Base: +, -, show, real, iterate, length

export
    # Base
    +, -, show, real, iterate, length,

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

    abstract type AbstractTreeNode{T} end
    abstract type AbstractTreeNode2D{T} <: AbstractTreeNode{T} end
    abstract type AbstractTreeNode3D{T} <: AbstractTreeNode{T} end

    @inline real(p::T) where T <: AbstractTreeNode = p

    include("Config.jl")
    include("Peano.jl")
    include("TreeNodes.jl")
    include("Trees.jl")
    include("Iterators.jl")
    include("setup/extent.jl")
    include("setup/OctreeSetup.jl")
end