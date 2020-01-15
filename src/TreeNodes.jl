mutable struct OctreeNode{T<:Union{Number, Quantity}, I<:Integer} <: AbstractTreeNode2D
    ID::I
    Father::I
    DaughterID::Array{I,1}
    Center::AbstractPoint2D
    SideLength::Quantity
    Mass::Quantity
    MassCenter::AbstractPoint2D
    MaxSoft::Quantity
    SparseDaughterID::Array{Int64,1} # Walk in sparse tree to improve performance
    PDM_Mass::Quantity
    PDM_MassCenter::AbstractPoint2D
    IsLeaf::Bool
    ParticleID::I # Refers to the particle or vector on this leaf.
                  # One leaf can only take one particle. Set 0 if none or more than 1

    NextNode::I
    Sibling::I
    BitFlag::I
end

mutable struct TopOctreeNode{I<:Integer}
    Daughter::I
    Pstart::I
    Blocks::I
    Leaf::I
    Size::Int128
    StartKey::Int128
    Count::Int128
end
TopNode(;NumLocal = 0, bits=21) = TopNode(-1, 1, 0, 0, Int128(1)<<Int128(3*bits), 0, NumLocal)

mutable struct PhysicalOctreeNode
    ID::Int64
    Father::Int64
    DaughterID::Array{Int64,1}
    Center::AbstractPoint
    SideLength::Quantity
    Mass::Quantity
    MassCenter::AbstractPoint
    MaxSoft::Quantity
    SparseDaughterID::Array{Int64,1} # Walk in sparse tree to improve performance
    PDM_Mass::Quantity
    PDM_MassCenter::AbstractPoint
    IsLeaf::Bool
    ParticleID::Int64 # Refers to the particle on this leaf.
                      # One leaf can only take one particle. Set 0 if none or more than 1

    NextNode::Int64
    Sibling::Int64
    BitFlag::Int64
end
PhysicalTreeNode() = PhysicalTreeNode(1, 0, [0,0,0,0,0,0,0,0], PVector(u"kpc"), 0.0u"kpc", 0.0u"Msun",
                        PVector(u"kpc"), 0.0u"kpc", [], 0.0u"Msun", PVector(u"kpc"), true, 0, 0, 0, 0)

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