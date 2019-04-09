export AARectangle

mutable struct AARectangle <: Ranger.AbstractNode
    base::Nodes.NodeData

    function AARectangle(id::UInt32, name::String, parent::Ranger.AbstractNode)
        new(NodeData(id, name, parent))
    end
end

