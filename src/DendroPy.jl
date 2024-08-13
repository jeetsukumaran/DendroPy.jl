module DendroPy

export dendropy,
    divergence_times_from_dendropy_tree

import PyCall

include("types.jl")

const dendropy = PyCall.PyNULL()

function __init__()
    copy!(dendropy, PyCall.pyimport("dendropy"))
end

function divergence_times_from_dendropy_tree(
    tree,
    is_include_leaves::Bool = false,
)
    nd_ages = Dict{typeof(tree.seed_node), Float64}()
    # nd_ages = Dict{Int64, Float64}()
    # nd_key = (nd) -> PyCall.py"""id($nd)"""
    nd_key = (nd) -> nd
    for cnd in tree.preorder_node_iter()
        cnd_key = nd_key(cnd)
        node_edge_length = (cnd.edge != nothing && cnd.edge.length != nothing) ? cnd.edge.length : 0.0
        if (cnd.parent_node != nothing)
        #     nd_ages[cnd_key] = nd_ages[nd_key(cnd.parent_node)] + node_edge_length
        elseif (is_include_leaves || !cnd.is_leaf())
            nd_ages[cnd_key] = node_edge_length
        end
    end
    return values(nd_ages)
end

function map_trees(transform_fn::Function, source::AbstractString, source_type::AbstractString, format::Symbol)
    schema = String(format)
    if transform_fn === nothing
        transform_fn = (tree) -> tree
    end
    trees = if source_type == "filepath"
        dendropy.TreeList.get(path=source, schema=schema)
    elseif source_type == "file"
        dendropy.TreeList.get(file=source, schema=schema)
    elseif source_type == "string"
        dendropy.TreeList.get(data=source, schema=schema)
    else
        throw(ArgumentError("Invalid source_type: $source_type. Must be one of 'filepath', 'file', or 'string'."))
    end
    return (transform_fn(tree) for tree in trees)
end

# function abstract_trees_from_file(filepath::AbstractString, format::Symbol)
# end

# function abstract_trees_from_file(filepath::AbstractString, format::Symbol)
# end

end
