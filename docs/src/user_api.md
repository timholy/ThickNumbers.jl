# User API

These are functions you can use on any `ThickNumber` subtype when writing your code.
Generally you shouldn't need to implement these directly (they all have default implementations),
although you can of course specialize them as needed as long as your implementation does not
violate the interface requirements.

## Types

```@docs
valuetype
```

## Query functions

API functions from the Interval Arithmetic Standard (IEEE Std 1788-2015), Table 9.2 are supported. One (deliberate) exception is `inf` and `sup`, which are replaced by [`loval`](@ref) and [`hival`](@ref): `inf` and `sup` have well-defined mathematical meanings that may not be appropriate for all `ThickNumber` subtypes (e.g., gaussian random variables don't have finite lower and upper bounds). If you are creating an interval arithmetic package, of course you can choose to define

```
inf(x::MyInterval) = loval(x)
sup(x::MyInterval) = hival(x)
```

in order to comply with the standard.

```@docs
mid
mag
mig
rad
wid
isfinite_tn
isinf_tn
isnan_tn
```

## Comparison operators

```@docs
iseq_tn
isequal_tn
isapprox_tn
isless_tn
≺
≻
⪯
⪰
```

## Set operations

See also [IntervalSets](https://github.com/JuliaMath/IntervalSets.jl) for a more flexible way of supporting intervals as sets.

```@docs
in(::Real, ::ThickNumber)
hull
Base.isempty(::ThickNumber)
issubset_tn
issupset_tn
is_strict_subset_tn
is_strict_supset_tn
```

Also supported are `Base`'s:

- `isdisjoint`
- `intersect`


## Operations with real numbers

- `clamp(::Real, ::ThickNumber)`
