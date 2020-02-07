@testset "Peano" begin
    @testset "Integer" begin
        # 2D
        @test peanokey(0,0; bits = 1) == 0
        @test peanokey(0,1; bits = 1) == 1
        @test peanokey(1,1; bits = 1) == 2
        @test peanokey(1,0; bits = 1) == 3

        @test peanokey(0,0; bits = 2) == 0
        @test peanokey(1,0; bits = 2) == 1
        @test peanokey(1,1; bits = 2) == 2
        @test peanokey(0,1; bits = 2) == 3
        @test peanokey(0,2; bits = 2) == 4
        @test peanokey(0,3; bits = 2) == 5
        @test peanokey(1,3; bits = 2) == 6
        @test peanokey(1,2; bits = 2) == 7
        @test peanokey(2,2; bits = 2) == 8
        @test peanokey(2,3; bits = 2) == 9
        @test peanokey(3,3; bits = 2) == 10
        @test peanokey(3,2; bits = 2) == 11
        @test peanokey(3,1; bits = 2) == 12
        @test peanokey(2,1; bits = 2) == 13
        @test peanokey(2,0; bits = 2) == 14
        @test peanokey(3,0; bits = 2) == 15

        @test peanokey(7,0; bits = 3) == 63
        @test peanokey(15,0; bits = 4) == 255
        @test peanokey(31,0; bits = 5) == 1023

        @test peanokey(1<<31-1, 0) == 1<<62-1

        # 3D
        @test peanokey(0,0,0; bits = 1) == 0
        @test peanokey(0,1,0; bits = 1) == 1
        @test peanokey(1,1,0; bits = 1) == 2
        @test peanokey(1,0,0; bits = 1) == 3
        @test peanokey(1,0,1; bits = 1) == 4
        @test peanokey(1,1,1; bits = 1) == 5
        @test peanokey(0,1,1; bits = 1) == 6
        @test peanokey(0,0,1; bits = 1) == 7

        @test peanokey(0,0,3; bits = 2) == 63
        @test peanokey(0,0,7; bits = 3) == 511
        @test peanokey(0,0,1<<21-1) == Int128(1)<<63 - 1
    end
end