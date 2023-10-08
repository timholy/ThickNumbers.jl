```@meta
CurrentModule = ThickNumbers
```

# ThickNumbers

A `ThickNumber{T}` is an abstract type denoting objects that act like numbers--they have standard algebraic operations `+`, `-`, `*`, and `/`--but also
have properties of a [connected set](https://en.wikipedia.org/wiki/Connected_space), specifically occupying some "width," e.g., a segment of the real number line. Examples of possible concrete subtypes include [intervals](https://en.wikipedia.org/wiki/Interval_arithmetic), [gaussian random variables](https://en.wikipedia.org/wiki/Algebra_of_random_variables), and potentially others. While the parameter `T` in `ThickNumber` does not necessarily have to be `T<:Real`, it should have an ordering so that "width" has some meaning.

## The Fundamental Principle of ThickNumbers (FPTN)

An important issue that must be understood at the outset is a generalization of the
*Fundamental Theorem of Interval Arithmetic* (Moore, R. E. 1966, *Interval analysis*), which we adopt as:

!!! note "Fundamental Principle of ThickNumbers (FPTN)"
    If `f(x::T)` is a function and `X` a `ThickNumber{T}`, then `f(X)` should either error
    or return another `ThickNumber` such that `f(x) ∈ f(X)` for "most" or all `x ∈ X`.
    This principle generalizes to functions with more than one argument, `f(x::T, y::T)`, but
    does not include mixtures of argument types like `f(x::T, X::ThickNumber{T})`.

Here, "most" is directed at possible subtypes like Gaussian random variables, where one would expect that `f(X)` returns a value appropriate for `x` drawn near the center of the distribution `X` but not necessarily for those in the tails.

FPTN has subtle implications, particularly for 2-argument functions intended to return a `Bool`.
For example, `==(x, y)` is a standard 2-argument Julia function, and the FPTN implies that `==(X::ThickNumber, Y::ThickNumber)` *cannot be defined* (it must error): after all,
returning `true` would imply that `x == y` *for any choice* `x ∈ X` and `y ∈ Y`, and this is impossible
unless `X` and `Y` are either empty or each contain only a single value. Concretely, if `1..3` constructs an interval, then `1..3 == 1..3` returning `true` would require that `1.5 == 1.5` and also `1.5 == 2.5` since both `1.5` and `2.5` can be drawn from `1..3`. This is obviously impossible,
thus having `1..3 == 1..3` return `true` would be a violation of the FPTN; it must error instead.

Because numbers are iterable in Julia, set operations like `X ⊆ Y` also cannot be defined (it would require that each number in `X` is a subset of every number in `Y`); however, operations like `intersect(X, Y)` (i.e., `X ∩ Y`) are valid because `x ∩ y` returns `∅` if `x != y` and `∅` is a subset of all other sets.

To avoid violating the FPTN, we replace operators like `==` with custom operators that work only on `ThickNumber{T}` but not `T`. For `Base` Julia functions, a convention is to add `_tn` after the standard function name:

- `isequal_tn(X, Y)` replaces the "intent" of `X == Y` (unicode: `⩦`)
- `isapprox_tn(X, Y)` replaces `≈` (unicode: `⩪`)
- `≺(X, Y)` (`\prec`-TAB) replaces `x < y ∀ x ∈ X, y ∈ Y`; likewise, `≻` (`\succ`-TAB) replaces `>`
- `isless_tn(X, Y)` replaces `isless(x, y) ∀ x ∈ X, y ∈ Y`
- `issubset_tn` replaces `⊆` (unicode: `⫃`)
- `is_strict_subset_tn` replaces `⊂` (unicode: `⪽`)
- `issupset_tn` replaces `⊇` (unicode: `⫄`)
- `is_strict_supset_tn` replaces `⊃` (unicode: `⪾`)

## Creating a new ThickNumber subtype

To create a new type `MyType{T} <: ThickNumber{T}`, the following interface functions must be defined:

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

## API

```@contents
Pages = ["required.md", "optional.md", "user_api.md"]
```
