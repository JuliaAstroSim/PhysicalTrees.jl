summary(io, tree::AbstractTree) = print(io, summary(tree))

function summary(tree::AbstractTree)
    return string(
        "Tree defined on worker ", tree.id.first, ":\n    ",
             "Distributed on worker ", tree.pids, "\n    ",
             tree.extent, "\n    ",
             
    )
end

Base.show(io::IO, tree::AbstractTree) = summary(io, tree)



function datainfo(tree::AbstractTree)
    if typeof(tree.data) <: Array
        return string(
            "Number of Particles: ", gather(length, tree, :data)
        )
    else

    end
end