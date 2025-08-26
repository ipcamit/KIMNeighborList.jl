using KIMNeighborList
using StaticArrays
using LinearAlgebra

println("KIMNeighborList.jl Examples")
println("="^50)

# Example 1: Simple two-atom system (working)
println("\nExample 1: Simple two-atom system")
println("-"^40)

coords = [SVector(0.0, 0.0, 0.0), SVector(1.2, 0.0, 0.0)]
species = ["H", "H"]
cell = [10.0 0.0 0.0; 0.0 10.0 0.0; 0.0 0.0 10.0]
pbc = [false, false, false]
cutoff = 1.5

println("Coordinates: $coords")
println("Species: $species")
println("Cutoff: $cutoff")

get_neigh = NeighborList(species, coords, cell, pbc, cutoff)

for i in 1:2
    neigh_idx, neigh_coords, neigh_species = get_neigh(i)
    println("Atom $i ($(species[i])): $(length(neigh_idx)) neighbors")
    println("  Indices: $neigh_idx")
    println("  Species: $neigh_species")
    if length(neigh_coords) > 0
        println("  Distances: $([round(norm(neigh_coords[j] - coords[i]), digits=3) for j in 1:length(neigh_coords)])")
    end
end

# Example 2: Using atomic numbers instead of symbols
println("\nExample 2: Atomic numbers input")
println("-"^40)

coords_atomic = [SVector(0.0, 0.0, 0.0), SVector(1.2, 0.0, 0.0)]
species_atomic = [6, 8]  # Carbon and Oxygen
cutoff_atomic = 1.5

get_neigh_atomic = NeighborList(species_atomic, coords_atomic, cell, pbc, cutoff_atomic)

for i in 1:2
    neigh_idx, neigh_coords, neigh_species = get_neigh_atomic(i)
    println("Atom $i (Z=$(species_atomic[i])): neighbors have species $neigh_species")
end

# Example 3: Low-level C interface for advanced users
println("\nExample 3: Low-level C interface")
println("-"^40)

# Create coordinates for a simple 2-atom system
coords_low = [0.0 0.0 0.0; 1.0 0.0 0.0]
species_low = Int32[1, 1]  # Hydrogen
cutoffs_low = [1.5]
need_neighbors_low = ones(Int32, 2)

# Initialize neighbor list
nl_ptr = nbl_initialize()

# Build neighbor list
error = nbl_build(nl_ptr, coords_low, 1.5, cutoffs_low, need_neighbors_low)
if error == 0
    println("Low-level neighbor list built successfully")
    
    # Query neighbors
    for i in 0:1  # 0-based indexing for C interface
        num_neigh, neighbors = nbl_get_neigh(nl_ptr, cutoffs_low, 0, i)
        println("Atom $i: $num_neigh neighbors -> $neighbors")
    end
else
    println("Failed to build neighbor list (error: $error)")
end

# Clean up
nbl_clean(nl_ptr)

println("\nAll examples completed!")
println("="^50)