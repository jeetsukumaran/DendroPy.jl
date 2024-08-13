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

@testset "DendroPy.jl: map_trees: single" begin
    # Write your tests here.
    test_data = get_test_data()
    trees_data = test_data["trees"]
    tree_keys::Vector{Symbol} = []
    tree_strings::Vector{String} = []
    application_count = Dict{Symbol, Integer}()
    n_trees_visited = 0
    foreach(enumerate(trees_data)) do (tree_idx, tree_data)
        n_trees_visited += 1
        tree_str = tree_data["newick"]
        push!(tree_strings, tree_str)
        DendroPy.map_trees(tree_str, "string", :newick) do tree
            tree_key = Symbol(tree_data["id"])
            application_count[tree_key] = get(application_count, tree_key, 0) + 1
            push!(tree_keys, tree_key)
        end
    end
    @test length(tree_keys) == length(trees_data) == n_trees_visited
    @test all(haskey.(Ref(application_count), tree_keys))
    @test sort(collect(keys(application_count))) == sort(tree_keys)

    # Some experiments in syntax
    @test all((==).(values(application_count), 1))
    @test all(x -> x == 1, values(application_count))
    @test all(x == 1 for x in values(application_count))

end

