using CxxWrap

src_dir = joinpath(@__DIR__, "..")
build_dir = joinpath(src_dir, "build")
lib_dir = joinpath(src_dir, "lib")

mkpath(build_dir)
mkpath(lib_dir)

sources = [
    joinpath(src_dir, "src", "neighbor_list.cpp"),
    joinpath(src_dir, "src", "neighbor_list_wrap.cpp")
]

include_dirs = [joinpath(src_dir, "src")]

try
    CxxWrap.build_shared_lib("kimneighborlist", sources; 
                           include_directories=include_dirs,
                           output_directory=lib_dir)
    println("KIMNeighborList built successfully!")
catch e
    println("Build failed with CxxWrap build system, falling back to manual CMake...")
    
    # Fallback to manual cmake
    cd(build_dir) do
        cxxwrap_prefix = CxxWrap.prefix_path()
        run(`cmake -DCMAKE_BUILD_TYPE=Release -DJlCxx_DIR=$cxxwrap_prefix/lib/cmake/JlCxx ..`)
        run(`cmake --build . --config Release`)
    end
    println("KIMNeighborList built successfully with CMake!")
end
