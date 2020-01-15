mutable struct Octree
    len::Int64
    extent::AbstractExtent

    AppendLength::Int64
    MaxLength::Int64

    NumLeaves::Int64
    Nodes::Array{OctreeNode}
end

function append!()
end