using CxxWrap
using Libdl

const libpath = joinpath(@__DIR__, "..", "lib", "kimneighborlist")
@wrapmodule(() -> libpath, :define_julia_module)

function __init__()
    @initcxx
end

export nbl_initialize, nbl_clean, nbl_build, nbl_get_neigh, nbl_create_paddings, get_neigh_kim_ptr
