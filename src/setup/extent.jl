extent(data::Dict) = extent([extent(p) for p in values(data)])

function global_extent(pids::Array{Int64,1})
    @everywhere pids octree.extent = extent(octree.data)
    
end