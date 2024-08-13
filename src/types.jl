using AbstractTrees

struct Node{T}
  data::T
  children::Vector{Node{T}}
end

Node(data::T) where T = Node(data, Node{T}[])

AbstractTrees.children(n::Node) = n.children
AbstractTrees.printnode(io::IO, node::Node) = print(io, node.data)
Base.show(io::IO, n::Node) = print(io, n.data)

# root = Node(1, [Node(2, [Node(5, [Node(9), Node(10)]), Node(6)]), Node(3)]);
# print_tree(root)
# print(reverse(collect(AbstractTrees.StatelessBFS(root))))

