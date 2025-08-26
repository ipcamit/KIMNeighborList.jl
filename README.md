# KIMNeighborList.jl

Julia package for efficient neighbor list calculations, converted from the pybind11-based Python/C++ KLIFF/KIMPY implementation using CxxWrap.jl.

Seems faster then NeighbourLists.jl that I currently use in `kim_api.jl`. Ported specifically for use in `kim_api.jl` but can be used standalone.

## Installation

1. First, ensure you have Julia 1.10+ installed.

2. Clone this repository and navigate to it:
```bash
cd kim_neigh.jl
```

3. Build the package:
```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
Pkg.build("KIMNeighborList")
```

This will automatically compile the C++ code and create the necessary bindings.

## Usage

### High-Level Interface (Recommended)

```julia
using KIMNeighborList
using StaticArrays

# Define system
coords = [SVector(0.0, 0.0, 0.0), SVector(1.0, 0.0, 0.0), SVector(2.0, 0.0, 0.0)]
species = ["H", "H", "H"]  # or atomic numbers [1, 1, 1]
cell = [10.0 0.0 0.0; 0.0 10.0 0.0; 0.0 0.0 10.0]  # 3x3 cell matrix
pbc = [false, false, false]  # periodic boundary conditions
cutoff = 1.5

# Create neighbor list (returns a closure)
get_neigh = NeighborList(species, coords, cell, pbc, cutoff)

# Query neighbors (1-based indexing)
neigh_idx, neigh_coords, neigh_species = get_neigh(2)
println("Atom 2 has $(length(neigh_idx)) neighbors: $neigh_species")
```

### Low-Level Interface (Advanced)

For direct access to C++ functions:

```julia
using KIMNeighborList

# Create neighbor list pointer
nl_ptr = nbl_initialize()

# Build neighbor list
coords = [0.0 0.0 0.0; 1.0 0.0 0.0; 2.0 0.0 0.0]
coords = Matrix(coords')# 3xN matrix, Julia is column-major
cutoffs = [1.5]
need_neighbors = ones(Int32, 3)
error = nbl_build(nl_ptr, coords, 1.5, cutoffs, need_neighbors)

# Get neighbors (0-based indexing)
num_neighbors, neighbor_indices = nbl_get_neigh(nl_ptr, cutoffs, 0, 1)

# Clean up
nbl_clean(nl_ptr)
```

TODO: check 0-based vs 1-based indexing in low-level interface
TODO: fix the GC issue
TODO: Benchmark against NeighbourLists.jl

## API Reference

### High-Level Interface

```julia
NeighborList(species, coords, cell, pbc, cutoffs; padding_need_neigh=true)
```

**Arguments:**
- `species`: Vector of atomic symbols (`String`) or numbers (`Int`)
- `coords`: Vector of `SVector{3,Float64}` coordinates
- `cell`: 3×3 `Matrix{Float64}` with cell vectors as columns
- `pbc`: Vector of 3 `Bool` for periodic boundary conditions
- `cutoffs`: Single `Float64` or `Vector{Float64}` of cutoff distances
- `padding_need_neigh`: Whether padding atoms need neighbor lists

**Returns:**
- `get_neigh`: Closure function taking atom index (1-based) and returning:
  - `neigh_idx`: Vector of neighbor indices (1-based)
  - `neigh_coords`: Vector of `SVector{3,Float64}` neighbor coordinates
  - `neigh_species`: Vector of neighbor species symbols

### Low-Level Interface

- `nbl_initialize()`: Create neighbor list pointer
- `nbl_build(ptr, coords, influence_distance, cutoffs, need_neighbors)`: Build neighbor list
- `nbl_get_neigh(ptr, cutoffs, neighbor_list_index, particle_number)`: Get neighbors
- `nbl_create_paddings(...)`: Create padding atoms for PBC
- `nbl_clean(ptr)`: Clean up memory
- `get_neigh_kim_ptr()`: Get function pointer for KIM interface

## Examples

See `examples/basic_usage.jl` for comprehensive usage examples including:
- Linear chains and mixed species
- Periodic boundary conditions
- Multiple cutoff distances
- Low-level C interface usage

## Testing

Run the test suite:
```julia
using Pkg
Pkg.test("KIMNeighborList")
```

## Package Structure

```
src/
├── KIMNeighborList.jl    # Main module
├── load.jl              # C++ function loading
├── highlevel.jl          # High-level Julia interface
└── neighbor_list_wrap.cpp # CxxWrap bindings
```

## Dependencies

- Julia 1.10+
- CxxWrap.jl 0.17+
- StaticArrays.jl
- CMake (for building)

## License

Same as the original implementation.
