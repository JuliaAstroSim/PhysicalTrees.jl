mutable struct OctreeNode2D{T<:Number, I<:Integer} <: AbstractOctreeNode2D{T}
    ID::I
    Father::I
    DaughterID::Array{I,1}
    Center::AbstractPoint2D
    SideLength::T
    Mass::T
    MassCenter::AbstractPoint2D
    MaxSoft::T
    SparseDaughterID::Array{Int64,1} # Walk in sparse tree to improve performance
    IsLeaf::Bool
    ParticleID::I # Refers to the particle or vector on this leaf.
                  # One leaf can only take one particle. Set 0 if none or more than 1

    NextNode::I
    Sibling::I
    BitFlag::I
end
OctreeNode2D() = OctreeNode2D(1, 0, [0,0,0,0], PVector2D(), 0.0, 0.0,
                        PVector2D(), 0.0, Array{Int64,1}(), true, 0, 0, 0, 0)

mutable struct OctreeNode{T<:Number, I<:Integer} <: AbstractOctreeNode3D{T}
    ID::I
    Father::I
    DaughterID::Array{I,1}
    Center::AbstractPoint3D
    SideLength::T
    Mass::T
    MassCenter::AbstractPoint3D
    MaxSoft::T
    SparseDaughterID::Array{Int64,1} # Walk in sparse tree to improve performance
    IsLeaf::Bool
    ParticleID::I # Refers to the particle or vector on this leaf.
                  # One leaf can only take one particle. Set 0 if none or more than 1

    NextNode::I
    Sibling::I
    BitFlag::I
end
OctreeNode() = OctreeNode(1, 0, [0,0,0,0,0,0,0,0], PVector(), 0.0, 0.0,
                        PVector(), 0.0, Array{Int64,1}(), true, 0, 0, 0, 0)

mutable struct TopNode{I<:Integer}
    Daughter::I
    Pstart::I
    Blocks::I
    Leaf::I
    Size::Int128
    StartKey::Int128
    Count::Int128
end
TopNode(;bits=21) = TopNode(-1, 1, 0, 0, Int128(1)<<(3*bits), Int128(0), Int128(0))

mutable struct PhysicalOctreeNode2D{I<:Integer} <: AbstractOctreeNode2D{I}
    ID::I
    Father::I
    DaughterID::Array{I,1}
    Center::AbstractPoint2D
    SideLength::Quantity
    Mass::Quantity
    MassCenter::AbstractPoint2D
    MaxSoft::Quantity
    SparseDaughterID::Array{I,1} # Walk in sparse tree to improve performance
    PDM_Mass::Quantity
    PDM_MassCenter::AbstractPoint2D
    IsLeaf::Bool
    ParticleID::I # Refers to the particle on this leaf.
                      # One leaf can only take one particle. Set 0 if none or more than 1

    NextNode::I
    Sibling::I
    BitFlag::I
end
PhysicalOctreeNode2D() = PhysicalOctreeNode2D(1, 0, [0,0,0,0,0,0,0,0], PVector(u"kpc"), 0.0u"kpc", 0.0u"Msun",
                        PVector(u"kpc"), 0.0u"kpc", Array{Int64,1}(), 0.0u"Msun", PVector(u"kpc"), true, 0, 0, 0, 0)

mutable struct PhysicalOctreeNode{I<:Integer} <: AbstractOctreeNode{I}
    ID::I
    Father::I
    DaughterID::Array{I,1}
    Center::AbstractPoint3D
    SideLength::Quantity
    Mass::Quantity
    MassCenter::AbstractPoint3D
    MaxSoft::Quantity
    SparseDaughterID::Array{I,1} # Walk in sparse tree to improve performance
    PDM_Mass::Quantity
    PDM_MassCenter::AbstractPoint3D
    IsLeaf::Bool
    ParticleID::I # Refers to the particle on this leaf.
                      # One leaf can only take one particle. Set 0 if none or more than 1

    NextNode::I
    Sibling::I
    BitFlag::I
end
PhysicalOctreeNode() = PhysicalOctreeNode(1, 0, [0,0,0,0,0,0,0,0], PVector(u"kpc"), 0.0u"kpc", 0.0u"Msun",
                        PVector(u"kpc"), 0.0u"kpc", Array{Int64,1}(), 0.0u"Msun", PVector(u"kpc"), true, 0, 0, 0, 0)

mutable struct DomainNode
    MassCenter::AbstractPoint
    Vel::AbstractPoint
    Mass::Quantity
    MaxSoft::Quantity
    BitFlag::Int64
end
DomainNode() = DomainNode(PVector(u"kpc"), PVector(u"kpc/Gyr"), 0.0u"Msun", 0.0u"kpc",0)

mutable struct ExtNode
    hmax::Quantity
    vs::AbstractPoint  # Center-of-mass velocity
end
ExtNode() = ExtNode(0.0u"kpc", PVector(u"kpc/Gyr"))