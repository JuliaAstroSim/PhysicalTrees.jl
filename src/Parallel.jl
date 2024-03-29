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
getfrom(tree::AbstractTree, p::Int64, expr1::Symbol, expr2::Symbol, mod::Module = PhysicalTrees) = getfrom(p, :(registry[$(tree.id)].$expr1.$expr2), mod)
getfrom(tree::AbstractTree, p::Int64, expr1::Symbol, expr2::Symbol, expr3::Symbol, mod::Module = PhysicalTrees) = getfrom(p, :(registry[$(tree.id)].$expr1.$expr2.$expr3), mod)
sendto(tree::AbstractTree, p::Int64, expr, data, mod::Module = PhysicalTrees) = sendto(p, :(registry[$(tree.id)].$expr), data, mod)
sendto(tree::AbstractTree, p::Int64, expr1::Symbol, expr2::Symbol, data, mod::Module = PhysicalTrees) = sendto(p, :(registry[$(tree.id)].$expr1.$expr2), data, mod)
sendto(tree::AbstractTree, p::Int64, expr1::Symbol, expr2::Symbol, expr3::Symbol, data, mod::Module = PhysicalTrees) = sendto(p, :(registry[$(tree.id)].$expr1.$expr2.$expr3), data, mod)

bcast(tree::AbstractTree, expr, data, mod::Module = PhysicalTrees) = bcast(tree.pids, :(registry[$(tree.id)].$expr), data, mod)
bcast(tree::AbstractTree, expr1::Symbol, expr2::Symbol, data, mod::Module = PhysicalTrees) = bcast(tree.pids, :(registry[$(tree.id)].$expr1.$expr2), data, mod)
bcast(tree::AbstractTree, expr1::Symbol, expr2::Symbol, expr3::Symbol, data, mod::Module = PhysicalTrees) = bcast(tree.pids, :(registry[$(tree.id)].$expr1.$expr2.$expr3), data, mod)
bcast(tree::AbstractTree, f::Function, expr, mod::Module = PhysicalTrees) = bcast(tree.pids, f, :(registry[$(tree.id)].$expr), mod)
bcast(tree::AbstractTree, f::Function, expr1::Symbol, expr2::Symbol, mod::Module = PhysicalTrees) = bcast(tree.pids, f, :(registry[$(tree.id)].$expr1.$expr2), mod)
bcast(tree::AbstractTree, f::Function, expr1::Symbol, expr2::Symbol, expr3::Symbol, mod::Module = PhysicalTrees) = bcast(tree.pids, f, :(registry[$(tree.id)].$expr1.$expr2.$expr3), mod)
bcast(tree::AbstractTree, f::Function, mod::Module = PhysicalTrees) = bcast(tree.pids, f, :(registry[$(tree.id)]), mod)

scatterto(tree::AbstractTree, data::Array, expr, mod::Module = PhysicalTrees) = scatterto(tree.pids, data, :(registry[$(tree.id)].$expr), mod)
scatterto(tree::AbstractTree, data::Array, expr1::Symbol, expr2::Symbol, mod::Module = PhysicalTrees) = scatterto(tree.pids, data, :(registry[$(tree.id)].$expr1.$expr2), mod)
scatterto(tree::AbstractTree, data::Array, expr1::Symbol, expr2::Symbol, expr3::Symbol, mod::Module = PhysicalTrees) = scatterto(tree.pids, data, :(registry[$(tree.id)].$expr1.$expr2.$expr3), mod)

reduce(tree::AbstractTree, f::Function, expr, mod::Module = PhysicalTrees) = reduce(f, tree.pids, :(registry[$(tree.id)].$expr), mod)
reduce(tree::AbstractTree, f::Function, expr1::Symbol, expr2::Symbol, mod::Module = PhysicalTrees) = reduce(f, tree.pids, :(registry[$(tree.id)].$expr1.$expr2), mod)
reduce(tree::AbstractTree, f::Function, expr1::Symbol, expr2::Symbol, expr3::Symbol, mod::Module = PhysicalTrees) = reduce(f, tree.pids, :(registry[$(tree.id)].$expr1.$expr2.$expr3), mod)

gather(tree::AbstractTree, expr, mod::Module = PhysicalTrees) = gather(tree.pids, :(registry[$(tree.id)].$expr), mod)
gather(tree::AbstractTree, expr1::Symbol, expr2::Symbol, mod::Module = PhysicalTrees) = gather(tree.pids, :(registry[$(tree.id)].$expr1.$expr2), mod)
gather(tree::AbstractTree, expr1::Symbol, expr2::Symbol, expr3::Symbol, mod::Module = PhysicalTrees) = gather(tree.pids, :(registry[$(tree.id)].$expr1.$expr2.$expr3), mod)
gather(tree::AbstractTree, f::Function, expr, mod::Module = PhysicalTrees) = gather(f, tree.pids, :(registry[$(tree.id)].$expr), mod)
gather(tree::AbstractTree, f::Function, expr1::Symbol, expr2::Symbol, mod::Module = PhysicalTrees) = gather(f, tree.pids, :(registry[$(tree.id)].$expr1.$expr2), mod)
gather(tree::AbstractTree, f::Function, expr1::Symbol, expr2::Symbol, expr3::Symbol, mod::Module = PhysicalTrees) = gather(f, tree.pids, :(registry[$(tree.id)].$expr1.$expr2.$expr3), mod)
gather(tree::AbstractTree, f::Function, mod::Module = PhysicalTrees) = gather(f, tree.pids, :(registry[$(tree.id)]), mod)

function allgather(tree::AbstractTree, src_expr::Symbol, target_expr::Symbol, mod::Module = PhysicalTrees)
    data = gather(tree, src_expr, mod)
    setfield!(tree, target_expr, data)
    bcast(tree, target_expr, data, mod)
end

function allgather(tree::AbstractTree, expr::Symbol, src_expr::Symbol, target_expr::Symbol, mod::Module = PhysicalTrees)
    data = gather(tree, expr, src_expr, mod)
    setfield!(getproperty(tree, expr), target_expr, data)
    bcast(tree, expr, target_expr, data, mod)
end

function allreduce(tree::AbstractTree, f::Function, src_expr::Symbol, target_expr::Symbol, mod::Module = PhysicalTrees)
    data = reduce(tree, f, src_expr, mod)
    setfield!(tree, target_expr, data)
    bcast(tree, target_expr, data, mod)
end

function allreduce(tree::AbstractTree, f::Function, expr::Symbol, src_expr::Symbol, target_expr::Symbol, mod::Module = PhysicalTrees)
    data = reduce(tree, f, expr, src_expr, mod)
    setfield!(getproperty(tree, expr), target_expr, data)
    bcast(tree, expr, target_expr, data, mod)
end

# Commonly used functions
sum(tree::AbstractTree, expr, mod::Module = PhysicalTrees) = sum(gather(tree, expr, mod))
sum(tree::AbstractTree, expr1::Symbol, expr2::Symbol, mod::Module = PhysicalTrees) = sum(gather(tree, expr1, expr2, mod))
sum(tree::AbstractTree, expr1::Symbol, expr2::Symbol, expr3::Symbol, mod::Module = PhysicalTrees) = sum(gather(tree, expr1, expr2, expr3, mod))
function allsum(tree::AbstractTree, src_expr::Symbol, target_expr::Symbol, mod::Module = PhysicalTrees)
    data = sum(tree, src_expr, mod)
    setfield!(tree, target_expr, data)
    bcast(tree, target_expr, data, mod)
end

function allsum(tree::AbstractTree, expr::Symbol, src_expr::Symbol, target_expr::Symbol, mod::Module = PhysicalTrees)
    data = sum(tree, expr, src_expr, mod)
    setfield!(getproperty(tree, expr), target_expr, data)
    bcast(tree, expr, target_expr, data, mod)
end

extent(tree::AbstractTree) = return extent(tree.data)

"""
    global_extent(tree::AbstractTree)

Compute global extent of all particles and broadcast the result.
"""
function global_extent(tree::AbstractTree)
    es = gather(tree, extent)

    e = es[1]
    for i in es
        e = extent(e, i)
    end

    if isnothing(e)
        error("Got empty global data")
    end

    SideLength = e.SideLength * tree.config.ExtentMargin
    e = setproperties!!(e, SideLength = SideLength, Corner = e.Center - PVector(SideLength, SideLength, SideLength) * 0.5)

    bcast(tree, :mutable, :extent, e)
    tree.mutable.extent = e
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

function clear_local()
    empty!(registry)
end

"""
    function clear(pids = procs())

Clear distributed memories in `PhysicalTrees.registry`
"""
function clear(pids = procs())
    bcast(pids, clear_local)
end