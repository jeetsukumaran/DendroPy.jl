using Printf

using Test
using Logging
using JSON

using DendroPy

function get_test_data()
    source_path = joinpath(@__DIR__, "data", "expectedresults.trees.basic.json")
    d = JSON.parsefile(source_path)
    return d
end

# Ensure that enumerate_map_trees visits each tree in correct order once and exactly once
function check_mapping_over_collection(iter_fn)
    test_d = get_test_data()
    test_trees_data = test_d["data"]
    test_newick_str = test_d["definitions"]["newick"]
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
    test_d = get_test_data()
    test_trees_data = test_d["data"]
    test_newick_str = test_d["definitions"]["newick"]
    DendroPy.enumerate_map_tree_source( (tree_idx, tree) -> begin
        test_tree_data = test_trees_data[tree_idx]
        for (fn_key, apply_fn) in (
            ["edge_lengths", DendroPy.edge_length,],
            ["labels", DendroPy.label,],
            # ["ages", DendroPy.age,],
        )
            for (traversal_key, iter_fn) in (
                # ["postorder", DendroPy.postorder_map, test_tree_data[tree_idx]["nodes"][fn_key]["postorder"]],
                ["postorder", DendroPy.postorder_map],
                ["preorder", DendroPy.preorder_map],
            )
                expected = test_tree_data["nodes"][fn_key][traversal_key]
                result = iter_fn(apply_fn, tree)
                # @info result
                # @info typeof(result)
                @test result == expected
            end
        end
    end, test_newick_str, "string", :newick)
end

function check_tree_features()
    test_d = get_test_data()
    test_trees_data = test_d["data"]
    test_newick_str = test_d["definitions"]["newick"]
    DendroPy.enumerate_map_tree_source( (tree_idx, tree) -> begin
        test_tree_data = test_trees_data[tree_idx]
        for (feature_key, feature_fn,) in (
            ["coalescence_ages", DendroPy.coalescence_ages, ],
            ["divergence_times", DendroPy.divergence_times, ],
        )
            expected = test_tree_data["features"][feature_key]
            result = feature_fn(tree)
            @test length(result) == length(expected)
            @test result == expected
        end
    end, test_newick_str, "string", :newick)
end

@testset "DendroPy.jl: mappings over collections of trees" begin
    check_mapping_over_collection(DendroPy.enumerate_map_tree_source)
    check_mapping_over_collection(DendroPy.map_tree_source)
end

@testset "DendroPy.jl: mappings over tree" begin
    check_mapping_over_tree()
end

@testset "DendroPy.jl: tree feature extraction" begin
    check_tree_features()
end


