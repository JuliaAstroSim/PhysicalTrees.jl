struct OctreeConfig{I<:Integer, T<:AbstractFloat}
    ToptreeAllocSection::I
    MaxTopnode::I
    TopnodeFactor::Int64

    TreeAllocSection::I
    MaxTreeNode::I

    ExtentMargin::T

    PeanoBits3D::Int64
    PeanoBits2D::Int64

    units::Array
end

function OctreeConfig(
    NumParticles = 0,
    ;
    ToptreeAllocFactor = 0.3,
    ToptreeAllocSection = 256,
    MaxTopnode = 20000,
    TopnodeFactor = 20,

    TreeAllocFactor = 0.3,
    TreeAllocSection = 512,
    MaxTreeNode = 200000,

    ExtentMargin = 1.001,

    PeanoBits3D = 21,
    PeanoBits2D = 31,

    units = uAstro,
)

    return OctreeConfig(
        ToptreeAllocSection,
        MaxTopnode,
        TopnodeFactor,

        TreeAllocSection,
        MaxTreeNode,

        ExtentMargin,

        PeanoBits3D,
        PeanoBits2D,

        units,
    )
end