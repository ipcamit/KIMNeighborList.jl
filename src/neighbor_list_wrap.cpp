#include "jlcxx/jlcxx.hpp"
#include "jlcxx/stl.hpp"
#include "neighbor_list.h"

// Simple wrapper to handle NeighList* as opaque pointer
JLCXX_MODULE define_julia_module(jlcxx::Module& mod)
{
  mod.method("nbl_initialize", []() -> void* {
    NeighList* nl = nullptr;
    nbl_initialize(&nl);
    return static_cast<void*>(nl);
  });

  mod.method("nbl_clean", [](void* nl_ptr) {
    NeighList* nl = static_cast<NeighList*>(nl_ptr);
    nbl_clean(&nl);
  });

  mod.method("nbl_build", [](void* nl_ptr,
                            jlcxx::ArrayRef<double, 2> coords,
                            double influence_distance,
                            jlcxx::ArrayRef<double, 1> cutoffs,
                            jlcxx::ArrayRef<int, 1> need_neigh) -> int {
    NeighList* nl = static_cast<NeighList*>(nl_ptr);
    int natoms = coords.size() / 3;
    
    return nbl_build(nl,
                    natoms,
                    coords.data(),
                    influence_distance,
                    static_cast<int>(cutoffs.size()),
                    cutoffs.data(),
                    need_neigh.data());
  });

  mod.method("nbl_get_neigh", [](void* nl_ptr,
                                jlcxx::ArrayRef<double, 1> cutoffs,
                                int neighbor_list_index,
                                int particle_number) -> std::tuple<int, std::vector<int>> {
    const void* data_object = nl_ptr;
    int number_of_neighbors = 0;
    const int* neigh_of_atom = nullptr;
    
    int error = nbl_get_neigh(data_object,
                             static_cast<int>(cutoffs.size()),
                             cutoffs.data(),
                             neighbor_list_index,
                             particle_number,
                             &number_of_neighbors,
                             &neigh_of_atom);
    
    if (error == 1) {
      throw std::runtime_error("nbl_get_neigh failed");
    }
    
    std::vector<int> neighbors(neigh_of_atom, neigh_of_atom + number_of_neighbors);
    return std::make_tuple(number_of_neighbors, neighbors);
  });

  mod.method("nbl_create_paddings", [](double influence_distance,
                                       jlcxx::ArrayRef<double, 2> cell,
                                       jlcxx::ArrayRef<int, 1> pbc,
                                       jlcxx::ArrayRef<double, 2> coords,
                                       jlcxx::ArrayRef<int, 1> species) 
    -> std::tuple<std::vector<double>, std::vector<int>, std::vector<int>> {
    
    int natoms = coords.size() / 3;
    int number_of_pads;
    std::vector<double> pad_coords;
    std::vector<int> pad_species;
    std::vector<int> pad_image;

    int error = nbl_create_paddings(natoms,
                                   influence_distance,
                                   cell.data(),
                                   pbc.data(),
                                   coords.data(),
                                   species.data(),
                                   number_of_pads,
                                   pad_coords,
                                   pad_species,
                                   pad_image);
    
    if (error == 1) {
      throw std::runtime_error("nbl_create_paddings failed");
    }

    return std::make_tuple(pad_coords, pad_species, pad_image);
  });

  mod.method("get_neigh_kim_ptr", []() -> void* {
    return reinterpret_cast<void*>(&nbl_get_neigh);
  });
}