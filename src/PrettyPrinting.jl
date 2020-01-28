summary(io::IO, tree::AbstractTree) = print(io, summary(tree))

function summary(tree::AbstractTree)
    return string(typeof(tree), " defined on worker ", tree.id.first,
             ":\n    Distributed on workers: ", tree.pids,
             "\n        Number of topnodes: ", tree.NTopnodes,
             "\n       Number of topleaves: ", tree.NTopLeaves,
             "\n             Domain factor: ", tree.DomainFac,
             "\n         Domain start list: ", tree.DomainStartList,
             "\n           Domain end list: ", tree.DomainEndList,
             "\n                 Load list: ", tree.list_load,
             "\n                 Work list: ", tree.list_work,
             "\n    ", tree.extent,
             "\n", datainfo(tree),
    )
end

Base.show(io::IO, tree::AbstractTree) = summary(io, tree)

function Base.show(io::IO, config::OctreeConfig)
    print(
        io,
        "Config for Octrees:",
        "\n    Toptree allocation section: ", config.ToptreeAllocSection,
        "\n                  Max Topnodes: ", config.MaxTopnode,
        "\n                Topnode Factor: ", config.TopnodeFactor,
        "\n       Tree allocation section: ", config.TreeAllocSection,
        "\n                Max Tree nodes: ", config.MaxTreeNode,
        "\n                 Extent margin: ", config.ExtentMargin,
        "\n                 3D Peano bits: ", config.PeanoBits3D,
        "\n                 2D Peano bits: ", config.PeanoBits2D,
        "\n                         units: ", config.units,
    )
end

function datainfo(tree::AbstractTree)
    return string(
        "Data info:",
        "\n   total: ", tree.NumTotal,
        "\n    type: ", typeof(tree.data),
        "\n    cuts: ", gather(tree, :NumLocal),
    )
end