


function octree_type(p::AbstractPoint)
    TreeType = nothing
    NodeType = nothing
    if typeof(p) <: AbstractPoint3D
        if typeof(p.x) <: Quantity
            TreeType = PhysicalOctree
            NodeType = PhysicalOctreeNode
        else
            TreeType = Octree
            NodeType = OctreeNode
        end
    else
        if typeof(p.x) <: Quantity
            TreeType = PhysicalOctree2D
            NodeType = PhysicalOctreeNode2D
        else
            TreeType = Octree2D
            NodeType = OctreeNode2D
        end
    end
    return TreeType, NodeType
end

function octree_type(data::Array)
    p = nothing
    if typeof(data[1]) <: AbstractParticle
        p = data[1].Pos
    elseif typeof(data[1]) <: AbstractPoint
        p = data[1]
    else
        error("Unsupported data type!")
    end

    return octree_type(p)
end

function octree_type(data::Dict)
    p = nothing
    for v in values(data)
        if length(v) > 0
            p = v[1].Pos
        end
    end

    return octree_type(p)
end

"""
function split_data(data::Array, i::Int64, N::Int64)

    split data to N sections, return the ith section
"""
function split_data(data::Array, i::Int64, N::Int64)
    if length(data) == 0
        return similar(data)
    end

    len = length(data)
    if i <= len % N
        head = (i - 1) * (div(len, N) + 1) + 1
        return data[head : head + div(len, N) + 1]
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

    TreeType, NodeType = octree_type(data)

    for i in 1:length(worker)
        d = split_data(data, i, length(worker))
        @everywhere worker[i] const octree = init_tree($TreeType, $NodeType, $config, $e, $d, $worker)
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