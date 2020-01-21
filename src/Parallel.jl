const registry=Dict{Pair{Int64, Int64},Any}()
const sendlist=Dict{Expr, Tuple{Any, Pair{Int64,Int64}, Any}}()
const receivelist=Dict{Tuple{Any, Pair{Int64,Int64}, Any}}()

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

function map!(f::F, pids, tree::AbstractTree) where F
    asyncmap(pids) do p
        remotecall_fetch(p) do
            map!(f, tree)
        end
    end
    return tree
end

function map!(f::F, tree::AbstractTree) where F
    map!(f, tree.pids, tree)
end

function map!(f::F, pids, tree::AbstractTree, symbol::Symbol) where F
    asyncmap(pids) do p
        remotecall_fetch(p) do
            map!(f, getfield(tree, symbol))
        end
    end
    return tree
end

function map!(f::F, tree::AbstractTree, symbol::Symbol) where F
    map!(f, tree.pids, tree, symbol)
end

# Reduce

function Base.reduce(f::F, pids, tree::AbstractTree, symbol::Symbol) where F
    results = asyncmap(pids) do p
        remotecall_fetch(p) do
            return reduce(f, getfield(registry[$(tree.id)], symbol))
        end
    end
    return reduce(f, results)
end

function Base.reduce(f::F, tree::AbstractTree, symbol::Symbol) where F
    return reduce(f, tree.pids, tree, symbol)
end

function Base.reduce(f::F, pids, symbol::Symbol, mod = Main) where F
    results = asyncmap(pids) do p
        remotecall_fetch(p) do
            return reduce(f, Core.eval(mod, symbol))
        end
    end
    return reduce(f, results)
end

function Base.reduce(f::F, pids, symbol::Expr, mod = Main) where F
    results = asyncmap(pids) do p
        remotecall_fetch(p) do
            return reduce(f, Core.eval(mod, symbol))
        end
    end
    return reduce(f, results)
end

# Gather

function gather(pids, expr::Expr, mod=Main)
    results = asyncmap(pids) do p
        fetch(@spawnat(p, Core.eval(mod, expr)))
    end
    return results
end

function gather(pids, symbol::Symbol, mod=Main)
    results = asyncmap(pids) do p
        fetch(@spawnat(p, getfield(mod, symbol)))
    end
    return results
end

function movedata()
    
end

function movedatapool()
    
end