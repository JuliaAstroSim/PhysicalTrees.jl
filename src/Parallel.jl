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

bcast(tree::AbstractTree, expr, data, mod::Module = PhysicalTrees) = bcast(tree.pids, :(registry[$(tree.id)].$expr), data, mod)
bcast(tree::AbstractTree, f::Function, expr, mod::Module = PhysicalTrees) = bcast(tree.pids, f, :(registry[$(tree.id)].$expr), mod)
bcast(tree::AbstractTree, f::Function, mod::Module = PhysicalTrees) = bcast(tree.pids, f, :(registry[$(tree.id)]), mod)

scatter(tree::AbstractTree, data::Array, expr, mod::Module = PhysicalTrees) = scatter(tree.pids, data, :(registry[$(tree.id)].$expr), mod)

reduce(tree::AbstractTree, f::Function, expr, mod::Module = PhysicalTrees) = reduce(f, tree.pids, :(registry[$(tree.id)].$expr), mod)

gather(tree::AbstractTree, expr, mod::Module = PhysicalTrees) = gather(tree.pids, :(registry[$(tree.id)].$expr), mod)
gather(tree::AbstractTree, f::Function, expr, mod::Module = PhysicalTrees) = gather(tree.pids, f, :(registry[$(tree.id)].$expr), mod)

allgather(tree::AbstractTree, src_expr, mod::Module = PhysicalTrees) = allgather(tree.pids, :(registry[$(tree.id)].$src_expr), mod)
allgather(tree::AbstractTree, src_expr, targer_expr, mod::Module = PhysicalTrees) = allgather(tree.pids, :(registry[$(tree.id)].$src_expr), :(registry[$(tree.id)].$target_expr), mod)

allreduce(tree::AbstractTree, f::Function, src_expr, mod::Module = PhysicalTrees) = allreduce(f, tree.pids, :(registry[$(tree.id)].$src_expr), mod)
allreduce(tree::AbstractTree, f::Function, src_expr, target_expr, mod::Module = PhysicalTrees) = allreduce(f, tree.pids, :(registry[$(tree.id)].$src_expr), :(registry[$(tree.id)].$target_expr), mod)