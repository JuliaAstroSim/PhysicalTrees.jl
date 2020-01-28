function extent(tree::AbstractTree)
    if length(tree.pids) == 1
        return extent(tree.data)
    else
        if tree.isholder
            return reduce(extent, gather(tree, extent, :data))
        else
            return extent(tree.data)
        end
    end
end
