using ThickNumbers
using ForwardDiff
using Test

include(joinpath(dirname(@__DIR__), "setpath.jl"))

using IntervalArith

@testset "ForwardDiff extension" begin
    @test isempty(detect_ambiguities(ThickNumbers))
    @test isempty(detect_ambiguities(IntervalArith))

    a, b = Interval(1, 2), Interval(0, 0.1)
    f1(t) = a + t*b
    f2(x) = a + abs2(x)/2

    df1(t) = ForwardDiff.derivative(f1, t)
    df2(x) = ForwardDiff.derivative(f2, x)
    @test df1(0.5) ≐ b
    @test df2(b) ⩪ b
    ddf2(x) = ForwardDiff.derivative(df2, x)
    @test ddf2(b) ≐ 1
end
