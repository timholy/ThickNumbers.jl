using ThickNumbers
using Test

const interfacetestsdir = abspath(joinpath(dirname(@__DIR__), "ThickNumbersInterfaceTests"))
const testpackagesdir = joinpath(interfacetestsdir, "test", "testpackages")

if testpackagesdir ∉ LOAD_PATH
    push!(LOAD_PATH, testpackagesdir)
end

using IntervalArith

@testset "ThickNumbers generics" begin
    # Test all the operations defined in ThickNumbers
    @test isequal_tn(Interval(1, 2), Interval(1, 2))
    @test_throws FPTNException isequal(Interval(1, 2), Interval(1, 2))
    @test !isequal_tn(Interval(1, 2), Interval(1, 3))
    @test Interval(1, 2) ≐ Interval(1, 2)
    @test_throws FPTNException Interval(1, 2) == Interval(1, 2)
    @test isapprox_tn(Interval(1, 2), Interval(1, nextfloat(2.0)))
    @test Interval(1, 2) ⩪ Interval(1, nextfloat(2.0))
    @test_throws FPTNException Interval(1, 2) ≈ Interval(1, nextfloat(2.0))
    @test !isapprox_tn(Interval(1, 2), Interval(1, 2.1))
    @test isless_tn(Interval(1, 2), Interval(nextfloat(2.0), 3))
    @test_throws FPTNException isless(Interval(1, 2), Interval(nextfloat(2.0), 3))
    @test Interval(1, 2) ≺ Interval(nextfloat(2.0), 3)
    @test_throws FPTNException Interval(1, 2) < Interval(nextfloat(2.0), 3)
    @test Interval(nextfloat(2.0), 3) ≻ Interval(1, 2)
    @test_throws FPTNException Interval(nextfloat(2.0), 3) > Interval(1, 2)
    @test !isless_tn(Interval(1, 2), Interval(1, 2))
    @test !isless_tn(Interval(1, 2), Interval(2, 3))
    @test issubset_tn(Interval(1, 2), Interval(1, 2))
    @test Interval(1, 2) ⫃ Interval(1, 2)
    @test_throws FPTNException issubset(Interval(1, 2), Interval(1, 2))
    @test issubset_tn(Interval(1, 2), Interval(0, 3))
    @test !issubset_tn(Interval(1, 2), Interval(0, 1))
    @test is_strict_subset_tn(Interval(1, 2), Interval(0, 3))
    @test !is_strict_subset_tn(Interval(1, 2), Interval(1, 2))
    @test issupset_tn(Interval(1, 2), Interval(1, 2))
    @test_throws FPTNException Interval(1, 2) ⊇ Interval(1, 2)
    @test issupset_tn(Interval(0, 3), Interval(1, 2))
    @test !issupset_tn(Interval(0, 1), Interval(1, 2))
    @test is_strict_supset_tn(Interval(0, 3), Interval(1, 2))
    @test !is_strict_supset_tn(Interval(1, 2), Interval(1, 2))
    # isdisjoint
    @test isdisjoint(Interval(1, 2), Interval(3, 4))
    @test !isdisjoint(Interval(1, 2), Interval(2, 3))
    @test !isdisjoint(Interval(1, 2), Interval(1, 2))
    # hull
    @test hull(Interval(1, 2), Interval(3, 4)) === Interval(1, 4)
    @test hull(Interval(1, 2), Interval(2, 3)) === Interval(1, 3)
    @test hull(Interval(1, 2), Interval(1, 2)) === Interval(1, 2)
    # intersect
    @test intersect(Interval(1, 2), Interval(3, 4)) === emptyset(Interval{Int})
    @test intersect(Interval(1, 2), Interval(2, 3)) === Interval(2, 2)
    @test emptyset(Interval{Float32}) === Interval(Inf32, -Inf32)
    @test emptyset(Interval{Float64}) === Interval(Inf, -Inf)
    @test isfinite_tn(Interval(1, 2))
    @test_throws FPTNException isfinite(Interval(1, 2))
    @test !isfinite_tn(Interval(1, Inf))
    @test !isfinite_tn(Interval(-Inf, 2))
    @test !isfinite_tn(Interval(-Inf, Inf))
    @test isinf_tn(Interval(1, Inf))
    @test_throws FPTNException isinf(Interval(1, Inf))
    @test isinf_tn(Interval(-Inf, 2))
    @test isinf_tn(Interval(-Inf, Inf))
    @test !isinf_tn(Interval(1, 2))
    @test isnan_tn(Interval(NaN, 2))
    @test_throws FPTNException isnan(Interval(NaN, 2))
    @test isnan_tn(Interval(1, NaN))
    @test isnan_tn(Interval(NaN, NaN))
    @test !isnan_tn(Interval(1, 2))
    @test !isnan_tn(Interval(1, Inf))

    x = Interval(1.0, 3.0)
    @test valuetype(x) === valuetype(typeof(x)) === Float64
    @test typemin(x) ≐ Interval(-Inf, -Inf)
    @test typemax(x) ≐ Interval(Inf, Inf)

    @test x ≐ +x
    @test -x ≐ Interval(-3.0, -1.0)
    y = Interval(0x00, 0xff)
    @test_throws OverflowError -y
end

filter!(LOAD_PATH) do path
    path != testpackagesdir && path != interfacetestsdir
end
nothing
