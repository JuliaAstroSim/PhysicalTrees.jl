const registry=Dict{Pair{Int64, Int64},Any}()
const sendlist=Dict()
const receivelist=Dict()

let DID::Int = 1
    global next_treeid
    next_treeid() = (id = DID; DID += 1; Pair(myid(), id))
end

"""
    next_treeid()

Produces an incrementing ID that will be used for trees.
"""
next_treeid

procs(tree::AbstractTree) = tree.pids

# Map

function map!(f::Function, pids::Array{Integer}, tree::AbstractTree)
    asyncmap(pids) do p
        remotecall_fetch(p) do
            map!(f, tree)
        end
    end
    return tree
end

function map!(f::Function, tree::AbstractTree)
    map!(f, tree.pids, tree)
end

function map!(f::Function, pids::Array{Integer}, tree::AbstractTree, symbol::Symbol)
    asyncmap(pids) do p
        remotecall_fetch(p) do
            map!(f, getfield(tree, symbol))
        end
    end
    return tree
end

function map!(f::Function, tree::AbstractTree, symbol::Symbol)
    map!(f, tree.pids, tree, symbol)
end

# Reduce

function Base.reduce(f::Function, pids::Array, symbol::Symbol, mod = PhysicalTrees)
    results = asyncmap(pids) do p
        remotecall_fetch(p) do
            return reduce(f, Core.eval(mod, symbol))
        end
    end
    return reduce(f, results)
end

function Base.reduce(f::Function, pids::Array, expr::Expr, mod = PhysicalTrees)
    results = asyncmap(pids) do p
        remotecall_fetch(p) do
            return reduce(f, Core.eval(mod, expr))
        end
    end
    return reduce(f, results)
end

function Base.reduce(f::Function, tree::AbstractTree, symbol::Symbol, mod = PhysicalTrees)
    return reduce(f, tree.pids, :(registry[$(tree.id)].$symbol), mod)
end

# Gather

function gather(pids::Array, expr::Expr, mod=PhysicalTrees)
    results = asyncmap(pids) do p
        fetch(@spawnat(p, Core.eval(mod, expr)))
    end
    return results
end

function gather(pids::Array, symbol::Symbol, mod=PhysicalTrees)
    results = asyncmap(pids) do p
        fetch(@spawnat(p, getfield(mod, symbol)))
    end
    return results
end

gather(f::Function, pids::Array{Integer}, expr::Expr, mod=PhysicalTrees) = gather(pids, :($f($expr)), mod)
gather(f::Function, pids::Array{Integer}, symbol::Symbol, mod=PhysicalTrees) = gather(pids, :($f($symbol)), mod)

gather(tree::AbstractTree, symbol::Symbol, mod = PhysicalTrees) = gather(tree.pids, :(registry[$(tree.id)].$symbol), mod)
gather(f::Function, tree::AbstractTree, symbol::Symbol, mod = PhysicalTrees) = gather(tree.pids, :($f(registry[$(tree.id)].$symbol)), mod)

function movedata()
    
end

function movedatapool()
    
end