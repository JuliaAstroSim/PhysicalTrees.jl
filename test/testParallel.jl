@testset "Parallelism" begin
    @test sum(procs(tree)) == sum(pids)

    sendto(tree, pids[1], :last, 10)
    @test getfrom(tree, pids[1], :last) == 10

    bcast(tree, :last, 1)
    @test sum(gather(tree, :last)) == 2

    bcast(tree, p->(p.last = 2))
    @test sum(gather(tree, x->x-1, :last)) == 2

    scatterto(tree, [1, 2], :last)
    @test sum(gather(tree, :last)) == 3
    @test reduce(tree, max, :last) == 2

    allreduce(tree, max, :last)
    allsum(tree, :last)
    @test sum(tree, :last) == 8
end