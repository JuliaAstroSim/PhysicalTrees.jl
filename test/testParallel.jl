@testset "Parallelism" begin
    pids = addprocs(4)

    # Initialize workers
    @everywhere pids using PhysicalTrees

    @everywhere pids x = myid()

    @testset "Gather" begin
        x = gather(pids, :x)
        @test sum(x) == sum(pids)

        m = reduce(max, pids, :x)
        @test last(pids) == m
    end

    rmprocs(pids)
end