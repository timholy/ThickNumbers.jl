module IntervalArith

using ThickNumbers

export Interval

# To avoid ambiguity with the ForwardDiff extension, it's easiest to be specific about the promotion of
# other Numbers against `Interval`
const BaseReals = Union{AbstractFloat, Integer, AbstractIrrational, Rational}

struct Interval{T<:Number} <: ThickNumber{T}
    lo::T
    hi::T
end
Interval(lo, hi) = Interval(promote(lo, hi)...)
Interval{T}(iv::Interval) where T = Interval{T}(iv.lo, iv.hi)
Interval{T}(x::Number) where T = Interval{T}(x, x)

ThickNumbers.loval(x::Interval) = x.lo
ThickNumbers.hival(x::Interval) = x.hi
ThickNumbers.lohi(::Type{I}, lo, hi) where I<:Interval = I(lo, hi)

# These are needed only for `Interval` and not `Interval{T}`
ThickNumbers.midrad(::Type{Interval}, mid::T, rad::T) where T = midrad(Interval{T}, mid, rad)
ThickNumbers.midrad(::Type{Interval}, mid, rad) = midrad(Interval, promote(mid, rad)...)

# Promotion of `valuetype`
Base.promote_rule(::Type{Interval{S}}, ::Type{Interval{T}}) where {S<:Number, T<:Number} = Interval{promote_type(T, S)}
Base.promote_rule(::Type{Interval{S}}, ::Type{T}) where {S<:Number, T<:BaseReals} = Interval{promote_type(T, S)}

# Very basic arithmetic needed for `norm` (this would be fleshed out in real applications)
Base.:+(x::Interval, y::Interval) = Interval(x.lo + y.lo, x.hi + y.hi)
Base.:/(x::Interval, y::Real) = Interval(x.lo / y, x.hi / y)
function Base.:*(x::Interval, y::Interval)
    T = typeof(zero(valuetype(x))*zero(valuetype(y)))
    (isempty(x) || isempty(y)) && return emptyset(Interval{T})
    v1, v2, v3, v4 = x.lo*y.lo, x.hi*y.lo, x.lo*y.hi, x.hi*y.hi
    v1, v2 = v1 > v2 ? (v2, v1) : (v1, v2)
    v3, v4 = v3 > v4 ? (v4, v3) : (v3, v4)
    return Interval(min(v1, v3), max(v2, v4))
end
Base.abs2(x::Interval) = Interval(mig(x)^2, mag(x)^2)
Base.sqrt(x::Interval) = Interval(sqrt(loval(x)), sqrt(hival(x)))

end # module IntervalArith
