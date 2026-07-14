using ThickNumbersInterfaceTests
using ThickNumbers
using Test

const testdir = abspath(joinpath(@__DIR__, "testpackages"))
if testdir ∉ LOAD_PATH
    push!(LOAD_PATH, testdir)
end

using IntervalArith
using MidRadArith

@testset "Interface tests" begin
    ThickNumbersInterfaceTests.test_reserved()
    ThickNumbersInterfaceTests.test_required(Interval{Float64})
    ThickNumbersInterfaceTests.test_required(Interval, [Float32, Float64])
    ThickNumbersInterfaceTests.test_optional(Interval{Float64})
    ThickNumbersInterfaceTests.test_optional(Interval, [Float32, Float64])
    ThickNumbersInterfaceTests.test_FPTNviolations(Interval(1.0, 2.0))

    # `MidRad` is parametrized by midpoint and radius rather than by lo/hi
    ThickNumbersInterfaceTests.test_required(MidRad{Float64})
    ThickNumbersInterfaceTests.test_required(MidRad, [Float32, Float64])
    ThickNumbersInterfaceTests.test_optional(MidRad{Float64})
    ThickNumbersInterfaceTests.test_optional(MidRad, [Float32, Float64])
    ThickNumbersInterfaceTests.test_FPTNviolations(MidRad(1.5, 0.5))
end

filter!(LOAD_PATH) do path
    path != testdir
end
nothing
