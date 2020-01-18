mutable struct Octree2D{T<:Union{Array,Dict}} <: AbstractOctree2D{T}
    NodeType::UnionAll

    config::OctreeConfig

    extent::AbstractExtent2D

    data::T
    topnodes::Array{TopNode}
    nodes::Array{AbstractOctreeNode2D}

end

mutable struct Octree{T<:Union{Array,Dict}} <: AbstractOctree3D{T}
    NodeType::UnionAll

    config::OctreeConfig

    extent::AbstractExtent3D

    data::T
    topnodes::Array{TopNode}
    nodes::Array{AbstractOctreeNode}

end

mutable struct PhysicalOctree2D{T<:Union{Array,Dict}} <: AbstractOctree2D{T}
    NodeType::UnionAll

    config::OctreeConfig

    extent::AbstractExtent2D

    data::T
    topnodes::Array{TopNode}
    nodes::Array{AbstractOctreeNode2D}
end

mutable struct PhysicalOctree{T} <: AbstractOctree3D{T}
    NodeType::UnionAll

    config::OctreeConfig
    extent::AbstractExtent3D

    data::T
    worker::Array{Int64,1}

    topnodes::Array
    nodes::Array

    # Tree data
    DomainFac::Float64
    peano_keys::Array{Int128,1}
    key_points::Array{Any,2}
    
    NTopNodes::Int64
    NumLocal::Int64

    NTopLeaves::Int64
    NTopLeavesLocal::Int64
    StartKeys::Array{Int128,1}
    Counts::Array{Int128,1}

    # Domain data
    DomainWork::Array{Float64,1}
    DomainCount::Array{Int64,1}
    DomainTask::Array{Int64,1}
    DomainStartList::Array{Int64,1}
    DomainEndList::Array{Int64,1}
    list_load::Array{Int64,1}
    list_work::Array{Float64,1}

    DomainMyStart::Int64
    DomainMyEnd::Int64
end
PhysicalOctree(NodeType::UnionAll, config::OctreeConfig, extent::AbstractExtent3D, data, worker::Array{Int64,1}) = PhysicalOctree(
    NodeType, config, extent, data, worker,
    [TopNode() for i=1:config.ToptreeAllocSection],
    [NodeType() for i=1:config.TreeAllocSection],

    # Tree Data
    0.0,
    Array{Int128,1}(),
    [[] []],

    1,
    0,

    0,
    0,
    Array{Int128,1}(),
    Array{Int128,1}(),

    # Domain data
    Array{Float64,1}(),
    Array{Int64,1}(),
    Array{Int64,1}(),
    zeros(Int64, nprocs()),
    zeros(Int64, nprocs()),
    zeros(Int64, nprocs()),
    zeros(Float64, nprocs()),

    0,
    0,
)

function init_tree(TreeType::UnionAll, NodeType::UnionAll, config::OctreeConfig, extent::AbstractExtent3D, data, worker::Array{Int64,1})
    return TreeType(NodeType, config, extent, data, worker)
end

function append!()
end