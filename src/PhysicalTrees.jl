module PhysicalTrees

__precompile__(true)

using Reexport
using Unitful, UnitfulAstro
using Distributed
using StaticArrays
using BangBang
using StructArrays

import Base: +, -, show, real, iterate, length, append!, sum
import Unitful.Units
import Distributed: procs

@reexport using PhysicalParticles
import PhysicalParticles: extent

using ParallelOperations
import ParallelOperations: sendto, getfrom, bcast, scatterto, reduce, gather, allgather, allreduce, allsum

#using SimulationProfiles


export
    AbstractTree, AbstractTree2D, AbstractTree3D,
    AbstractOctree2D, AbstractOctree3D,
    AbstractOctreeNode, AbstractOctreeNode2D, AbstractOctreeNode3D,
    # Base
    +, -, show, real, iterate, length, sum,

    # Parallel
    procs, sendto, getfrom, bcast, scatterto, reduce, gather, allgather, allreduce, allsum,
    send_buffer,


    # Configs
    OctreeConfig,

    # Tree node
    OctreeNode,
    TopNode,
    DomainNode,
    ExtNode,

    # Tree
    Octree,
    extent, global_extent,

    # Peano
    peanokey,

    # Setup
    octree,
    rebuild, update_node_len,
    init_octree, split_data,
    redistribute,
    unregister

    abstract type AbstractTree{T} end
    abstract type AbstractTree2D{T} <: AbstractTree{T} end
    abstract type AbstractTree3D{T} <: AbstractTree{T} end

    @inline real(p::T) where T <: AbstractTree = p
    @inline length(p::T) where T <: AbstractTree = 1
    @inline iterate(p::T) where T <: AbstractTree = (p,nothing)
    @inline iterate(p::T,st) where T <: AbstractTree = nothing

    abstract type AbstractOctree2D{T} <: AbstractTree2D{T} end
    abstract type AbstractOctree3D{T} <: AbstractTree3D{T} end


    abstract type AbstractOctreeNode{T} end
    abstract type AbstractOctreeNode2D{T} <: AbstractOctreeNode{T} end
    abstract type AbstractOctreeNode3D{T} <: AbstractOctreeNode{T} end

    @inline real(p::T) where T <: AbstractOctreeNode = p
    @inline length(p::T) where T <: AbstractOctreeNode = 1

    include("Parallel.jl")
    include("Timing.jl")
    
    include("octree_sparse/config.jl")
    include("octree_sparse/peano.jl")
    include("octree_sparse/nodes.jl")
    include("octree_sparse/octrees.jl")
    include("octree_sparse/iterators.jl")

    include("octree_sparse/init.jl")
    include("octree_sparse/domain.jl")
    include("octree_sparse/build.jl")
    include("octree_sparse/update.jl")

    include("octree_sparse/setup.jl")
    #include("octree_sparse/search.jl")


    include("PrettyPrinting.jl")
    include("Analyse.jl")
end