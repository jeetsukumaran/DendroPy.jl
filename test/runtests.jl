using DendroPy
using Test
using JSON

function get_test_data()
    source_path = joinpath(@__DIR__, "data", "expectedresults20240812.json")
    return JSON.parsefile(source_path)
end

@testset "DendroPy.jl" begin
    # Write your tests here.
    test_data = get_test_data()
    foreach(test_data["trees"]) do tree_data
        @info tree_data["newick"]
    end
end
