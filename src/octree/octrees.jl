mutable struct Octree2D{T<:Array} <: AbstractOctree2D{T}
    NodeType::UnionAll

    config::OctreeConfig

    extent::AbstractExtent2D

    data::T
    topnodes::Array{TopNode}
    nodes::Array{AbstractOctreeNode2D}
end

mutable struct Octree{T<:Array, I<:Integer} <: AbstractOctree3D{T}
    id::Pair{Int64,Int64}
    isholder::Bool

    units

    config::OctreeConfig
    extent::AbstractExtent3D

    data::T
    pids::Array{Int64,1}
    NumTotal::Int64

    topnodes::Array{TopNode{I},1}

    # Tree data
    DomainFac::Number
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

    local_to_go::Dict{Int64, Int64}
    DeleteIDs::Array{Int64,1}

    # Tree
    DomainNodeIndex::Array{Int64,1}
    treenodes::Array{OctreeNode,1}
    NTreenodes::Int64
    nextfreenode::Int64

    DomainMoment::Array{DomainNode,1}
    NextNodes::Array{Int64,1}
    Fathers::Array{Int64,1}
    ExtNodes::Array{ExtNode,1}
    last::Int64

    MomentsToSend::Array{DomainNode,1}

    sendbuffer::Dict{Int64, Array{Any,1}}
    recvbuffer::Dict{Int64, Array{Any,1}}
end
Octree(id::Pair{Int64,Int64}, isholder::Bool, units, config::OctreeConfig, extent::AbstractExtent3D, data, NumTotal::Int64, pids::Array{Int64,1}) = Octree(
    id, isholder, units,
    config, extent, data, pids, NumTotal,
    Array{TopNode{Int64},1}(),

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

    Dict{Int64, Int64}(),
    Array{Int64,1}(),

    # Tree
    Array{Int64,1}(),
    Array{OctreeNode,1}(),
    0,
    0,

    Array{DomainNode,1}(),
    zeros(Int64, config.MaxData + config.MaxTopnode),
    zeros(Int64, config.MaxData),
    [ExtNode(units) for i in 1:config.MaxTreenode],
    0,

    Array{DomainNode,1}(),

    Dict{Int64, Array{Any,1}}(),
    Dict{Int64, Array{Any,1}}(),
)

function init_octree(id::Pair{Int64,Int64}, isholder::Bool, units, config::OctreeConfig, extent::AbstractExtent3D, data, NumTotal::Int64, pids::Array{Int64,1}, ::Physical3D)
    if isnothing(units)
        error("Please define units!")
    else
        registry[id] = Octree(id, isholder, units, config, extent, data, NumTotal, pids)
    end
end

function init_octree(id::Pair{Int64,Int64}, isholder::Bool, units, config::OctreeConfig, extent::AbstractExtent3D, data, NumTotal::Int64, pids::Array{Int64,1}, ::Unitless3D)
    registry[id] = Octree(id, isholder, nothing, config, extent, data, NumTotal, pids)
end

function append!()
end

function close()

end
