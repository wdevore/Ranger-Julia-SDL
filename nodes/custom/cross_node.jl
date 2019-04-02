export CrossNode

using ..Nodes:
    NodeData, AbstractNode

mutable struct CrossNode <: AbstractNode
    base::NodeData

    function CrossNode(id::UInt32, name::String, parent::AbstractNode)
        new(
            NodeData(id, name, parent)
        )
    end
end

