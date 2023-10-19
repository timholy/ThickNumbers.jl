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

function ForwardDiff.dual_definition_retval(::Val{T}, val::ThickNumber, deriv::ThickNumber, partial::Partials) where {T}
    return Dual{T}(val, deriv * partial)
end
function ForwardDiff.dual_definition_retval(::Val{T}, val::ThickNumber, deriv1::ThickNumber, partial1::Partials, deriv2::ThickNumber, partial2::Partials) where {T}
    return Dual{T}(val, ForwardDiff._mul_partials(partial1, partial2, deriv1, deriv2))
end

Base.:*(x::ThickNumber, partials::Partials) = partials * x
function Base.:*(partials::Partials, x::ThickNumber)
    return Partials(ForwardDiff.scale_tuple(partials.values, x))
end

Base.promote_rule(::Type{TN}, ::Type{Dual{T,V,N}}) where {TN<:ThickNumber,T,V<:Number,N} = Dual{T, promote_dual(TN, V),N}

promote_dual(::Type{TN}, ::Type{V}) where {TN<:ThickNumber,V} = promote_type(TN, V)
promote_dual(::Type{TN}, ::Type{Dual{T,V,N}}) where {TN<:ThickNumber,T,V,N} = Dual{T, promote_dual(TN, V), N}

### Special functions

Base.signbit(x::ThickDual) = signbit(value(x))

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
