module ThickNumbersForwardDiffExt

using ThickNumbers
using ForwardDiff: ForwardDiff, Dual, Partials, Tag

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

end
