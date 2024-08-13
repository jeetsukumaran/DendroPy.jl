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



# Ensure that map_trees visits each tree in correct order once and exactly once
@testset "DendroPy.jl: mappings over collections of trees" begin
    # Write your tests here.
    test_data = get_test_data()
    test_trees_data = test_data[:trees_data]
    test_newick_str = join(test_data[:newick_strings], "\n")
    visited_trees = Dict{Any, Integer}()
    DendroPy.enumerate_map_trees( (tree_idx, tree) -> begin
                           if haskey(visited_trees, tree)
                               visited_trees[tree] += 1
                           else
                               visited_trees[tree] = 1
                           end
                        end,
                        test_newick_str, "string", :newick)
    @test length(visited_trees) == length(test_trees_data)
    @test all(values(visited_trees) .== 1)
    # application_count = Dict{Symbol, Integer}()
    # n_trees_visited = 0
    # foreach(enumerate(trees_data)) do (tree_idx, tree_data)
    #     n_trees_visited += 1
    #     tree_str = tree_data["newick"]
    #     push!(visited_tree_strings, tree_str)
    #     DendroPy.map_trees(tree_str, "string", :newick) do tree
    #     end
    # end
    # @test length(tree_keys) == length(trees_data) == n_trees_visited
    # @test all(haskey.(Ref(application_count), tree_keys))
    # @test sort(collect(keys(application_count))) == sort(tree_keys)

    # # Some experiments in syntax
    # @test all((==).(values(application_count), 1))
    # @test all(x -> x == 1, values(application_count))
    # @test all(x == 1 for x in values(application_count))

end

