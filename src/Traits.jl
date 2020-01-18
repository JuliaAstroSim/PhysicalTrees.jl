abstract type AbstractTreeType end
struct Physical2D <: AbstractTreeType end
struct Physical3D <: AbstractTreeType end
struct Unitless2D <: AbstractTreeType end
struct Unitless3D <: AbstractTreeType end

treetype(p::AbstractParticle) = treetype(p.Pos, p.Pos.x)
treetype(p::AbstractPoint) = treetype(p, p.x)

treetype(::AbstractPoint2D, ::Number) = Unitless2D()
treetype(::AbstractPoint3D, ::Number) = Unitless3D()
treetype(::AbstractPoint2D, ::Quantity) = Physical2D()
treetype(::AbstractPoint3D, ::Quantity) = Physical3D()

treetype(a::Array) = treetype(a[1])

function treetype(data::Dict)
    for v in values(data)
        if length(v) > 0
            return treetype(p)            
        end
    end
    error("Empty data!")
end