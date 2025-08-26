cmake_minimum_required(VERSION 3.10)
project(KIMNeighborList)
find_package(JlCxx REQUIRED)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
add_library(kimneighborlist SHARED
    src/neighbor_list.cpp
    src/neighbor_list_wrap.cpp
)
target_include_directories(kimneighborlist PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)
target_link_libraries(kimneighborlist JlCxx::cxxwrap_julia)
set_target_properties(kimneighborlist PROPERTIES
    PREFIX ""
    SUFFIX ""
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib"
)
install(TARGETS kimneighborlist
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)
# thanks to claude for this file
