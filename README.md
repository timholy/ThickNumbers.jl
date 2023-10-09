# ThickNumbers

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://timholy.github.io/ThickNumbers.jl/dev/)
[![Build Status](https://github.com/timholy/ThickNumbers.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/timholy/ThickNumbers.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/timholy/ThickNumbers.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/timholy/ThickNumbers.jl)

This package defines a new abstract type, `ThickNumber{T}`, which is like Julia's `Number` but represents numbers that may have a "thickness" or "width". Such numbers generally support arithmetic but also act like sets, in the sense that they contain spans of "point" numbers. Prominent examples of such numbers include [intervals](https://en.wikipedia.org/wiki/Interval_arithmetic) and [gaussian random variables](https://en.wikipedia.org/wiki/Algebra_of_random_variables).

It also defines a common API for working with ThickNumber types, making it possible to write code that supports multiple `ThickNumber` subtypes simultaneously. See the [documentation](https://timholy.github.io/ThickNumbers.jl/dev/) for details.
