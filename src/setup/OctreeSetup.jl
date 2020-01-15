function setup(
    points::Array{T,N},
    ;
    config = OctreeConfig()
    worker = workers()
) where T<:AbstractPoint where N
    if length(worker) == 1
        ex = extent(data)
    else

    end

    
end

function setup(
    particles::Array{T,N},
    ; 
    config = OctreeConfig()
    worker = workers()
) where T<:AbstractParticle where N
    if length(worker) == 1

    else

    end
end

function setup(
    data::Dict,
    worker = workers()
    ;
)
    if length(worker) == 1

    else

    end
end
