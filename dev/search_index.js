var documenterSearchIndex = {"docs":
[{"location":"manual/octree/#Octree","page":"Octree","title":"Octree","text":"","category":"section"},{"location":"manual/octree/#Parallelism","page":"Octree","title":"Parallelism","text":"","category":"section"},{"location":"manual/octree/","page":"Octree","title":"Octree","text":"using Distributed\naddprocs(4)\n\n@everywhere using PhysicalTrees\n\npos = [PVector(1.0, 1.0, 1.0, u\"kpc\"), PVector(-1.0, -1.0, -1.0, u\"kpc\"),\n       PVector(1.0, 0.0, -1.0, u\"kpc\"), PVector(-1.0, 0.0, 1.0, u\"kpc\"),\n       PVector(0.0, 0.0, -1.0, u\"kpc\"), PVector(-1.0, 0.0, 0.0, u\"kpc\")];\nparticles = StructArray(Star(uAstro) for i in 1:6);\nassign_particles(particles, :Pos, pos)\n\n# By default, pids = workers()\ntree = octree(particles, pids = procs())","category":"page"},{"location":"lib/Methods/#Methods","page":"Methods","title":"Methods","text":"","category":"section"},{"location":"lib/Methods/#Index","page":"Methods","title":"Index","text":"","category":"section"},{"location":"lib/Methods/","page":"Methods","title":"Methods","text":"Pages = [\"Methods.md\"]","category":"page"},{"location":"lib/Methods/","page":"Methods","title":"Methods","text":"octree\nglobal_extent","category":"page"},{"location":"lib/Methods/#PhysicalTrees.global_extent","page":"Methods","title":"PhysicalTrees.global_extent","text":"global_extent(tree::AbstractTree)\n\nCompute global extent of all particles and broadcast the result.\n\n\n\n\n\n","category":"function"},{"location":"lib/Types/#Types","page":"Types","title":"Types","text":"","category":"section"},{"location":"lib/Types/#Index","page":"Types","title":"Index","text":"","category":"section"},{"location":"lib/Types/","page":"Types","title":"Types","text":"Pages = [\"Types.md\"]","category":"page"},{"location":"lib/Types/","page":"Types","title":"Types","text":"","category":"page"},{"location":"manual/guide/#Guide","page":"Guide","title":"Guide","text":"","category":"section"},{"location":"manual/guide/","page":"Guide","title":"Guide","text":"using PhysicalParticles, PhysicalTrees, UnitfulAstro\n\npos = [PVector(1.0, 1.0, 1.0, u\"kpc\"), PVector(-1.0, -1.0, -1.0, u\"kpc\"),\n       PVector(1.0, 0.0, -1.0, u\"kpc\"), PVector(-1.0, 0.0, 1.0, u\"kpc\"),\n       PVector(0.0, 0.0, -1.0, u\"kpc\"), PVector(-1.0, 0.0, 0.0, u\"kpc\")];\ntree = octree(pos)\n\nparticles = StructArray(Star(uAstro) for i in 1:6);\nassign_particles(particles, :Pos, pos)\ntree = octree(particles)","category":"page"},{"location":"#PhysicalTrees.jl","page":"Home","title":"PhysicalTrees.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Tools to construct distributed unitful trees","category":"page"},{"location":"#Package-Features","page":"Home","title":"Package Features","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Unitful\nDistributed\nUser-friendly interface","category":"page"},{"location":"#Manual-Outline","page":"Home","title":"Manual Outline","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Pages = [\n    \"manual/guide.md\",\n]","category":"page"}]
}
