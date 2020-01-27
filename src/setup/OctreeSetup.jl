function octree(data::Array{T,N},
               ;
               config = OctreeConfig(),
               pids = workers(),) where T <: Union{AbstractPoint,AbstractParticle,Dict} where N
    
    tree = init_octree(data, config, pids)
    split_domain(tree)
    build(tree)
    update(tree)

    return tree
end