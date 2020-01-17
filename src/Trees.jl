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

    #NTopLeavesLocal::Int64
    topnodes::Array

    nodes::Array

end

function append!()
end