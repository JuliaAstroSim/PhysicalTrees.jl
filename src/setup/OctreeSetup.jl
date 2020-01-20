function setup(data::Array{T,N},
               ;
               config = OctreeConfig(),
               pids = workers(),) where T <: Union{AbstractPoint,AbstractParticle,Dict} where N
    
    tree = init_octree(data, config, pids)


    return tree
end