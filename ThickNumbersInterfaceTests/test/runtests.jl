using ThickNumbersInterfaceTests
using ThickNumbers
using Test

const testdir = abspath(joinpath(@__DIR__, "testpackages"))
if testdir ∉ LOAD_PATH
    push!(LOAD_PATH, testdir)
end

using IntervalArith

@testset "Interface tests" begin
    ThickNumbersInterfaceTests.test_reserved()
    ThickNumbersInterfaceTests.test_required(Interval{Float64})
    ThickNumbersInterfaceTests.test_required(Interval, [Float32, Float64])
    ThickNumbersInterfaceTests.test_optional(Interval{Float64})
    ThickNumbersInterfaceTests.test_optional(Interval, [Float32, Float64])
end

filter!(LOAD_PATH) do path
    path != testdir
end
nothing
