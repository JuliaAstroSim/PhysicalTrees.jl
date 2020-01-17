function setup(data::Array{T,N},
               ;
               config = OctreeConfig(),
               worker = workers(),) where T <: Union{AbstractPoint,AbstractParticle,Dict} where N
    
    init_octree(data, config, worker)


    
end