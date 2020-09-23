# PhysicalTrees.jl

[![codecov](https://codecov.io/gh/JuliaAstroSim/PhysicalTrees.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaAstroSim/PhysicalTrees.jl)

Distributed Octree for Nbody simulation.

## Install

```julia
]add PhysicalTrees
```
or
```julia
]add https://github.com/JuliaAstroSim/PhysicalTrees.jl
```

## Usage

```julia
using Distributed
addprocs(1)

@everywhere using PhysicalTrees

# discrete points
pos = [PVector(1.0, 1.0, 1.0), PVector(-1.0, -1.0, -1.0),
       PVector(1.0, 0.0, -1.0), PVector(-1.0, 0.0, 1.0),
       PVector(0.0, 0.0, -1.0), PVector(-1.0, 0.0, 0.0)]

# Build octree from point data
tree1 = octree(pos)

# Or, build octree from particles
particles = [Massless() for i in 1:6]
assign_particles(particles, :Pos, pos)
tree2 = octree(particles, pids = [2])
```

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