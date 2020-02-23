function octree(data::Array,
               ;
               units = uAstro,
               config = OctreeConfig(length(data)),
               pids = workers(),)

    tree = init_octree(data, units, config, pids)

    @info "Spliting domain"
    split_domain(tree)

    @info "Building tree"
    build(tree)

    @info "Updating tree"
    update(tree)

    return tree
end

function rebuild(tree::Octree)
    e = gather(tree, extent, :data)
    e.SideLength *= tree.config.ExtentMargin
    bcast(tree, :extent, e)
    tree.extent = e

    @info "Spliting domain"
    split_domain(tree)

    @info "Building tree"
    build(tree)

    @info "Updating tree"
    update(tree)
end