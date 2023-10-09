# Creating a new ThickNumber subtype

Create your type by subtyping `ThickNumber{T}`:

```julia
struct MyType{T<:Real} <: ThickNumber{T}
    a::T
    b::T
    # you can have whatever fields you need
end
```

If you only intend to support, say, `Float64`, you can use `struct MyType <: ThickNumber{Float64} ... end`: the key point is that the `T` in `ThickNumber{T}` should encode the [`valuetype`](@ref)

the following interface functions must be defined:

- [`lohi(MyType{T}, lo, hi)`](@ref): construct `x` from two numbers specifying the lower and upper spans. For example, for an interval `lo` and `hi` would be the left and right edges, respectively. (Conservative outward rounding is allowed.) Types like gaussian random variables that do not have a strict lower bound should use some characteristic lower and upper values, e.g., `center ± σ`.
- [`loval(x)`](@ref): should return the lower span.
- [`hival(x)`](@ref): should return the upper span.
- arithmetic operations, e.g., `+`, `-`, `*`, and `/`

The implementation of these functions must satisfy certain requirements spelled out in the documentation of each of these functions.

There are also numerous optional methods you can specialize if it makes `MyType` operate more
efficiently. For example, a gaussian random variable package might want to implement [`midrad(MyType{T}, center, σ)`](@ref) to construct values directly, assuming this is the natural parametrization
of this type.

## Ensuring compliance with the ThickNumbers interface

The `ThickNumbersInterfaceTests` package can be used to determine whether your implementations comply with the requirements.  As it is possible that this test suite will evolve and add new requirements,
be sure to use `[compat]` bounds to specify the major version number of `ThickNumbersInterfaceTests` that your implementation satisfies.

## Features provided by subtyping ThickNumber

See the [User API](@ref).
