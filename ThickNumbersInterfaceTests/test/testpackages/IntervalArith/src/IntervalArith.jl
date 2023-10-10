module IntervalArith

using ThickNumbers

export Interval

struct Interval{T} <: ThickNumber{T}
    lo::T
    hi::T
end
Interval(lo, hi) = Interval(promote(lo, hi)...)
Interval{T}(iv::Interval) where T = Interval{T}(iv.lo, iv.hi)

ThickNumbers.loval(x::Interval) = x.lo
ThickNumbers.hival(x::Interval) = x.hi
ThickNumbers.lohi(::Type{I}, lo, hi) where I<:Interval = I(lo, hi)

# These are needed only for `Interval` and not `Interval{T}`
ThickNumbers.midrad(::Type{Interval}, mid::T, rad::T) where T = midrad(Interval{T}, mid, rad)
ThickNumbers.midrad(::Type{Interval}, mid, rad) = midrad(Interval, promote(mid, rad)...)

# Promotion of `valuetype`
Base.promote_rule(::Type{Interval{T}}, ::Type{Interval{S}}) where {T, S} = Interval{promote_type(T, S)}

# Very basic arithmetic needed for `norm` (this would be fleshed out in real applications)
Base.:+(x::Interval, y::Interval) = Interval(x.lo + y.lo, x.hi + y.hi)
Base.abs2(x::Interval) = Interval(mig(x)^2, mag(x)^2)
Base.sqrt(x::Interval) = Interval(sqrt(loval(x)), sqrt(hival(x)))

end # module IntervalArith
