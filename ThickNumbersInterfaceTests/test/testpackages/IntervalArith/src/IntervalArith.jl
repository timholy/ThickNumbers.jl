module IntervalArith

using ThickNumbers

export Interval

struct Interval{T} <: ThickNumber{T}
    lo::T
    hi::T
end
Interval(lo, hi) = Interval(promote(lo, hi)...)

ThickNumbers.loval(x::Interval) = x.lo
ThickNumbers.hival(x::Interval) = x.hi
ThickNumbers.lohi(::Type{Interval{T}}, lo, hi) where T = Interval{T}(lo, hi)
ThickNumbers.lohi(::Type{Interval}, lo::T, hi::T) where T = Interval{T}(lo, hi)
ThickNumbers.lohi(::Type{Interval}, lo, hi) = Interval(promote(lo, hi)...)

# These are needed only for `Interval` and not `Interval{T}`
ThickNumbers.midrad(::Type{Interval}, lo::T, hi::T) where T = midrad(Interval{T}, lo, hi)
ThickNumbers.midrad(::Type{Interval}, lo, hi) = Interval(promote(lo, hi)...)

end # module IntervalArith