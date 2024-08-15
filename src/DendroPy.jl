module DendroPy

export
    postorder_iter,
    postorder_map,
    preorder_iter,
    preorder_map,
    enumerate_map_tree_source,
    map_tree_source,
    abstract_tree,
    dendropy,
    install_dendropy

import PythonCall
import Logging

include("types.jl")

# const dendropy = PyCall.PyNULL()
const dendropy_ref = Ref{WrappedPythonType}()

function install_dendropy()
    @info("Attempting to install DendroPy Python package from the development-main branch.")
    # Use Conda.jl or the user's existing Python environment to install DendroPy
    run(`pip install git+https://github.com/jeetsukumaran/DendroPy@development-main`)
    # copy!(dendropy, PyCall.pyimport("dendropy"))
    dendropy_ref[] = PythonCall.pyimport("dendropy")
end

function __init__()
    try
        dendropy_ref[] = PythonCall.pyimport("dendropy")
    catch e
        # if true # isa(e, PyCall.PyError)
        if true # isa(e, PythonCall.Core.PyException)
            @info "DendroPy package not found. Installing..."
            install_dendropy()
        else
            rethrow(e)
        end
    end
end

dendropy = () -> dendropy_ref[]
# dendropy = PythonCall.pyimport("dendropy")

# function divergence_times_from_dendropy_tree(
#     tree,
#     is_include_leaves::Bool = false,
# )
#     nd_ages = Dict{typeof(tree.seed_node), Float64}()
#     nd_key = (nd) -> nd
#     for cnd in tree.preorder_node_iter()
#         cnd_key = nd_key(cnd)
#         node_edge_length = (cnd.edge != nothing && cnd.edge.length != nothing) ? cnd.edge.length : 0.0
#         if (cnd.parent_node != nothing)
#         elseif (is_include_leaves || !cnd.is_leaf())
#             nd_ages[cnd_key] = node_edge_length
#         end
#     end
#     return values(nd_ages)
# end

function enumerate_map_tree_source(transform_fn::Function, source::AbstractString, source_type::AbstractString, format::Symbol)
    dp = PythonCall.pyimport("dendropy")
    schema = String(format)
    trees = if source_type == "filepath"
        dp.TreeList.get(path=source, schema=schema, rooting="force-rooted")
    elseif source_type == "file"
        dp.TreeList.get(file=source, schema=schema, rooting="force-rooted")
    elseif source_type == "string"
        dp.TreeList.get(data=source, schema=schema, rooting="force-rooted")
    else
        throw(ArgumentError("Invalid source_type: $source_type. Must be one of 'filepath', 'file', or 'string'."))
    end
    return [transform_fn(tree_idx, tree) for (tree_idx, tree) in enumerate(trees)]
end

function map_tree_source(transform_fn::Function, args...)
    return enumerate_map_tree_source( (tree_idx, tree) -> transform_fn(tree), args... )
end

function abstract_tree(start_node::WrappedPythonType)
    # # if haskey(start_node, :seed_node) # PyCall
    if hasproperty(start_node, "seed_node")
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
function postorder_iter(tree::WrappedPythonType)
    return postorder_iter(abstract_tree(tree))
end
function postorder_map(fn::Function, tree::WrappedPythonType)
    map(postorder_iter(abstract_tree(tree))) do node
        return fn(node)
    end
end

function preorder_iter(start_node::Node)
    return AbstractTrees.PreOrderDFS(start_node)
end
function preorder_iter(tree::WrappedPythonType)
    return preorder_iter(abstract_tree(tree))
end
function preorder_map(fn::Function, tree::WrappedPythonType)
    map(preorder_iter(abstract_tree(tree))) do node
        return fn(node)
    end
end

function edge_length(node::Node)
    return node.data.edge.length
end
function label(node::Node)
    return node.data.taxon == nothing ? node.data.label : node.data.taxon.label
end
function age(node::Node)
    return node.data.age
end

function coalescence_ages(tree::WrappedPythonType)
    tree.resolve_node_ages()
    return sort([nd.age for nd in tree.internal_nodes()])
end

function divergence_times(tree::WrappedPythonType)
    tree.resolve_node_depths()
    return sort([nd.depth for nd in tree.internal_nodes()])
end

end

