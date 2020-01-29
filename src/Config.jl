struct OctreeConfig{I<:Integer, T<:AbstractFloat}
    ToptreeAllocSection::I
    MaxTopnode::I
    TopnodeFactor::Int64

    TreeAllocSection::I
    MaxTreenode::I

    ExtentMargin::T

    PeanoBits3D::Int64
    PeanoBits2D::Int64

    units::Array

    MaxData::I
end

function OctreeConfig(
    NumParticles::Integer,
    ;
    ToptreeAllocFactor = 0.3,
    ToptreeAllocSection = 256,
    MaxTopnode = 2000,
    TopnodeFactor = 20,

    TreeAllocFactor = 0.3,
    TreeAllocSection = 256,
    MaxTreenode = 200000,

    ExtentMargin = 1.001,

    PeanoBits3D = 21,
    PeanoBits2D = 31,

    units = uAstro,

    MaxData = 10^(trunc(Int64, log10(NumParticles))+1)
)

    return OctreeConfig(
        ToptreeAllocSection,
        MaxTopnode,
        TopnodeFactor,

        TreeAllocSection,
        MaxTreenode,

        ExtentMargin,

        PeanoBits3D,
        PeanoBits2D,

        units,

        MaxData,
    )
end