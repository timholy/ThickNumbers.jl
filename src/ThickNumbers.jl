module ThickNumbers

using LinearAlgebra

export ThickNumber, FPTNException

# Traits
export valuetype, basetype

# These mimic IEEE Std 1788-2015, Table 9.2, but with `inf` and `sup`
# replaced by names that do not imply true bounds.
# (`inf` and `sup` have standard mathematical meanings)
# E.g., for Intervals, one could implement `inf(x) = loval(x)`,
# but for a Gaussian random variable, `inf` would be misleading
# (the true minimum of any Gaussian random variable is `-Inf`).
export lohi, midrad, loval, hival, mid, wid, rad, mag, mig

# Set operations
export emptyset, hull, issubset_tn, ⫃, is_strict_subset_tn, ⪽, issupset_tn, ⫄, is_strict_supset_tn, ⪾

# Operators
export isequal_tn, iseq_tn, ≐, isapprox_tn, ⩪, isless_tn, ≺, ≻, ⪯, ⪰

# Unary
export isfinite_tn, isinf_tn, isnan_tn

# Types

abstract type ThickNumber{T<:Number} <: Number end

struct FPTNException
    f
    frep

    FPTNException(@nospecialize(f), @nospecialize(frep=nothing)) = new(f, frep)
end

function Base.showerror(io::IO, err::FPTNException)
    print(io, "FPTNException: ", err.f, " is deliberately not implemented for ThickNumber objects (see documentation).")
    if err.frep !== nothing
        print(io,  "\nConsider using ", err.frep, " instead.")
    end
end

# Traits

"""
    valuetype(::Type{<:ThickNumber})

Return the type of the numbers in the span, i.e., the `T` in `ThickNumber{T}`.

# Examples

```julia
julia> valuetype(Interval{Float64})
Float64
```
"""
valuetype(::Type{TN}) where TN<:ThickNumber{T} where T = T
valuetype(x::ThickNumber) = valuetype(typeof(x))

# Functions that must be defined by subtypes

"""
    loval(x::ThickNumber)

The value representing the lower limit of the span of `x`.
`loval` must be implemented by any subtype of `ThickNumber`.

# Examples

```julia
julia> loval(Interval(1, 2))    # suppose Interval{T} <: ThickNumber{T}
1
```
"""
loval(x::ThickNumber) = error("loval not defined for $(typeof(x))")

"""
    hival(x::ThickNumber)

The value representing the upper limit of the span of `x`.
`hival` must be implemented by any subtype of `ThickNumber`.

# Examples

```julia
julia> hival(Interval(1, 2))    # suppose Interval{T} <: ThickNumber{T}
2
```
"""
hival(x::ThickNumber) = error("hival not defined for $(typeof(x))")


"""
    lohi(::Type{TN}, lo, hi) where TN<:ThickNumber

Construct a `TN` from its `lo` and `hi` values.

# Interface requirements

`lohi` must be implemented by all ThickNumber subtypes.

If

```julia
x = lohi(TN, lo, hi)
```

succeeds without throwing an error, then it is required that

```julia
typeof(x) <: TN
lo ∈ x
hi ∈ x
lo ≈ loval(x)
hi ≈ hival(x)
```

For the latter two, exact equality is not required; this allows for roundoff error (in case
`TN` is parametrized by something other than its `lo` and `hi` values) as well as outward
rounding for ThickNumber types that aim to be conservative and guarantee acccuracy even in
the presence of roundoff error.
"""
lohi(::Type{TN}, lo, hi) where TN<:ThickNumber = error("lohi not defined for $TN")

"""
    basetype(::Type{TN}) where TN<:ThickNumber

Strip the `valuetype` from `TN`.

# Interface requirements

`basetype` must be implemented by all ThickNumber subtypes.

# Examples

In a package implementing `Interval` you would define

```julia
ThickNumbers.basetype(::Type{Interval{T}}) where T = Interval
ThickNumbers.basetype(::Type{Interval}) = Interval
```

so that

```julia
julia> basetype(Interval{Float64})
Interval
```

This can be used to construct `valuetype`-agnostic ThickNumbers:

```julia
julia> lohi(basetype(Interval{Float64}), 1, 2))
Interval{$Int}(1, 2)
```
"""
basetype(::Type{TN}) where TN<:ThickNumber = error("basetype not defined for $TN")
basetype(x::ThickNumber) = basetype(typeof(x))

# Optional specializations

"""
    midrad(::Type{TN}, mid, rad) where TN<:ThickNumber

Construct a `TN` from its midpoint `mid` and radius `rad`.

# Interface requirements

If

```julia
x = midrad(TN, mid, rad)
```

succeeds without throwing an error and `rad >= 0`, then it is required that

```julia
typeof(x) <: TN
rad(x) >= rad && rad(x) ≈ rad
```

If `rad < 0`, then it is required that

```julia
typeof(x) <: TN
isempty(x)
```
"""
function midrad(::Type{TN}, mid, rad) where TN<:ThickNumber
    lo, hi = mid-rad, mid+rad
    T = isa(TN, DataType) ? valuetype(TN) : promote_type(typeof(lo), typeof(hi))
    if T <: AbstractFloat && hi >= lo
        rad′ = (hi - lo) / 2
        if rad′ < rad
            Δ = rad - rad′
            lo -= 2Δ
            hi += 2Δ
        end
    end
    return lohi(TN, lo, hi)
end
# Note: packages have to implement `midrad(::Type{TN}, mid, rad)` where `TN` is missing the `valuetype` parameter.

"""
    emptyset(::Type{TN}) where TN<:ThickNumber
    emptyset(x::ThickNumber)

Construct an "empty set" of type `TN`.

# Default implementation

The default implementation creates an empty set by making the `loval`
be bigger than the `hival`. Specifically, the default implementation is

    emptyset(::Type{TN}) where TN<:ThickNumber{T} where T = lohi(TN, typemax(T), typemin(T))

# Examples

```julia
julia> emptyset(Interval{Float64})
Interval{Float64}(Inf, -Inf)
```
"""
emptyset(::Type{TN}) where TN<:ThickNumber{T} where T = lohi(TN, typemax(T), typemin(T))
emptyset(x::ThickNumber) = emptyset(typeof(x))

# Derived exports

"""
    mid(x::ThickNumber)

The midpoint of the span of `x`. Required by IEEE Std 1788-2015, Table 9.2.

# Default implementation

The default implementation is

    mid(x::ThickNumber) = (loval(x) + hival(x))/2
"""
mid(x::ThickNumber) = (loval(x) + hival(x))/2

"""
    wid(x::ThickNumber)

The width of the span of `x`. Required by IEEE Std 1788-2015, Table 9.2.

# Default implementation

The default implementation is

    wid(x::ThickNumber) = hival(x) - loval(x)
"""
wid(x::ThickNumber) = hival(x) - loval(x)

"""
    rad(x::ThickNumber)

Half the width of the span of `x`. Required by IEEE Std 1788-2015, Table 9.2.

# Default implementation

The default implementation is

    rad(x::ThickNumber) = wid(x)/2
"""
rad(x::ThickNumber) = wid(x)/2

"""
    mag(x::ThickNumber)

The maximum absolute value of `x`. Required by IEEE Std 1788-2015, Table 9.2.

# Default implementation

The default implementation is

    mag(x::ThickNumber) = max(abs(loval(x)), abs(hival(x)))
"""
mag(x::ThickNumber) = max(abs(loval(x)), abs(hival(x)))

"""
    mig(x::ThickNumber)

The minimum absolute value of `x`. Required by IEEE Std 1788-2015, Table 9.2.

# Default implementation

The default implementation checks to see if the set contains zero, and if
so returns zero. Otherwise, it returns the minimum absolute value of the endpoints:

    mig(x::ThickNumber) = zero(T) ∈ x ? zero(T) : min(abs(loval(x)), abs(hival(x)))
"""
mig(x::ThickNumber{T}) where T = zero(T) ∈ x ? zero(T) : min(abs(loval(x)), abs(hival(x)))

Base.promote_rule(::Type{ThickNumber{T}}, ::Type{ThickNumber{S}}) where {T<:Number,S<:Number} = ThickNumber{promote_type(T,S)}

## Trait functions and constants

"""
    isfinite_tn(x::ThickNumber)

Returns `true` if all values in `x` are finite, `false` otherwise.
"""
isfinite_tn(a::ThickNumber) = isfinite(loval(a)) & isfinite(hival(a))
Base.isfinite(::ThickNumber) = throw(FPTNException(isfinite, isfinite_tn))

"""
    isinf_tn(x::ThickNumber)

Returns `true` if any value in `x` is infinite, `false` otherwise.
"""
isinf_tn(a::ThickNumber) = isinf(loval(a)) | isinf(hival(a))
Base.isinf(::ThickNumber) = throw(FPTNException(isinf, isinf_tn))

"""
    isnan_tn(x::ThickNumber)

Returns `true` if any value in `x` is NaN, `false` otherwise.
"""
isnan_tn(a::ThickNumber) = isnan(loval(a)) | isnan(hival(a))
Base.isnan(::ThickNumber) = throw(FPTNException(isnan, isnan_tn))


Base.typemin(::Type{TN}) where TN<:ThickNumber{T} where T<:Number = TN(typemin(T), typemin(T))
Base.typemax(::Type{TN}) where TN<:ThickNumber{T} where T<:Number = TN(typemax(T), typemax(T))
Base.typemin(x::ThickNumber) = typemin(typeof(x))
Base.typemax(x::ThickNumber) = typemax(typeof(x))

## Set operations

"""
    in(x::Real, a::ThickNumber)

Returns `true` if `x` is in the span of `a` (i.e., between `loval(a)` and `hival(a)`), `false` otherwise.
"""
function Base.in(x::Real, a::ThickNumber)
    # This is possibly dicey for "soft" ThickNumbers like Gaussian random variables
    isinf(x) && return false
    return loval(a) <= x <= hival(a)
end

"""
    issubset_tn(a::ThickNumber, b::ThickNumber)
    ⫃(a::ThickNumber, b::ThickNumber)

Returns `true` if `a` is a subset of `b`, `false` otherwise.

See documentation for why this is not just `⊆`
"""
function issubset_tn(a::ThickNumber, b::ThickNumber)
    isempty(a) && return true
    loval(b) ≤ loval(a) && hival(a) ≤ hival(b)
end
const ⫃ = issubset_tn
Base.issubset(::ThickNumber, ::ThickNumber) = throw(FPTNException("issubset (or ⊆)", "issubset_tn (or ⫃)"))

"""
    is_strict_subset_tn(a::ThickNumber, b::ThickNumber)
    ⪽(a::ThickNumber, b::ThickNumber)

Returns `true` if `a` is a strict subset of `b`, `false` otherwise.
`a` is a strict subset if `a` is a subset of `b` not equal to `b`.

See documentation for why this is not just `⊂`.
"""
function is_strict_subset_tn(a::ThickNumber, b::ThickNumber)
    a ≐ b && return false
    return issubset_tn(a, b)
end
const ⪽ = is_strict_subset_tn

"""
    issupset_tn(a::ThickNumber, b::ThickNumber)
    ⫄(a::ThickNumber, b::ThickNumber)

The converse of [`issubset_tn`](@ref).
"""
issupset_tn(a::ThickNumber, b::ThickNumber) = issubset_tn(b, a)
const ⫄ = issupset_tn
Base.:(⊇)(::ThickNumber, ::ThickNumber) = throw(FPTNException(⊇, ⫄))

"""
    is_strict_supset_tn(a::ThickNumber, b::ThickNumber)
    ⪾(a::ThickNumber, b::ThickNumber)

The converse of [`is_strict_subset_tn`](@ref).
"""
is_strict_supset_tn(a::ThickNumber, b::ThickNumber) = is_strict_subset_tn(b, a)
const ⪾ = is_strict_supset_tn

"""
    isempty(x::ThickNumber)

Returns `true` if `hival(x) < loval(x)` is empty, `false` otherwise.
"""
Base.isempty(x::ThickNumber) = hival(x) < loval(x)

function Base.isdisjoint(a::ThickNumber, b::ThickNumber)
    (isempty(a) || isempty(b)) && return true
    return hival(b) < loval(a) || hival(a) < loval(b)
end

function Base.intersect(a::TN, b::TN) where TN<:ThickNumber
    isdisjoint(a,b) && return emptyset(TN)
    TN(max(loval(a), loval(b)), min(hival(a), hival(b)))
end
Base.intersect(a::ThickNumber, b::ThickNumber) = intersect(promote(a, b)...)
Base.intersect(a::ThickNumber, b::ThickNumber, c::ThickNumber...) = intersect(intersect(a, b), c...)

"""
    hull(a::ThickNumber, b::ThickNumber, c::ThickNumber...)

Construct a `ThickNumber` containing `a`, `b`, and `c...`.
"""
hull(a::ThickNumber, b::ThickNumber, c::ThickNumber...) = hull(hull(a, b), c...)
hull(a::ThickNumber, b::ThickNumber) = hull(promote(a, b)...)
hull(a::TN, b::TN) where TN<:ThickNumber =
    TN(min(loval(a), loval(b)), max(hival(a), hival(b)))

## Operators

"""
    isequal_tn(a::ThickNumber, b::ThickNumber)

Returns `true` if `a` and `b` are both empty or both `loval` and `hival` are equal in the sense of `isequal`. It is `false` otherwise.
"""
isequal_tn(a::ThickNumber, b::ThickNumber) = (isempty(a) & isempty(b)) | (isequal(loval(a), loval(b)) & isequal(hival(a), hival(b)))
Base.isequal(::ThickNumber, ::ThickNumber) = throw(FPTNException(isequal, isequal_tn))
isequal_tn(a::ThickNumber, b::Number) = isequal(loval(a), hival(a)) & isequal(loval(a), b)
isequal_tn(a::Number, b::ThickNumber) = isequal_tn(b, a)

"""
    iseq_tn(a::ThickNumber, b::ThickNumber)
    a ≐ b  (`\\doteq`-TAB`)

Returns `true` if `a` and `b` are both empty or both `loval` and `hival` are equal in the sense of `==`. It is `false` otherwise.
"""
iseq_tn(a::ThickNumber, b::ThickNumber) = (isempty(a) & isempty(b)) | ((loval(a) == loval(b)) & (hival(a) == hival(b)))
iseq_tn(a::ThickNumber, b::Number) = loval(a) == hival(a) == b
iseq_tn(a::Number, b::ThickNumber) = iseq_tn(b, a)
const ≐ = iseq_tn
Base.:(==)(::ThickNumber, ::ThickNumber) = throw(FPTNException(==, "≐ (\\doteq-TAB) or iseq_tn"))

"""
    isapprox_tn(a::ThickNumber, b::ThickNumber; atol=0, rtol::Real=atol>0 ? 0 : √eps)
    a ⩪ b (`\\dotsim`-TAB)

Returns `true` if `a` and `b` are both empty or both `loval` and `hival` are approximately equal (≈). It is `false` otherwise.
"""
function isapprox_tn(x::ThickNumber, y::ThickNumber; atol::Real=0, rtol::Real=Base.rtoldefault(x,y,atol), nans::Bool=false)
    (isempty(x) & isempty(y)) && return true
    isequal_tn(x, y) || (isfinite_tn(x) && isfinite_tn(y) && max(abs(hival(x)-hival(y)), abs(loval(x)-loval(y))) <= max(atol, rtol*max(mag(x), mag(y)))) || (nans && isnan(x) && isnan(y))
end
isapprox_tn(x::ThickNumber, y::Number; kwargs...) = isapprox(loval(x), y; kwargs...) & isapprox(hival(x), y; kwargs...)
isapprox_tn(x::Number, y::ThickNumber; kwargs...) = isapprox_tn(y, x; kwargs...)
function Base.rtoldefault(::Union{TN1,Type{TN1}}, ::Union{TN2,Type{TN2}}, atol::Real) where {TN1<:ThickNumber,TN2<:ThickNumber}
    rtol = max(Base.rtoldefault(TN1),Base.rtoldefault(TN2))
    return atol > 0 ? zero(rtol) : rtol
end
Base.rtoldefault(::Type{TN}) where TN<:ThickNumber{T} where T = Base.rtoldefault(T)
const ⩪ = isapprox_tn
Base.isapprox(::ThickNumber, ::ThickNumber; kwargs...) = throw(FPTNException("isapprox (or ≈)", "isapprox_tn (or ⩪, \\dotsim-TAB)"))

function isapprox_tn(x::AbstractArray, y::AbstractArray;
    atol::Real=0,
    rtol::Real=Base.rtoldefault(LinearAlgebra.promote_leaf_eltypes(x),LinearAlgebra.promote_leaf_eltypes(y),atol),
    nans::Bool=false, norm::Function=_norm)
    function magnorm(x::AbstractArray)
        n = norm(x)
        return isa(n, ThickNumber) ? mag(n) : n
    end

    normx, normy = magnorm(x), magnorm(y)
    tol = max(atol, rtol*max(normx, normy))
    return mapreduce((a, b) -> isapprox_tn(a, b; atol=tol, nans=nans), &, x, y)
end
_norm(x::AbstractArray) = sqrt(sum(abs2, x))

"""
    isless_tn(a::ThickNumber, b::ThickNumber)

Returns `true` if `isless(hival(a), loval(b))`, `false` otherwise. See also [`≺`](@ref).
"""
isless_tn(a::ThickNumber, b::ThickNumber) = isless(hival(a), loval(b))
Base.isless(::ThickNumber, ::ThickNumber) = throw(FPTNException(isless, isless_tn))

"""
    a ≺ b

Returns `true` if `hival(a) < loval(b)`, `false` otherwise. Use `\\prec`-TAB to type.
"""
≺(a::ThickNumber, b::ThickNumber) = hival(a) < loval(b)
Base.:(<)(::ThickNumber, ::ThickNumber) = throw(FPTNException(<, "≺ (\\prec-TAB)"))

"""
    a ≻ b

Returns `true` if `loval(a) > hival(b)`, `false` otherwise. Use `\\succ`-TAB to type.
"""
≻(a::ThickNumber, b::ThickNumber) = hival(a) > loval(b)
Base.:(>)(::ThickNumber, ::ThickNumber) = throw(FPTNException(>, "≻ (\\succ-TAB)"))

"""
    a ≼ b

Returns `true` if `hival(a) ≤ loval(b)`, `false` otherwise. Use `\\preceq`-TAB to type.
"""
⪯(a::ThickNumber, b::ThickNumber) = hival(a) <= loval(b)
Base.:(<=)(::ThickNumber, ::ThickNumber) = throw(FPTNException(<=, "⪯ (\\preceq-TAB)"))

"""
    a ≽ b

Returns `true` if `loval(a) ≥ hival(b)`, `false` otherwise. Use `\\succeq`-TAB to type.
"""
⪰(a::ThickNumber, b::ThickNumber) = hival(a) >= loval(b)
Base.:(>=)(::ThickNumber, ::ThickNumber) = throw(FPTNException(>=, "⪰ (\\succeq-TAB)"))


## Unary + and -
Base.:(+)(a::ThickNumber) = a
Base.:(-)(a::TN) where TN<:ThickNumber = lohi(TN, -hival(a), -loval(a))
Base.:(-)(a::TN) where TN<:ThickNumber{T} where T<:Integer = lohi(TN,
    Base.Checked.checked_neg(hival(a)),
    Base.Checked.checked_neg(loval(a))
)

# Functions

Base.eps(::Type{TN}) where TN<:ThickNumber{T} where T = (e = eps(T); lohi(TN, e, e))
Base.eps(x::ThickNumber) = lohi(typeof(x), eps(mig(x)), eps(mag(x)))

Base.signbit(x::ThickNumber) = lohi(basetype(typeof(x)), signbit(hival(x)), signbit(loval(x)))

Base.abs(x::ThickNumber) = lohi(typeof(x), mig(x), mag(x))

Base.clamp(x::ThickNumber, lo::Real, hi::Real) = lohi(basetype(x), max(lo, loval(x)), min(hi, hival(x)))


end # module
