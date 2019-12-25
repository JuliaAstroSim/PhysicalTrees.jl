mutable struct TopNode
    Daughter::Int64
    Pstart::Int64
    Blocks::Int64
    Leaf::Int64
    Size::Int128
    StartKey::Int128
    Count::Int128
end
TopNode(;NumLocal = 0, bits=21) = TopNode(-1, 1, 0, 0, Int128(1)<<Int128(3*bits), 0, NumLocal)

mutable struct PhysicalTreeNode
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