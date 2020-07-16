const registry=Dict{Pair{Int64, Int64},Any}()

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

getfrom(tree::AbstractTree, p::Int64, expr, mod::Module = PhysicalTrees) = getfrom(p, :(registry[$(tree.id)].$expr), mod)
getfrom(tree::AbstractTree, p::Int64, expr1, expr2, mod::Module = PhysicalTrees) = getfrom(p, :(registry[$(tree.id)].$expr1.$expr2), mod)
sendto(tree::AbstractTree, p::Int64, expr, data, mod::Module = PhysicalTrees) = sendto(p, :(registry[$(tree.id)].$expr), data, mod)
sendto(tree::AbstractTree, p::Int64, expr1, expr2, data, mod::Module = PhysicalTrees) = sendto(p, :(registry[$(tree.id)].$expr1.$expr2), data, mod)

bcast(tree::AbstractTree, expr, data, mod::Module = PhysicalTrees) = bcast(tree.pids, :(registry[$(tree.id)].$expr), data, mod)
bcast(tree::AbstractTree, expr1, expr2, data, mod::Module = PhysicalTrees) = bcast(tree.pids, :(registry[$(tree.id)].$expr1.$expr2), data, mod)
bcast(tree::AbstractTree, f::Function, expr, mod::Module = PhysicalTrees) = bcast(tree.pids, f, :(registry[$(tree.id)].$expr), mod)
bcast(tree::AbstractTree, f::Function, expr1, expr2, mod::Module = PhysicalTrees) = bcast(tree.pids, f, :(registry[$(tree.id)].$expr1.$expr2), mod)
bcast(tree::AbstractTree, f::Function, mod::Module = PhysicalTrees) = bcast(tree.pids, f, :(registry[$(tree.id)]), mod)

scatter(tree::AbstractTree, data::Array, expr, mod::Module = PhysicalTrees) = scatter(tree.pids, data, :(registry[$(tree.id)].$expr), mod)
scatter(tree::AbstractTree, data::Array, expr1, expr2, mod::Module = PhysicalTrees) = scatter(tree.pids, data, :(registry[$(tree.id)].$expr1.$expr2), mod)

reduce(tree::AbstractTree, f::Function, expr, mod::Module = PhysicalTrees) = reduce(f, tree.pids, :(registry[$(tree.id)].$expr), mod)
reduce(tree::AbstractTree, f::Function, expr1, expr2, mod::Module = PhysicalTrees) = reduce(f, tree.pids, :(registry[$(tree.id)].$expr1.$expr2), mod)

gather(tree::AbstractTree, expr, mod::Module = PhysicalTrees) = gather(tree.pids, :(registry[$(tree.id)].$expr), mod)
gather(tree::AbstractTree, expr1, expr2, mod::Module = PhysicalTrees) = gather(tree.pids, :(registry[$(tree.id)].$expr1.$expr2), mod)
gather(tree::AbstractTree, f::Function, expr, mod::Module = PhysicalTrees) = gather(f, tree.pids, :(registry[$(tree.id)].$expr), mod)
gather(tree::AbstractTree, f::Function, expr1, expr2, mod::Module = PhysicalTrees) = gather(f, tree.pids, :(registry[$(tree.id)].$expr1.$expr2), mod)
gather(tree::AbstractTree, f::Function, mod::Module = PhysicalTrees) = gather(f, tree.pids, :(registry[$(tree.id)]), mod)

function allgather(tree::AbstractTree, src_expr, target_expr = src_expr, mod::Module = PhysicalTrees)
    data = gather(tree, src_expr, mod)
    setfield!(tree, target_expr, data)
    bcast(tree, target_expr, data, mod)
end

function allreduce(tree::AbstractTree, f::Function, src_expr, target_expr = src_expr, mod::Module = PhysicalTrees)
    data = reduce(tree, f, src_expr, mod)
    setfield!(tree, target_expr, data)
    bcast(tree, target_expr, data, mod)
end

# Commonly used functions
sum(tree::AbstractTree, expr, mod::Module = PhysicalTrees) = sum(gather(tree, expr, mod))
function allsum(tree::AbstractTree, src_expr, target_expr = src_expr, mod::Module = PhysicalTrees)
    data = sum(tree, src_expr, mod)
    setfield!(tree, target_expr, data)
    bcast(tree, target_expr, data, mod)
end

"""
function split_data(data::Array, i::Int64, N::Int64)

    split data to N sections, return the ith section
"""
function split_data(data::Array, i::Int64, N::Int64)
    if i > N || i <= 0
        error("Wrong section index! 1 <= i <= N, i ∈ Integer")
    end

    if length(data) == 0
        return empty(data)
    end

    len = length(data)
    sec = div(len, N)
    if len % N == 0
        head = (i - 1) * sec + 1
        return data[head : head + sec - 1]
    else
        if i <= len % N
            head = (i - 1) * (sec + 1) + 1
            return data[head : head + sec] # add one element
        else
            head = len - (N - i + 1) * sec + 1 # from tail
            return data[head : head + sec - 1]
        end
    end
end

function split_data(data::Dict, i::Int64, N::Int64)
    d = empty(data)
    for key in keys(data)
        d[key] = split_data(data[key], i, N)
    end
    return d
end

extent(tree::AbstractTree) = return extent(tree.data)

function global_extent(tree::AbstractTree)
    es = gather(tree, extent)

    e = es[1]
    for i in es
        e = extent(e, i)
    end

    if isnothing(e)
        error("Got empty global data")
    end

    bcast(tree, :extent, e)
    tree.extent = e
end

function send_buffer(tree::AbstractTree)
    # Reduce communication blocking
    # Move myid to last
    src = myid()
    circpids = circshift(tree.pids, length(tree.pids) - findfirst(x->x==src, tree.pids))

    for target in circpids[1:end-1]
        tree.recvbuffer[target] = Distributed.remotecall_eval(PhysicalTrees, target, :(registry[$(tree.id)].sendbuffer[$src]))
    end
end