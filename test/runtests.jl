using Test
using KIMNeighborList
using StaticArrays

@testset "KIMNeighborList.jl" begin

    # AI generated tests for KIMNeighborList.jl
    @testset "Low-level C functions" begin
        @testset "Basic neighbor list creation" begin
            nl_ptr = nbl_initialize()
            @test nl_ptr isa Ptr{Nothing}
            nbl_clean(nl_ptr)
        end
        
        @testset "KIM function pointer" begin
            ptr = get_neigh_kim_ptr()
            @test ptr isa Ptr{Nothing}
        end
    end
    
    @testset "High-level NeighborList interface" begin        
        @testset "Simple system with atomic numbers" begin
            # Two atoms with atomic numbers
            coords = [SVector(0.0, 0.0, 0.0), SVector(1.0, 0.0, 0.0)]
            species = [1, 1]  # Hydrogen
            cell = [10.0 0.0 0.0; 0.0 10.0 0.0; 0.0 0.0 10.0]
            pbc = [false, false, false]
            cutoff = 1.2
            
            get_neigh = NeighborList(species, coords, cell, pbc, cutoff)
            
            # Each atom should see the other
            neigh_idx1, neigh_coords1, neigh_species1 = get_neigh(1)
            @test length(neigh_idx1) == 1
            @test neigh_idx1[1] == 2
            @test neigh_species1[1] == "H"
            
            neigh_idx2, neigh_coords2, neigh_species2 = get_neigh(2)
            @test length(neigh_idx2) == 1
            @test neigh_idx2[1] == 1
            @test neigh_species2[1] == "H"
        end
                
        @testset "Error handling" begin
            coords = [SVector(0.0, 0.0, 0.0)]
            species = ["H"]
            cell = [1.0 0.0 0.0; 0.0 1.0 0.0; 0.0 0.0 1.0]
            pbc = [false, false, false]
            cutoff = 1.0
            
            get_neigh = NeighborList(species, coords, cell, pbc, cutoff)
            
            # Test bounds checking
            @test_throws ArgumentError get_neigh(0)
            @test_throws ArgumentError get_neigh(2)
            
            # Test input validation
            @test_throws ArgumentError NeighborList(["H"], [SVector(0.0, 0.0, 0.0), SVector(1.0, 0.0, 0.0)], 
                                                   cell, pbc, cutoff)  # mismatched species/coords
            @test_throws ArgumentError NeighborList(species, coords, [1.0 0.0; 0.0 1.0], pbc, cutoff)  # wrong cell size
            @test_throws ArgumentError NeighborList(species, coords, cell, [true, false], cutoff)  # wrong pbc length
        end
    end

    # Good old human generated manual tests
    @testset "Generate Neighbors tests" begin

        cutoff = 3.7
        coords = [SVector(0.0, 0.0, 0.0), SVector(1.35, 1.35, 1.35)]
        cell = [0.0 2.7 2.7; 2.7 0.0 2.7; 2.7 2.7 0.0]
        species = ["H", "H"]  # or atomic numbers [1, 1, 1]
        
        @testset "PBC on test" begin
            pbc = [true, true, true]  # periodic boundary conditions

            get_neigh = NeighborList(species, coords, cell, pbc, cutoff)
            n, p, s = get_neigh(1)
            @test typeof(n) == Vector{Int}
            @test n == [2, 12, 24, 28]
            @test_throws ArgumentError get_neigh(0)
            @test_throws ArgumentError get_neigh(3) # no neigs for ghosts
        end

        @testset "PBC off test" begin
            pbc = [false, false, false]  # no periodic boundary conditions

            get_neigh = NeighborList(species, coords, cell, pbc, cutoff)
            n, p, s = get_neigh(1)
            @test typeof(n) == Vector{Int}
            @test n == [2]
        end

        @testset "Ask for neighbors of ghosts" begin
            pbc = [true, true, true]  # periodic boundary conditions

            get_neigh = NeighborList(species, coords, cell, pbc, cutoff; padding_need_neigh=true)
            n, p, s = get_neigh(3)
            @test n == [4]
        end

        @testset "multiple cutoffs" begin
            cutoffs = [3.7, 4.0]
            pbc = [true, true, true]  # periodic boundary conditions
            get_neigh = NeighborList(species, coords, cell, pbc, cutoffs)
            n, p, s = get_neigh(2, list_idx=2)
            @test n == [1, 12, 24, 28, 32, 44, 26, 40, 45, 46, 14, 18, 33, 34, 29, 30]
            @test_throws ArgumentError get_neigh(2, list_idx=0)
            @test_throws ArgumentError get_neigh(2, list_idx=3)
        end
    end
end

println("All tests passed!")
