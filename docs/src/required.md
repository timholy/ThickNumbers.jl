# Required API functions

Each package creating a new `ThickNumber` subtype must implement these functions.

You also need to implement any binary arithmetic operations (`a + b`, `a - b`, `a * b`, `a / b`).
Unary `+` and `-` (i.e., `-x`) have default implementations for all `ThickNumber` subtypes,
although you can choose to specialize if warranted.

```@docs
lohi
loval
hival
```
