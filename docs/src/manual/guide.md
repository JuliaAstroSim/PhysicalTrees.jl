# Guide

```@repl guide
using PhysicalParticles, PhysicalTrees, UnitfulAstro

pos = [PVector(1.0, 1.0, 1.0, u"kpc"), PVector(-1.0, -1.0, -1.0, u"kpc"),
       PVector(1.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 1.0, u"kpc"),
       PVector(0.0, 0.0, -1.0, u"kpc"), PVector(-1.0, 0.0, 0.0, u"kpc")];
tree = octree(pos)

particles = StructArray(Star(uAstro) for i in 1:6);
assign_particles(particles, :Pos, pos)
tree = octree(particles)
```