# PhysicalTrees.jl

[![codecov](https://codecov.io/gh/JuliaAstroSim/PhysicalTrees.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaAstroSim/PhysicalTrees.jl)
[![][docs-dev-img]][docs-dev-url]

Distributed Octree for Nbody simulation.

## Install

```julia
]add PhysicalTrees
```
or
```julia
]add https://github.com/JuliaAstroSim/PhysicalTrees.jl
```

## Installation

```julia
]add PhysicalTrees
```

or

```julia
using Pkg; Pkg.add("PhysicalTrees")
```

or

```julia
using Pkg; Pkg.add("https://github.com/JuliaAstroSim/PhysicalTrees.jl")
```

To test the Package:
```julia
]test PhysicalTrees
```

## Documentation

- [**Dev**][docs-dev-url] &mdash; *documentation of the in-development version.*

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://juliaastrosim.github.io/PhysicalTrees.jl/dev

For beginners, it is highly recommended to read the [documentation of PhysicalParticles.jl](https://juliaastrosim.github.io/PhysicalParticles.jl/dev/).

## References

- [Gadget2 by V. Springel](https://wwwmpa.mpa-garching.mpg.de/gadget/)

## Package ecosystem

- Basic data structure: [PhysicalParticles.jl](https://github.com/JuliaAstroSim/PhysicalParticles.jl)
- File I/O: [AstroIO.jl](https://github.com/JuliaAstroSim/AstroIO.jl)
- Initial Condition: [AstroIC.jl](https://github.com/JuliaAstroSim/AstroIC.jl)
- Parallelism: [ParallelOperations.jl](https://github.com/JuliaAstroSim/ParallelOperations.jl)
- Trees: [PhysicalTrees.jl](https://github.com/JuliaAstroSim/PhysicalTrees.jl)
- Meshes: [PhysicalMeshes.jl](https://github.com/JuliaAstroSim/PhysicalMeshes.jl)
- Plotting: [AstroPlot.jl](https://github.com/JuliaAstroSim/AstroPlot.jl)
- Simulation: [ISLENT](https://github.com/JuliaAstroSim/ISLENT)