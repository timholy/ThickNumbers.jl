module ThickNumbersInterfaceTests

using ThickNumbers
using Test

"""
    test_reserved(T = Float64)

Check that packages *don't* define reserved functions like `isequal_tn` for ordinary numbers.
"""
function test_reserved(@nospecialize(T=Float64))
    @test_throws MethodError isequal_tn(T(1), T(1))
    @test_throws MethodError isapprox_tn(T(1), T(1))
    @test_throws MethodError isless_tn(T(1), T(2))
    @test_throws MethodError T(1) ≺ T(2)
    @test_throws MethodError T(2) ≻ T(1)
    @test_throws MethodError issubset_tn(T(1), T(1))
    @test_throws MethodError is_strict_subset_tn(T(1), T(1))
    @test_throws MethodError issupset_tn(T(1), T(1))
    @test_throws MethodError is_strict_supset_tn(T(1), T(1))
    @test_throws MethodError emptyset(T)
    @test_throws MethodError isfinite_tn(T(1))
    @test_throws MethodError isinf_tn(T(1))
    @test_throws MethodError isnan_tn(T(1))
end

function test_required(@nospecialize(TN), @nospecialize(Ts=nothing))
    lo, hi = 1/3, nextfloat(2/3)
    x = lohi(TN, lo, hi)
    @test typeof(x) <: TN
    @test lo ∈ x
    @test hi ∈ x
    @test lo ≈ loval(x)
    @test hi ≈ hival(x)
    if Ts !== nothing
        for T in Ts
            for (x, l, h) in ((lohi(TN{T}, lo, hi), lo, hi), (lohi(TN{T}, 1, 2.0), 1.0, 2.0))
                @test typeof(x) <: TN{T}
                @test valuetype(x) === valuetype(typeof(x)) === T
                @test T(l) ∈ x
                @test T(h) ∈ x
                @test T(l) ≈ loval(x)
                @test T(h) ≈ hival(x)
            end
        end
    end
end

function test_optional(@nospecialize(TN), @nospecialize(Ts=nothing))
    m, r = 1/2, 1/6
    x = midrad(TN, m, r)
    @test typeof(x) <: TN
    @test m ∈ x && m ≈ mid(x)
    @test r <= rad(x) && r ≈ rad(x)
    if isa(TN, UnionAll)
        x = midrad(TN, 1, 2.0)
        @test valuetype(x) === valuetype(typeof(x)) === Float64
    end
    if Ts !== nothing
        for T in Ts
            x = midrad(TN{T}, m, r)
            @test typeof(x) <: TN{T}
            @test valuetype(x) === valuetype(typeof(x)) === T
            @test T(m) ∈ x && T(m) ≈ mid(x)
            @test T(r) <= rad(x) && T(r) ≈ rad(x)
        end
    end
end

end # module ThickNumbersInterfaceTests
