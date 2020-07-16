summary(io::IO, tree::AbstractTree) = print(io, summary(tree))

function summary(tree::AbstractTree)
    return string(typeof(tree), " defined on worker ", tree.id.first,
             ":\n    Distributed on workers: ", tree.pids,
             "\n                     units: ", tree.units,
             "\n        Number of topnodes: ", tree.domain.NTopnodes,
             "\n       Number of topleaves: ", tree.domain.NTopLeaves,
             "\n             Domain factor: ", tree.domain.DomainFac,
             "\n         Domain start list: ", tree.domain.DomainStartList,
             "\n           Domain end list: ", tree.domain.DomainEndList,
             "\n                 Load list: ", tree.domain.list_load,
             "\n                 Work list: ", tree.domain.list_work,
             "\n      Number of tree nodes: ", gather(tree, :NTreenodes),
             "\n    ", tree.extent,
             "\n", datainfo(tree),
    )
end

Base.show(io::IO, tree::AbstractTree) = summary(io, tree)

function Base.show(io::IO, config::OctreeConfig)
    print(
        io,
        "\n  ----------------------- Config for Octrees: -----------------------",
        "\n    Toptree allocation section: ", config.ToptreeAllocSection,
        "\n                  Max Topnodes: ", config.MaxTopnode,
        "\n                Topnode Factor: ", config.TopnodeFactor,
        "\n       Tree allocation section: ", config.TreeAllocSection,
        "\n                Max Tree nodes: ", config.MaxTreenode,
        "\n                 Extent margin: ", config.ExtentMargin,
        "\n                 3D Peano bits: ", config.PeanoBits3D,
        "\n                 2D Peano bits: ", config.PeanoBits2D,
        "\n"
    )
end

function datainfo(tree::AbstractTree)
    local_to_go = gather(tree, :domain, :local_to_go)
    local_to_go_string = string([string(x, "\n                                ") for x in local_to_go]...)

    return string(
        "\n  -------------------------- Data info --------------------------",
        "\n                         total: ", tree.NumTotal,
        "\n                          type: ", typeof(tree.data),
        "\n                          cuts: ", gather(tree, :NumLocal),
        "\n              last communicate: ", local_to_go_string,
    )
end