```@meta
CurrentModule = ThickNumbers
```

# ThickNumbers

A `ThickNumber{T}` is an abstract type denoting objects that act like numbers--they have standard algebraic operations `+`, `-`, `*`, and `/`--but also
have properties of a [connected set](https://en.wikipedia.org/wiki/Connected_space), specifically occupying some "width," e.g., a segment of the real number line. Examples of possible concrete subtypes include [intervals](https://en.wikipedia.org/wiki/Interval_arithmetic), [gaussian random variables](https://en.wikipedia.org/wiki/Algebra_of_random_variables), and potentially others. While the parameter `T` in `ThickNumber` does not necessarily have to be `T<:Real`, it should have an ordering so that "width" has some meaning.

This documentation is aimed at:

- *users* who what to know how to manipulate `ThickNumber` objects. Users should read:
  + [The Fundamental Principle of ThickNumbers (FPTN)](@ref), which explains key differences between `ThickNumber`s and "point" numbers
  + [The ThickNumber API](@ref), which lists the main functions used to manipulate ThickNumbers.
- *developers* who want to create a new `ThickNumber` subtype. Developers should read the two sections above followed by [Creating a new ThickNumber subtype](@ref), and then refer to the API reference sections as needed.

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

To avoid violating the FPTN, we replace operators like `==` with custom operators that work only on `ThickNumber{T}` but not `T`. For `Base` Julia functions, a convention is to add `_tn` after the standard function name: `isequal_tn(X, Y)` replaces the "intent" of `isequal(X, Y)`. Often these have unicode equivalents, which typically (though not always) involve a "dot" somewhere in the symbol.

See the API section below for a more complete list of these replacements.

## The ThickNumber API

Let `x` and `y` refer to a standard "point" numbers and `X` and `Y` corresponding `ThickNumber`s such that `x ∈ X` and `y ∈ Y`.

### Querying values

With only a few exceptions, the names of these come from the Interval Arithmetic Standard (IEEE Std 1788-2015).

- [`loval(X)`](@ref): return the "lower bound" (which may not be "fuzzy" for some ThickNumber subtypes) of `X` (similar to `inf` in the IEEE standard, but without promising the true infimum)
- [`hival(X)`](@ref): return the "upper bound" of `X` (similar to `sup` in the IEEE standard)
- [`mid(X)`](@ref): return the midpoint of `X`
- [`wid(X)`](@ref): return the width (`hival - loval`) of `X`
- [`rad(X)`](@ref): return the half-width of `X` (half the value of `wid(X)`)
- [`mag(X)`](@ref): the largest absolute value contained in `X`
- [`mig(X)`](@ref): the smallest absolute value contained in `X`

You can also check a few basic properties, like whether the values contained in `X` are finite:

- [`isfinite_tn(X)`](@ref)
- [`isinf_tn(X)`](@ref)
- [`isnan_tn(X)`](@ref)

### Type information

- [`valuetype(X)`](@ref): return the type of numbers contained in `X` (e.g., `Float64`)

### Generic constructors

Each `ThickNumber` subtype has its own constructor(s), but if you need a way to write generic code that works for multiple `ThickNumber` subtypes, you may be able to use:

- [`lohi`](@ref): `lohi(TN, lo, hi)` creates a ThickNumber `X` where `typeof(X) <: TN`, `loval(X) ≈ lo`, and `hival(X) ≈ hi`. (It's approximate because of floating-point roundoff error and the fact that not all ThickNumber subtypes encode these bounds directly.)
- [`midrad`](@ref) creates a ThickNumber from its midpoint and radius (see [`mid`](@ref) and [`rad`](@ref)).

Note that some ThickNumber subtypes might need additional arguments, so there may be some that cannot be constructed generically and for which `lohi` and `midrad` might error.

### Comparison operators

For an explanation of why these aren't just `==`, `<`, etc, read [The Fundamental Principle of ThickNumbers (FPTN)](@ref).

- [`iseq_tn`](@ref) (i.e., `iseq(X, Y)`, or the unicode analog `X ⩦ Y`) checks equality between `X` and `Y` (i.e., the replacement for `x == y`)
- `isequal_tn(X, Y)` replaces `isequal(x, y)` (see the Julia docs for the subtle difference between `==` and `isequal`).
- `isapprox_tn(X, Y)` (unicode `X ⩪ Y`) checks approximate equality (`≈`) between `X` and `Y`
- `X ≺ Y` (typed with `\prec`-TAB) and `X ≻ Y` (`\succ`-TAB) test whether "all" values in `X` are strictly less or greater, respectively, than "all" values in `Y`.
- `isless_tn(X, Y)` replaces `isless(x, y)` (see the Julia docs for the subtle difference between `<` and `isless`)
- `X ⪯ Y` (`\preceq`-TAB) and `X ⪰ Y`(`\succeq`-TAB) replace `<=` and `>=`, respectively.

### Set operations

- [`issubset_tn`](@ref) replaces `⊆` (unicode: `⫃`)
- [`is_strict_subset_tn`](@ref) replaces `⊂` (unicode: `⪽`)
- [`issupset_tn`](@ref) replaces `⊇` (unicode: `⫄`)
- [`is_strict_supset_tn`](@ref) replaces `⊃` (unicode: `⪾`)
- [`hull`](@ref) creates a number that contains its arguments

### API reference

The API is described more completely in:

```@contents
Pages = ["required.md", "optional.md", "user_api.md"]
```
