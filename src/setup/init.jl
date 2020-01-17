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
    sendto(worker, TreeType=TreeType, NodeType=NodeType)

    for i in 1:length(worker)
        d = split_data(data, i, length(worker))
        @everywhere worker[i] octree = TreeType(NodeType, $config, $e, $d,
                                                [TopNode() for k=1:$(config.ToptreeAllocSection)],
                                                [NodeType() for k=1:$(config.TreeAllocSection)])
    end
end

function clear_octree(octree::PhysicalOctree)
    octree.NTopLeavesLocal = 0
end