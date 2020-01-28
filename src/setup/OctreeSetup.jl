function octree(data::Array{T,N},
               ;
               config = OctreeConfig(),
               pids = workers(),) where T <: Union{AbstractPoint,AbstractParticle,Dict} where N
    
    tree = init_octree(data, config, pids)

    @info "Spliting domain"
    split_domain(tree)

    @info "Building tree"
    build(tree)

    @info "Updating tree"
    update(tree)

    return tree
end