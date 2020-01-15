struct OctreeConfig{T<:Integer}
    ToptreeAllocSection::T
    MaxToptreeNode::T

    TreeAllocSection::T
    MaxTreeNode::T
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
)

    return OctreeConfig(
        ToptreeAllocSection,
        MaxToptreeNode,

        TreeAllocSection,
        MaxTreeNode
    )
end