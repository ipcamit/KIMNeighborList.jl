# Load C++ functions via CxxWrap
using CxxWrap
using Libdl

const libpath = joinpath(@__DIR__, "..", "lib", "kimneighborlist")
@wrapmodule(() -> libpath, :define_julia_module)

function __init__()
    @initcxx
end