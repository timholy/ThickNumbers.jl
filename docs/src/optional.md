# Optional API functions

These methods have default implementations, but depending on the characteristics of your `ThickNumber` subtype you might prefer to supply your own implementation.

Julia Base functions (see Julia's own documentation for details):

- `Base.typemin(::Type{<:ThickNumber})`
- `Base.typemax(::Type{<:ThickNumber})`

Exported functions:

```@docs
ThickNumbers.midrad
ThickNumbers.emptyset
```
