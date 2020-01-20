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

function collect(pids, obj, mod=:Main)
    
end