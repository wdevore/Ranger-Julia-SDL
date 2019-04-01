export CrossNode

using ..Nodes
    Node, AbstractNode

mutable struct CrossNode <: AbstractNode
    base::Node

    function CrossNode(id::UInt32, name::String, parent::AbstractNode)
        new(
            Node(id, name, parent)
        )
    end
end

