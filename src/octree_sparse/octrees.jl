mutable struct DomainData{L, I, F, C, V, M, B}
    topnodes::Array{TopNode{I},1}
    NTopnodes::I
    NTopLeaves::I

    DomainFac::Number
    
    peano_keys::Array{Pair{Int128, Ref},1}

    StartKeys::Array{Int128,1}
    Counts::Array{Int128,1}

    DomainWork::Array{F,1}
    DomainCount::Array{I,1}
    DomainTask::Array{I,1}

    DomainStartList::Array{I,1}
    DomainEndList::Array{I,1}

    list_load::Array{I,1}
    list_work::Array{F,1}

    DomainMyStart::I
    DomainMyEnd::I

    DomainNodeIndex::Array{I,1}

    DomainMoment::Array{DomainNode{C, V, M, L, B},1}
    MomentsToSend::Array{DomainNode{C, V, M, L, B},1}

    local_to_go::Dict{I, I}
end

function DomainData(pids::Array{Int64,1}, units)
    return DomainData(
        Array{TopNode{Int64},1}(),
        1, 0,

        0.0,

        Array{Pair{Int128, Ref},1}(),

        Array{Int128,1}(),
        Array{Int128,1}(),

        Array{Float64,1}(),
        Array{Int64,1}(),
        Array{Int64,1}(),
        zeros(Int64, length(pids)),
        zeros(Int64, length(pids)),
        zeros(Int64, length(pids)),
        zeros(Float64, length(pids)),

        0,
        0,

        Array{Int64,1}(),

        fill(DomainNode(units), 0),
        fill(DomainNode(units), 0),

        Dict{Int64, Int64}(),
    )
end

mutable struct Octree{T, L, I, F, C, V, M, B} <: AbstractOctree3D{T}
    id::Pair{Int64,Int64}
    isholder::Bool

    units

    config::OctreeConfig
    extent::AbstractExtent3D

    data::T
    pids::Array{Int64,1}

    NumTotal::I
    NumLocal::I

    # Domain data
    domain::DomainData{L, I, F, C, V, M, B}

    # Tree
    treenodes::Array{OctreeNode{I, C, L, M},1}
    NTreenodes::I
    nextfreenode::I

    NextNodes::Array{I,1}
    ExtNodes::Array{ExtNode{L, V},1}
    last::I

    sendbuffer::Dict{Int64, Any}
    recvbuffer::Dict{Int64, Any}

    timers::Dict{String, UInt64}
end

function Octree(id::Pair{Int64,Int64}, isholder::Bool, units, config::OctreeConfig, extent::AbstractExtent3D, data, NumTotal::Int64, pids::Array{Int64,1})
    return Octree(
        id, isholder, units,
        config, extent, data, pids, NumTotal, 0,

        DomainData(pids, units),

        [OctreeNode(units) for i in 1:config.TreeAllocSection],
        0,
        0,

        [0 for i in 1:config.MaxTopnode],
        [ExtNode(units) for i in 1:config.MaxTreenode],
        0,

        Dict{Int64, Any}(),
        Dict{Int64, Any}(),

        Dict(
            "tree_domain" => UInt64(0),
            "tree_build"  => UInt64(0),
            "tree_update" => UInt64(0),
        )
    )
end

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