module MidRadArith

using ThickNumbers

export MidRad

# To avoid ambiguity with the ForwardDiff extension, it's easiest to be specific about the promotion of
# other Numbers against `MidRad`
const BaseReals = Union{AbstractFloat, Integer, AbstractIrrational, Rational}

"""
    MidRad(mid, rad)

A `ThickNumber` spanning `[mid-rad, mid+rad]`, stored by its midpoint and radius.

`MidRad` exists to exercise the generic code against a parametrization that is
*not* `(loval, hival)`: its two-argument constructor takes a radius where
`Interval`'s takes an upper bound. Generic code that builds a result by calling
the two-argument constructor with a span will therefore produce a wrong answer
for `MidRad` while still looking correct for `Interval`.
"""
struct MidRad{T<:Number} <: ThickNumber{T}
    mid::T
    rad::T
end
MidRad(mid, rad) = MidRad(promote(mid, rad)...)
MidRad{T}(x::MidRad) where T = MidRad{T}(x.mid, x.rad)
MidRad{T}(x::Number) where T = MidRad{T}(x, zero(x))

ThickNumbers.loval(x::MidRad) = x.mid - x.rad
ThickNumbers.hival(x::MidRad) = x.mid + x.rad

# Read the stored parametrization directly; recovering these from the span would
# round-trip through `mid ± rad` and can shrink the radius by an ulp, which
# `midrad` forbids (a radius may only err outward).
ThickNumbers.mid(x::MidRad) = x.mid
ThickNumbers.rad(x::MidRad) = x.rad
ThickNumbers.lohi(::Type{M}, lo, hi) where M<:MidRad = M((lo + hi)/2, (hi - lo)/2)
ThickNumbers.basetype(::Type{MidRad{T}}) where T = MidRad
ThickNumbers.basetype(::Type{MidRad}) = MidRad

# The natural parametrization: define it directly rather than round-tripping through `lohi`
ThickNumbers.midrad(::Type{MidRad{T}}, mid, rad) where T = MidRad{T}(mid, rad)
ThickNumbers.midrad(::Type{MidRad}, mid::T, rad::T) where T = MidRad{T}(mid, rad)
ThickNumbers.midrad(::Type{MidRad}, mid, rad) = midrad(MidRad, promote(mid, rad)...)

# The default empty set spans [typemax, typemin], whose midpoint is `NaN`; a negative
# radius is the representable way to make `hival < loval` in this parametrization.
ThickNumbers.emptyset(::Type{MidRad{T}}) where T = MidRad{T}(zero(T), -oneunit(T))

# Promotion of `valuetype`
Base.promote_rule(::Type{MidRad{S}}, ::Type{MidRad{T}}) where {S<:Number, T<:Number} = MidRad{promote_type(T, S)}
Base.promote_rule(::Type{MidRad{S}}, ::Type{T}) where {S<:Number, T<:BaseReals} = MidRad{promote_type(T, S)}

# Very basic arithmetic needed for `norm` (this would be fleshed out in real applications)
Base.:+(x::MidRad, y::MidRad) = MidRad(x.mid + y.mid, x.rad + y.rad)
Base.:/(x::MidRad, y::Real) = MidRad(x.mid / y, x.rad / abs(y))
function Base.:*(x::MidRad, y::MidRad)
    T = typeof(zero(valuetype(x))*zero(valuetype(y)))
    (isempty(x) || isempty(y)) && return emptyset(MidRad{T})
    v1, v2, v3, v4 = loval(x)*loval(y), hival(x)*loval(y), loval(x)*hival(y), hival(x)*hival(y)
    return lohi(MidRad, min(v1, v2, v3, v4), max(v1, v2, v3, v4))
end

Base.conj(x::MidRad{T}) where T = MidRad{T}(conj(x.mid), conj(x.rad))

end # module MidRadArith
