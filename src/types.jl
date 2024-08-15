using AbstractTrees
# using PyCall
using PythonCall
const WrappedPythonType = PythonCall.Core.Py

struct TreeNode{T<:WrappedPythonType}
  tree::T
  data::T
  children::Vector{TreeNode{T}}
end

AbstractTrees.children(n::TreeNode) = n.children
AbstractTrees.printnode(io::IO, node::TreeNode) = print(io, node.data)
Base.show(io::IO, n::TreeNode) = print(io, n.data)

# root = Node(1, [Node(2, [Node(5, [Node(9), Node(10)]), Node(6)]), Node(3)]);
# print_tree(root)
# print(reverse(collect(AbstractTrees.StatelessBFS(root))))

