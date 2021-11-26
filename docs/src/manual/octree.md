# Octree

## Parallelism

```julia
using Distributed
addprocs(4)

@everywhere using PhysicalTrees

pos = [PVector(1.0, 1.0, 1.0, u"kpc"), PVector(-1.0, -1.0, -1.0, u"kpc"),
       PVector(1.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 1.0, u"kpc"),
       PVector(0.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 0.0, u"kpc")];
particles = StructArray(Star(uAstro) for i in 1:6);
assign_particles(particles, :Pos, pos)

# By default, pids = workers()
tree = octree(particles, pids = procs())
```