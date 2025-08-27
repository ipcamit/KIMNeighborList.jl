# High-level interface for KIM neighbor lists
using StaticArrays

# Atomic number to symbol mapping (first 118 elements)
const ATOMIC_SYMBOLS = [
    "H", "He", "Li", "Be", "B", "C", "N", "O", "F", "Ne",
    "Na", "Mg", "Al", "Si", "P", "S", "Cl", "Ar", "K", "Ca",
    "Sc", "Ti", "V", "Cr", "Mn", "Fe", "Co", "Ni", "Cu", "Zn",
    "Ga", "Ge", "As", "Se", "Br", "Kr", "Rb", "Sr", "Y", "Zr",
    "Nb", "Mo", "Tc", "Ru", "Rh", "Pd", "Ag", "Cd", "In", "Sn",
    "Sb", "Te", "I", "Xe", "Cs", "Ba", "La", "Ce", "Pr", "Nd",
    "Pm", "Sm", "Eu", "Gd", "Tb", "Dy", "Ho", "Er", "Tm", "Yb",
    "Lu", "Hf", "Ta", "W", "Re", "Os", "Ir", "Pt", "Au", "Hg",
    "Tl", "Pb", "Bi", "Po", "At", "Rn", "Fr", "Ra", "Ac", "Th",
    "Pa", "U", "Np", "Pu", "Am", "Cm", "Bk", "Cf", "Es", "Fm",
    "Md", "No", "Lr", "Rf", "Db", "Sg", "Bh", "Hs", "Mt", "Ds",
    "Rg", "Cn", "Nh", "Fl", "Mc", "Lv", "Ts", "Og"
]

# Symbol to atomic number mapping
const SYMBOL_TO_NUMBER = Dict(symbol => i for (i, symbol) in enumerate(ATOMIC_SYMBOLS))

"""
    symbol_to_number(symbol::String)

Convert atomic symbol to atomic number.
"""
function symbol_to_number(symbol::String)
    get(SYMBOL_TO_NUMBER, symbol, 0)
end

"""
    number_to_symbol(number::Int)

Convert atomic number to atomic symbol.
"""
function number_to_symbol(number::Integer)
    1 <= number <= length(ATOMIC_SYMBOLS) ? ATOMIC_SYMBOLS[number] : "unknown"
end

"""
Opaque handle for keeping neighbor list pointer alive and healthy.
"""
mutable struct _NeighborListHandle
    ptr::Ptr{Cvoid}
    is_valid::Bool

    function _NeighborListHandle(ptr::Ptr{Cvoid})
        handle = new(ptr, true)

        finalizer(handle) do h
            if h.is_valid && h.ptr != C_NULL
                nbl_clean(h.ptr)
                h.is_valid = false
            end
        end
    end
end


"""
    NeighborList(species, coords, cell, pbc, cutoffs; padding_need_neigh=true)

Create a neighbor list and return a closure `get_neigh` for querying neighbors.

# Arguments
- `species`: Vector of atomic symbols (String) or atomic numbers (Int)
- `coords`: Vector of SVector{3,Float64} coordinates
- `cell`: 3×3 Matrix{Float64} cell vectors as columns
- `pbc`: Vector{3} of Bool for periodic boundary conditions
- `cutoffs`: Single Float64 or Vector{Float64} of cutoff distances
- `padding_need_neigh`: Bool, whether to compute neighbors for padding atoms

# Returns
- `get_neigh`: Closure function that takes an index (1-based) and list idx (default = 1) and returns:
  - `neigh_idx`: Vector{Int} of neighbor indices (1-based)
  - `neigh_coords`: Vector{SVector{3,Float64}} of neighbor coordinates
  - `neigh_species`: Vector{String} of neighbor species symbols

# Example
```julia
using StaticArrays
coords = [SVector(0.0, 0.0, 0.0), SVector(1.0, 0.0, 0.0)]
species = ["H", "H"]
cell = [10.0 0.0 0.0; 0.0 10.0 0.0; 0.0 0.0 10.0]
pbc = [true, true, true]
cutoffs = 2.0

get_neigh = NeighborList(species, coords, cell, pbc, cutoffs)
neigh_idx, neigh_coords, neigh_species = get_neigh(1)
```
"""
function NeighborList(species::Vector, coords::Vector{SVector{3,Float64}}, 
                     cell::Matrix{Float64}, pbc::Vector{Bool}, cutoffs;
                     padding_need_neigh::Bool=false)
    
    # Validate inputs
    length(species) == length(coords) || throw(ArgumentError("species and coords must have same length"))
    size(cell) == (3, 3) || throw(ArgumentError("cell must be 3×3 matrix"))
    length(pbc) == 3 || throw(ArgumentError("pbc must be length 3"))
    
    # Convert species to atomic numbers if they are symbols
    species_numbers = if eltype(species) <: AbstractString
        [symbol_to_number(s) for s in species]
    else
        collect(Int32, species)
    end
    
    # Convert cutoffs to vector if single value
    cutoffs_vec = if isa(cutoffs, Number)
        [Float64(cutoffs)]
    else
        Vector{Float64}(cutoffs)
    end
    
    # Convert coordinates to matrix format for C++
    natoms = length(coords)
    # Julia uses column-major order, so hcat
    coords_matrix = reduce(hcat, coords) # col mat

    # Convert PBC to Int32
    pbc_int = Vector{Int32}(pbc)
    
    # Create padding atoms if PBC is enabled
    all_coords = coords_matrix
    all_species = species_numbers
    padding_offset = 0
    
    if any(pbc)
        influence_distance = maximum(cutoffs_vec)
        pad_coords_flat, pad_species, pad_masters = nbl_create_paddings(
            influence_distance, cell, pbc_int, coords_matrix, Vector{Int32}(species_numbers))
        
        if length(pad_species) > 0
            padding_offset = natoms
            # Convert flat padding coords to matrix
            npadding = length(pad_species)
            pad_coords_matrix = reshape(pad_coords_flat, 3, npadding)
            
            # Combine original and padding
            all_coords = hcat(coords_matrix, pad_coords_matrix) # col mat
            all_species = vcat(species_numbers, pad_species)
        end
    end
    
    # Create neighbor list
    nl_ptr = nbl_initialize()
    
    # Determine which atoms need neighbors
    # all_coords = Matrix(all_coords') # col mat
    total_atoms = size(all_coords, 2)
    need_neighbors = Vector{Int32}(undef, total_atoms)
    need_neighbors[1:natoms] .= 1  # Original atoms always need neighbors
    if padding_offset > 0
        # Padding atoms need neighbors only if requested
        need_neighbors[natoms+1:end] .= padding_need_neigh ? 1 : 0
    end
    
    # Build neighbor list
    influence_distance = maximum(cutoffs_vec)
    error = nbl_build(nl_ptr, all_coords, influence_distance, cutoffs_vec, need_neighbors)
    if error != 0
        nbl_clean(nl_ptr)
        throw(ErrorException("Failed to build neighbor list (error code: $error)"))
    else
        # Wrap pointer in handle to manage memory
        nl_handle = _NeighborListHandle(nl_ptr)
    end
    
    # Convert all coordinates to SVector format
    # all_coords = Matrix(all_coords') # row mat, TODO: get a proper solution to row-col major shift
    # this is a bit annoying
    all_coords_svec = [SVector{3,Float64}(all_coords[:, i]) for i in 1:size(all_coords, 2)]
    
    # Convert all species to symbols
    all_species_symbols = [number_to_symbol(s) for s in all_species]
    max_idx = padding_need_neigh ? total_atoms : natoms
    max_list_idx = length(cutoffs_vec)

    # Return closure for neighbor queries
    function get_neigh(atom_idx::Int; list_idx::Int=1)
        # Convert to 0-based indexing for C++
        if (atom_idx < 1 || atom_idx > max_idx )
            throw(ArgumentError("input must be between 1 and $natoms"))
        end
        if (list_idx < 1 || list_idx > max_list_idx )
            throw(ArgumentError("list_idx must be between 1 and $max_list_idx"))
        end

        
        atom_idx_0based = atom_idx - 1
        
        # Use first cutoff list (index 0)
        num_neighbors, neighbor_indices_0based = nbl_get_neigh(nl_handle.ptr, cutoffs_vec, list_idx - 1, atom_idx_0based)
        
        # Convert back to 1-based indexing
        neigh_idx = [idx + 1 for idx in neighbor_indices_0based]
        neigh_coords = [all_coords_svec[idx] for idx in neigh_idx]
        neigh_species = [all_species_symbols[idx] for idx in neigh_idx]
        
        return neigh_idx, neigh_coords, neigh_species
    end
    
    # TODO: CHECK FOR MEMORY LEAKS [IMPORTANT!]
    # _NeighborListHandle finalizer should handle cleanup
    
    return get_neigh
end
