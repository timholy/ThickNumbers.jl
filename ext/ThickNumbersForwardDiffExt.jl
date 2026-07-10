module ThickNumbersForwardDiffExt

using ThickNumbers
using ForwardDiff: ForwardDiff, Dual, Partials, Tag, value, partials, npartials, tagtype
using ForwardDiff.DiffRules: DiffRules, @define_diffrule
# Supports up to third-order derivatives
const ThickDual = Union{Dual{T,<:ThickNumber} where T,
                        Dual{T1,<:Dual{T2,<:ThickNumber}} where {T1,T2},
                        Dual{T1,<:Dual{T2,<:Dual{T3,<:ThickNumber}}} where {T1,T2,T3},
}
const ThickLike = Union{ThickNumber, ThickDual}

function ForwardDiff.derivative(f::F, x::TN) where {F,TN<:ThickNumber}
    T = typeof(Tag(f, TN))
    return ForwardDiff.extract_derivative(T, f(Dual{T}(x, one(x))))
end

ForwardDiff.can_dual(::Type{<:ThickNumber}) = true

# The value is a ThickNumber (the function evaluated over a set), but a diffrule
# derivative may be an ordinary `Real` (e.g. the integer coefficient from a power
# rule), so `deriv` is left as `Number`. `val::ThickNumber` keeps these from
# overlapping ForwardDiff's all-`Real` methods.
function ForwardDiff.dual_definition_retval(::Val{T}, val::ThickNumber, deriv::Number, partial::Partials) where {T}
    return Dual{T}(val, deriv * partial)
end
function ForwardDiff.dual_definition_retval(::Val{T}, val::ThickNumber, deriv1::Number, partial1::Partials, deriv2::Number, partial2::Partials) where {T}
    return Dual{T}(val, ForwardDiff._mul_partials(partial1, partial2, deriv1, deriv2))
end

Base.:*(x::ThickNumber, partials::Partials) = partials * x
function Base.:*(partials::Partials, x::ThickNumber)
    return Partials(ForwardDiff.scale_tuple(partials.values, x))
end

# ForwardDiff v1's `scale_tuple`/`mul_tuples`/`div_tuple_by_scalar` dispatch
# elementwise through `_mul_partial`/`_div_partial`, which only ship `Real`-`Real`
# methods; the partial tuple elements and/or the deriv/factor arguments may be
# ThickNumber here (e.g. at higher derivative orders), so every ThickNumber/Real
# combination needs a method.
ForwardDiff._mul_partial(partial::Real, x::ThickNumber) = partial * x
ForwardDiff._mul_partial(partial::ThickNumber, x::Real) = partial * x
ForwardDiff._mul_partial(partial::ThickNumber, x::ThickNumber) = partial * x
ForwardDiff._div_partial(partial::Real, x::ThickNumber) = partial / x
ForwardDiff._div_partial(partial::ThickNumber, x::Real) = partial / x
ForwardDiff._div_partial(partial::ThickNumber, x::ThickNumber) = partial / x

# ForwardDiff's `iszero_tuple` tests each partial with `==`, which ThickNumber
# disables. Test exact-zeroness with `iszero` instead (defined for ThickNumber and,
# recursively, for nested Duals over ThickNumbers).
ForwardDiff.iszero_tuple(tup::NTuple{N,V}) where {N,V<:ThickLike} = all(iszero, tup)

Base.promote_rule(::Type{TN}, ::Type{Dual{T,V,N}}) where {TN<:ThickNumber,T,V<:Number,N} = Dual{T, promote_dual(TN, V),N}

promote_dual(::Type{TN}, ::Type{V}) where {TN<:ThickNumber,V} = promote_type(TN, V)
promote_dual(::Type{TN}, ::Type{Dual{T,V,N}}) where {TN<:ThickNumber,T,V,N} = Dual{T, promote_dual(TN, V), N}

### Special functions

## First and higher-order derivatives of `abs`
function DiffRules._abs_deriv(x::ThickNumber)
    sb = signbit(x)
    lv, hv = loval(x), hival(x)
    return lohi(basetype(typeof(x)), true ∈ sb ? -one(lv) : one(lv), false ∈ sb ? one(hv) : -one(hv))
end
# Second derivative of abs spans from 0 to either 0 or Inf (if 0 is included in the range)
_abs_deriv2(x::ThickNumber) = iszero(mig(x)) ? lohi(typeof(x), 0, typemax(valuetype(x))) : zero(x)
@define_diffrule DiffRules._abs_deriv(x) = :($(_abs_deriv2)($x))
eval(ForwardDiff.unary_dual_definition(:DiffRules, :_abs_deriv))
# Third and higher derivatives of abs span from -Inf to Inf, or is zero if 0 is not included in the range
_abs_deriv3(x::ThickNumber{T}) where T = iszero(mig(x)) ? lohi(typeof(x), typemin(T), typemax(T)) : zero(x)
@define_diffrule ThickNumbersForwardDiffExt._abs_deriv2(x) = :($(_abs_deriv3)($x))
@define_diffrule ThickNumbersForwardDiffExt._abs_deriv3(x) = :($(_abs_deriv3)($x))
eval(ForwardDiff.unary_dual_definition(:ThickNumbersForwardDiffExt, :_abs_deriv2))
eval(ForwardDiff.unary_dual_definition(:ThickNumbersForwardDiffExt, :_abs_deriv3))


end
