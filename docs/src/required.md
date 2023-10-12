# Required API functions

Each package creating a new `ThickNumber` subtype must implement:

```@docs
loval
hival
basetype
```

If possible, you should also implement:

```@docs
lohi
```

If your ThickNumber subtype can't be constructed this way, you will likely have to specialize several of the ThickNumber API functions to compensate.

You also need to implement any binary arithmetic operations (`a + b`, `a - b`, `a * b`, `a / b`).
Unary `+` and `-` (i.e., `-x`) have default implementations for all `ThickNumber` subtypes,
although you can choose to specialize if warranted.
