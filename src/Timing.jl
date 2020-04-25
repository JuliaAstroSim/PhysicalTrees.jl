"""
function begin_timer(tree::AbstractTree, name::AbstractString)

    Begin the named timer, save time_ns() to it
"""
function begin_timer(tree::AbstractTree, name::AbstractString)
    tree.timers[name] = time_ns()
end

"""
function end_timer(tree::AbstractTree, name::AbstractString)

    End the named timer, save the timing in ns
"""
function end_timer(tree::AbstractTree, name::AbstractString)
    tree.timers[name] = time_ns() - tree.timers[name]
end