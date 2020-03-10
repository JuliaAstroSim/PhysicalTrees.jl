@testset "Parallelism" begin
    @test sum(procs(tree)) == sum(pids)

    sendto(tree, pids[1], :last, 10)
    @test getfrom(tree, pids[1], :last) == 10

    bcast(tree, :last, 1)
    @test sum(gather(tree, :last)) == 4

    bcast(tree, p->(p.last = 2))
    @test sum(gather(tree, x->x-1, :last)) == 4

    scatter(tree, [1, 2, 3, 4], :last)
    @test sum(gather(tree, :last)) == 10
    @test reduce(tree, max, :last) == 4

    allreduce(tree, max, :last)
    allsum(tree, :last)
    @test sum(tree, :last) == 64
end