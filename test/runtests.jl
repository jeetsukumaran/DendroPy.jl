using DendroPy
using Test
using JSON

function get_test_data()
    source_path = joinpath(@__DIR__, "data", "expectedresults20240812.json")
    return JSON.parsefile(source_path)
end

@testset "DendroPy.jl: single tree parsing" begin
    # Write your tests here.
    test_data = get_test_data()
    foreach(test_data["trees"]) do tree_data
        tree_str = tree_data["newick"]
        dendropy_tree = dendropy.Tree.get(data=tree_str, schema=:newick, rooting="force-rooted")
    end
end
