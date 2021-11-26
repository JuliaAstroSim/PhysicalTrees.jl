@testset "Parallelism" begin
    @test sum(procs(tree)) == sum(pids)

    sendto(tree, pids[1], :mutable, :last, 10)
    @test getfrom(tree, pids[1], :mutable, :last) == 10

    bcast(tree, :mutable, :last, 1)
    @test sum(gather(tree, :mutable, :last)) == 2

    bcast(tree, p->(p.mutable.last = 2))
    @test sum(gather(tree, x->x-1, :mutable, :last)) == 2

    scatterto(tree, [1, 2], :mutable, :last)
    @test sum(gather(tree, :mutable, :last)) == 3
    @test reduce(tree, max, :mutable, :last) == 2

    allreduce(tree, max, :mutable, :last, :last)
    allsum(tree, :mutable, :last, :last)
    @test sum(tree, :mutable, :last) == 8
end