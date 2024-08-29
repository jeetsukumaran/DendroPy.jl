# DendroPy

This is a Julia wrapper for [DendroPy](https://jeetsukumaran.github.io/DendroPy/).

It is in pre-pre-pre-pre-alpha status :)

<!-- [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jeetsukumaran.github.io/DendroPy.jl/stable/) -->
<!-- [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jeetsukumaran.github.io/DendroPy.jl/dev/) -->
<!-- [![Build Status](https://github.com/jeetsukumaran/DendroPy.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jeetsukumaran/DendroPy.jl/actions/workflows/CI.yml?query=branch%3Amain) -->

## Installation

DendroPy can be installed from the command line
```bash
julia -e 'using Pkg; Pkg.add(url="https://github.com/jeetsukumaran/DendroPy.jl")'
```

Alternately, DendroPy may also be installed via Pkg's built-in REPL as
```
pkg> add https://github.com/jeetsukumaran/DendroPy.jl
```

## Usage Example

Print taxon labels from tree.

```julia
using DendroPy


DendroPy.map_tree_source(
  (tree) -> begin
    result = DendroPy.postorder_map(DendroPy.label, tree)
    println(result)
  end,
  "(A,B,(C,D)E)F;",
  "string",
  :newick
)
```
