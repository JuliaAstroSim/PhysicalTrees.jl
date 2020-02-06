struct OctreeConfig{I<:Integer, T<:AbstractFloat}
    ToptreeAllocSection::I
    MaxTopnode::I
    TopnodeFactor::Int64

    TreeAllocSection::I
    MaxTreenode::I

    ExtentMargin::T

    PeanoBits3D::Int64
    PeanoBits2D::Int64

    NumDataFactor::I
    MaxData::I
    epsilon::Float64
end

function OctreeConfig(
    NumData::Integer,
    ;
    
    ToptreeAllocFactor::Int64 = 1,
    MaxTopnode = 2000,
    TopnodeFactor = 20,

    TreeAllocFactor::Int64 = 1,
    MaxTreenode = 200000,

    ExtentMargin = 1.001,

    PeanoBits3D = 21,
    PeanoBits2D = 31,

    NumDataFactor::Int64 = 1,
    epsilon = 1.0e-4,
)

    NumDataBase = 10^(trunc(Int64, log10(NumData)))
    if NumDataBase < 10
        NumDataBase = 10
    end

    ToptreeAllocSection = NumDataBase * ToptreeAllocFactor
    TreeAllocSection = NumDataBase * TreeAllocFactor

    MaxData = 10 * NumDataBase * NumDataFactor

    return OctreeConfig(
        ToptreeAllocSection,
        MaxTopnode,
        TopnodeFactor,

        TreeAllocSection,
        MaxTreenode,

        ExtentMargin,

        PeanoBits3D,
        PeanoBits2D,

        NumDataFactor,
        MaxData,
        epsilon,
    )
end