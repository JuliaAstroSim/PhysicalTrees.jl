struct TopNode{I<:Integer}
    Daughter::I
    Pstart::Int128
    Blocks::Int128
    Leaf::I
    Size::Int128
    StartKey::Int128
    Count::Int128
end
TopNode(;bits=21) = TopNode(-1, Int128(1), Int128(0), 0, Int128(1)<<(3*bits), Int128(0), Int128(0))
@inline length(p::T) where T <: TopNode = 1

struct OctreeNode{I<:Integer, POS, LEN, MASS} <: AbstractOctreeNode{I}
    ID::I
    Father::I
    DaughterID::MVector{8,I}
    Center::POS
    SideLength::LEN
    Mass::MASS
    MassCenter::POS
    MaxSoft::LEN
    IsAssigned::Bool
    ParticleID::I # Refers to the particle on this leaf.
                      # One leaf can only take one particle. Set 0 if none or more than 1

    NextNode::I
    Sibling::I
    BitFlag::I
end

OctreeNode(::Nothing) = OctreeNode(1, 0, MVector{8}([0,0,0,0,0,0,0,0]), PVector(), 0.0, 0.0,
                        PVector(), 0.0, false, 0, 0, 0, 0)

function OctreeNode(u::Array)
    uLength = getuLength(u)
    uMass = getuMass(u)
    return OctreeNode(1, 0, MVector{8}([0,0,0,0,0,0,0,0]), PVector(uLength), 0.0uLength, 0.0uMass,
                        PVector(uLength), 0.0uLength, false, 0, 0, 0, 0)
end


struct DomainNode{POS, VEL, MASS, LEN, B}
    MassCenter::POS
    Vel::VEL
    Mass::MASS
    MaxSoft::LEN
    BitFlag::B # Int
end

DomainNode(::Nothing) = DomainNode(PVector(), PVector(), 0.0, 0.0, 0)

function DomainNode(u::Array)
    uLength = getuLength(u)
    uTime = getuTime(u)
    uMass = getuMass(u)
    DomainNode(PVector(uLength), PVector(uLength / uTime), 0.0uMass, 0.0uLength,0)
end


struct ExtNode{LEN, VEL}
    hmax::LEN
    vs::VEL  # Center-of-mass velocity
end
ExtNode(::Nothing, ::Nothing) = ExtNode(0.0, PVector())
ExtNode(uLength::Units, uVel::Units) = ExtNode(0.0 * uLength, PVector(uVel))