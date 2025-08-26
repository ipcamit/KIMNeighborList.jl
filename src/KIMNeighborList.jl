module KIMNeighborList

# Load low-level C++ functions
include("load.jl")

# Load high-level interface
include("highlevel.jl")

# Export low-level C functions
export nbl_initialize, nbl_clean, nbl_build, nbl_get_neigh, nbl_create_paddings, get_neigh_kim_ptr

# Export high-level interface
export NeighborList

end # module