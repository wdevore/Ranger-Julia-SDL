export AARectangle

mutable struct AARectangle <: AbstractNode
    base::NodeData

    function AARectangle(id::UInt32, name::String, parent::AbstractNode)
        new(NodeData(id, name, parent))
    end
end

