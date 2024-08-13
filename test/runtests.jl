using Printf

using Test
using Logging
using JSON

using DendroPy

function get_test_data()
    source_path = joinpath(@__DIR__, "data", "expectedresults20240812.json")
    d = JSON.parsefile(source_path)
    for (tree_idx, tree_d) in enumerate(d["trees"])
        tree_d["id"] = @sprintf("Tree_%03d", tree_idx)
    end
    return d
end

@testset "DendroPy.jl: map_trees" begin
    # Write your tests here.
    test_data = get_test_data()
    tree_keys::Vector{Symbol} = []
    application_count = Dict{Symbol, Integer}()
    trees_data = test_data["trees"]
    n_trees_visited = 0
    foreach(enumerate(trees_data)) do (tree_idx, tree_data)
        n_trees_visited += 1
        tree_str = tree_data["newick"]
        # test_apply_fn = (tree) -> application_count[tree_data["id"]] = get(application_count, tree_data["id"], 0) + 1
        # DendroPy.map_trees(test_apply_fn, tree_str, "string", :newick)
        DendroPy.map_trees(tree_str, "string", :newick) do tree
            tree_key = Symbol(tree_data["id"])
            application_count[tree_key] = get(application_count, tree_key, 0) + 1
            push!(tree_keys, tree_key)
        end
    end
    @test length(tree_keys) == length(trees_data) == n_trees_visited
    @test all(haskey.(Ref(application_count), tree_keys))
end

# @testset "DendroPy.jl: single tree parsing" begin
#     # Write your tests here.
#     test_data = get_test_data()
#     foreach(test_data["trees"]) do tree_data
#         tree_str = tree_data["newick"]
#         # py_tree = dendropy.Tree.get(data=tree_str, schema=:newick, rooting="force-rooted")
#         # j_trees = (fn) -> DendroPy.map_trees(fn, tree_str, "string", :newick)
#         DendroPy.map_trees(tree_str, "string", :newick) do j_tree
#             return j_tree.resolve_node_ages()
#         end
#     end
# end
