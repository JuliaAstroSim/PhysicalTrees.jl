@testset "Parallelism" begin
    @test sum(procs(tree)) == sum(pids)

    sendto(tree, pids[1], :last, 10)
    @test getfrom(tree, pids[1], :last) == 10

end