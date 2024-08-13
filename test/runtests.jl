using DendroPy
using Test
using JSON
using Logging

function get_test_data()
    source_path = joinpath(@__DIR__, "data", "expectedresults20240812.json")
    return JSON.parsefile(source_path)
end

@testset "DendroPy.jl: single tree parsing" begin
    # Write your tests here.
    test_data = get_test_data()
    foreach(test_data["trees"]) do tree_data
        tree_str = tree_data["newick"]
        py_tree = dendropy.Tree.get(data=tree_str, schema=:newick, rooting="force-rooted")
        # j_trees = (fn) -> DendroPy.map_trees(fn, tree_str, "string", :newick)
        DendroPy.map_trees(tree_str, "string", :newick) do j_tree
            return j_tree.resolve_node_ages()
        end
    end
end
