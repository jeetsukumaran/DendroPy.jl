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

function enumerate_map_trees(transform_fn::Function, source::AbstractString, source_type::AbstractString, format::Symbol)
    schema = String(format)
    trees = if source_type == "filepath"
        dendropy.TreeList.get(path=source, schema=schema, rooting="force-rooted")
    elseif source_type == "file"
        dendropy.TreeList.get(file=source, schema=schema, rooting="force-rooted")
    elseif source_type == "string"
        dendropy.TreeList.get(data=source, schema=schema, rooting="force-rooted")
    else
        throw(ArgumentError("Invalid source_type: $source_type. Must be one of 'filepath', 'file', or 'string'."))
    end
    return [transform_fn(tree_idx, tree) for (tree_idx, tree) in enumerate(trees)]
end

function map_trees(transform_fn::Function, args...)
    return enumerate_map_trees( (tree_idx, tree) -> transform_fn(tree), args... )
end

function abstract_tree(start_node::PyCall.PyObject)
    if haskey(start_node, :seed_node)
        start_node = start_node.seed_node
    end
    abstract_node = Node(
        start_node,
        Node{typeof(start_node)}[abstract_tree(child_node) for child_node in start_node.child_nodes()],
    )
    return abstract_node
end

function postorder_iter(start_node::Node)
    return AbstractTrees.PostOrderDFS(start_node)
end
function postorder_iter(start_node::PyCall.PyObject)
    return postorder_iter(abstract_tree(start_node))
end
function postorder_map(fn::Function, start_node::PyCall.PyObject)
    map(postorder_iter(abstract_tree(start_node))) do node
        return fn(node)
    end
end

function preorder_iter(start_node::Node)
    return AbstractTrees.PreOrderDFS(start_node)
end
function preorder_iter(tree::PyCall.PyObject)
    return preorder_iter(abstract_tree(tree))
end
function preorder_map(fn::Function, start_node::PyCall.PyObject)
    map(preorder_iter(abstract_tree(start_node))) do node
        return fn(node)
    end
end

function edge_length(node::Node)
    return node.data.edge.length
end
function label(node::Node)
    return node.data.taxon === nothing ? node.data.label : node.data.taxon.label
end
function age(node::Node)
    return node.data.age
end


# function abstract_trees_from_file(filepath::AbstractString, format::Symbol)
# end

# function abstract_trees_from_file(filepath::AbstractString, format::Symbol)
# end

end
