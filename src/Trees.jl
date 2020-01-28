mutable struct Octree2D{T<:Array} <: AbstractOctree2D{T}
    NodeType::UnionAll

    config::OctreeConfig

    extent::AbstractExtent2D

    data::T
    topnodes::Array{TopNode}
    nodes::Array{AbstractOctreeNode2D}

end

mutable struct Octree{T<:Array} <: AbstractOctree3D{T}
    NodeType::UnionAll

    config::OctreeConfig

    extent::AbstractExtent3D

    data::T
    topnodes::Array{TopNode}
    nodes::Array{AbstractOctreeNode}

end

mutable struct PhysicalOctree2D{T<:Array} <: AbstractOctree2D{T}
    NodeType::UnionAll

    config::OctreeConfig

    extent::AbstractExtent2D

    data::T
    topnodes::Array{TopNode}
    nodes::Array{AbstractOctreeNode2D}
end

mutable struct PhysicalOctree{T<:Array, I<:Integer} <: AbstractOctree3D{T}
    id::Pair{Int64,Int64}
    isholder::Bool

    config::OctreeConfig
    extent::AbstractExtent3D

    data::T
    pids::Array{Int64,1}
    NumTotal::Int64

    topnodes::Array{TopNode{I},1}
    nodes::Array{PhysicalOctreeNode{I},1}

    # Tree data
    DomainFac::Float64
    peano_keys::Array{Int128,1}

    NTopnodes::Int64
    NumLocal::Int64

    NTopLeaves::Int64
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

    sendbuffer::Any
    recvbuffer::Any
end
PhysicalOctree(id::Pair{Int64,Int64}, isholder::Bool, config::OctreeConfig, extent::AbstractExtent3D, data, NumTotal::Int64, pids::Array{Int64,1}) = PhysicalOctree(
    id, isholder,
    config, extent, data, pids, NumTotal,
    Array{TopNode{Int64},1}(),
    Array{PhysicalOctreeNode{Int64},1}(),

    # Tree Data
    0.0,
    Array{Int128,1}(),

    1,
    0,

    0,
    Array{Int128,1}(),
    Array{Int128,1}(),

    # Domain data
    Array{Float64,1}(),
    Array{Int64,1}(),
    Array{Int64,1}(),
    zeros(Int64, length(pids)),
    zeros(Int64, length(pids)),
    zeros(Int64, length(pids)),
    zeros(Float64, length(pids)),

    0,
    0,

    nothing,
    nothing,
)

function init_octree(id::Pair{Int64,Int64}, isholder::Bool, config::OctreeConfig, extent::AbstractExtent3D, data, NumTotal::Int64, pids::Array{Int64,1}, ::Physical3D)
    registry[id] = PhysicalOctree(id, isholder, config, extent, data, NumTotal, pids)
end

function append!()
end

function close()

end
