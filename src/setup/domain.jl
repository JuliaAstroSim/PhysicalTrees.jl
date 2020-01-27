function init_peano_topnodes(tree::PhysicalOctree)
    uLength = tree.config.units[1]
    tree.DomainFac = ustrip(Float64, uLength^-1, 1.0 / tree.extent.SideLength) * (1 << tree.config.PeanoBits3D)
    tree.peano_keys = peanokey(tree.data, tree.extent.Corner, tree.DomainFac, uLength, tree.config.PeanoBits3D)
    tree.NumLocal = datalength(tree.data)

    sortpeano(tree)
end

function init_topnodes(tree::PhysicalOctree)
    # Topnode
    tree.topnodes = [TopNode() for i=1:tree.config.ToptreeAllocSection]
    tree.NTopNodes = 1
    tree.topnodes[1].Count = tree.NumTotal
    tree.topnodes[1].Blocks = tree.NTopLeaves
end

function domain_topnode_split_local()
    
end

function domain_topnode_split()
    
end

function split_domain(tree::PhysicalOctree)
    init_peano_topnodes(tree)
    init_topnodes(tree)
end