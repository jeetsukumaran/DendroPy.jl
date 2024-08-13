using Printf

using Test
using Logging
using JSON

using DendroPy

function get_test_data()
    source_path = joinpath(@__DIR__, "data", "expectedresults20240812.json")
    d = JSON.parsefile(source_path)
    newick_strings::Vector{String} = []
    tree_ids::Vector{String} = []
    for (tree_idx, tree_d) in enumerate(d["trees"])
        tree_d["id"] = @sprintf("Tree_%03d", tree_idx)
        push!(newick_strings, tree_d["newick"])
        push!(tree_ids, tree_d["id"])
    end
    return Dict(
        :trees_data => d["trees"],
        :tree_ids => tree_ids,
        :newick_strings => newick_strings,
    )
end

# Ensure that enumerate_map_trees visits each tree in correct order once and exactly once
function check_mapping_over_collection(iter_fn)
    test_data = get_test_data()
    test_trees_data = test_data[:trees_data]
    test_newick_str = join(test_data[:newick_strings], "\n")
    visited_trees = Dict{Any, Integer}()
    iter_fn( (args...) -> begin
        tree = args[1]
        if haskey(visited_trees, tree)
            visited_trees[tree] += 1
        else
            visited_trees[tree] = 1
        end
    end, test_newick_str, "string", :newick)
    @test length(visited_trees) == length(test_trees_data)
    @test all(values(visited_trees) .== 1)
end

function check_mapping_over_tree()
    test_data = get_test_data()
    test_trees_data = test_data[:trees_data]
    test_newick_str = join(test_data[:newick_strings], "\n")
    DendroPy.enumerate_map_trees( (tree_idx, tree) -> begin
        test_tree_data = test_trees_data[tree_idx]
        abstract_tree = DendroPy.abstract_tree(tree)
        println(abstract_tree)
    end, test_newick_str, "string", :newick)
end

@testset "DendroPy.jl: mappings over collections of trees" begin
    # "labels": {
    #            "all_preorder": ["X0", "A", "B", "X1", "C", "X2", "D", "E"],
    #            "all_postorder": ["A", "B", "C", "D", "E", "X2", "X1", "X0"],
    #            "leaves_only": ["A", "B", "C", "D", "E"],
    #            "internal_preorder": ["X0", "X1", "X2"],
    #            "internal_postorder": ["X2", "X1", "X0"]
    #           },
    check_mapping_over_collection(DendroPy.enumerate_map_trees)
    check_mapping_over_collection(DendroPy.map_trees)
end

@testset "DendroPy.jl: mappings over tree" begin
    check_mapping_over_tree()
end


