# Creating a new ThickNumber subtype

!!! tip
    For a concrete example, see the `ThickNumbersInterfaceTests/test/testpackages/IntervalArith` "package"
    in the main source repository of `ThickNumbers.jl`. You can get a hint of the behaviors this endows by looking
    at `ThickNumbers/test/runtests.jl`, which uses the `Interval` type defined by `IntervalArith`.

Create your type by subtyping `ThickNumber{T}`:

```julia
struct MyType{T<:Real} <: ThickNumber{T}
    # you can have whatever fields you need...
    a::T
    b::T
end
```

If you only intend to support, say, `Float64`, you can use `struct MyType <: ThickNumber{Float64} ... end`: the key point is that the `T` in `ThickNumber{T}` should encode the [`valuetype`](@ref).

The following interface functions must be defined:

- [`loval(x)`](@ref): should return the lower span (i.e., the "lower bound" if such bounds are strict).
- [`hival(x)`](@ref): should return the upper span.
- [`basetype(x)`](@ref): should strip the `valuetype`, i.e., `basetype(Interval{Float64})` returns `Interval`.
- any arithmetic operations you need, e.g., `+`, `-`, `*`, and `/`

The implementation of these functions must satisfy certain requirements spelled out in the documentation of each of these functions.

If possible, you should also define:

- [`lohi(MyType{T}, lo, hi)`](@ref): construct `x` from two numbers specifying the lower and upper spans.

If you cannot define this for your type (e.g., `MyType` requires more than two arguments to construct), it is likely that you'll have to specialize some of the [User API](@ref) functions for `MyType`, since the default implementations of some of them rely on `lohi`.

There are also numerous optional methods you can specialize if it makes `MyType` operate more
efficiently. For example, a Gaussian random variable package might want to implement [`midrad(MyType{T}, center, σ)`](@ref) to construct values directly, assuming this is the natural parametrization
of this type.

`MyType` need not be parametrized by its `lo` and `hi` values: generic code constructs its
results only through [`lohi`](@ref) and [`midrad`](@ref), never by calling a two-argument
`MyType(a, b)` constructor. One caveat: the default [`emptyset`](@ref) spans
`[typemax(T), typemin(T)]`, whose midpoint is `NaN`, so a type parametrized by a midpoint
must specialize `emptyset`; a negative radius is the natural choice.

## Ensuring compliance with the ThickNumbers interface

The `ThickNumbersInterfaceTests` package can be used to determine whether your implementations comply with the requirements.  As it is possible that this test suite will evolve and add new requirements,
be sure to use `[compat]` bounds to specify the major version number of `ThickNumbersInterfaceTests` that your implementation satisfies.

## Features provided by subtyping ThickNumber

See the [User API](@ref).

## Implementing the interface without subtyping

Subtype `ThickNumber` to inherit the generic methods in the [User API](@ref).

A type with another supertype can implement the interface by defining [`isthick`](@ref):

```julia
ThickNumbers.isthick(::Type{<:MyType}) = true
```

It must implement [`loval`](@ref), [`hival`](@ref), [`lohi`](@ref), [`basetype`](@ref),
supported arithmetic, and any needed derived methods. These may include [`mid`](@ref),
[`wid`](@ref), [`rad`](@ref), [`mag`](@ref), [`mig`](@ref), [`hull`](@ref),
[`emptyset`](@ref), [`isempty_tn`](@ref), [`isnan_tn`](@ref), [`isinf_tn`](@ref),
[`isfinite_tn`](@ref), and `iszero`.

Use `isthick(x)` to recognize both kinds of implementation.
