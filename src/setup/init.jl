"""
function split_data(data::Array, i::Int64, N::Int64)

    split data to N sections, return the ith section
"""
function split_data(data::Array, i::Int64, N::Int64)
    if i > N || i <= 0
        error("Wrong section index! 1 <= i <= N, i ∈ Integer")
    end

    if length(data) == 0
        return similar(data)
    end

    len = length(data)
    sec = div(len, N)
    if len % N == 0
        head = (i - 1) * sec + 1
        return data[head : head + sec - 1]
    else
        if i <= len % N
            head = (i - 1) * (sec + 1) + 1
            return data[head : head + sec] # add one element
        else
            head = len - (N - i + 1) * sec + 1 # from tail
            return data[head : head + sec - 1]
        end
    end
end

function split_data(data::Dict, i::Int64, N::Int64)
    d = Dict{Symbol,Array{T,1} where T}()
    for key in keys(data)
        d[key] = split_data(data[key], i, N)
    end
    return d
end

function init_octree(data::Union{Array,Dict}, config::OctreeConfig, worker::Array{Int64,1})
    e = extent(data)
    for i in 1:length(worker)
        d = split_data(data, i, length(worker))
        @everywhere worker[i] const octree = init_octree($config, $e, $d, $worker)
    end
end

function clear_octree(octree::PhysicalOctree)
    octree.topnodes = [TopNode() for i=1:octree.MaxToptreeNodes]

    octree.NTopLeaves = 0
    octree.NTopLeavesLocal = 0
    octree.StartKeys = Array{Int128,1}()
    octree.Counts = Array{Int128,1}()

    octree.DomainStartList = zeros(Int64, nprocs())
    octree.DomainEndList = zeros(Int64, nprocs())
    octree.list_load = zeros(Int64, nprocs())
    octree.list_work = zeros(Float64, nprocs())
end

function rebuild_octree()
    
end