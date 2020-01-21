struct OctreeConfig{I<:Integer, T<:AbstractFloat}
    ToptreeAllocSection::I
    MaxToptreeNode::I

    TreeAllocSection::I
    MaxTreeNode::I

    ExtentMargin::T
end

function OctreeConfig(
    NumParticles::Int64 = 0,
    ;
    ToptreeAllocFactor = 0.3,
    ToptreeAllocSection = 256,
    MaxToptreeNode = 20000,

    TreeAllocFactor = 0.3,
    TreeAllocSection = 512,
    MaxTreeNode = 200000,

    ExtentMargin = 1.001
)

    return OctreeConfig(
        ToptreeAllocSection,
        MaxToptreeNode,

        TreeAllocSection,
        MaxTreeNode,

        ExtentMargin,
    )
end