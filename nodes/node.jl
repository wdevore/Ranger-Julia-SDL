import Base.show

export NodeData, NodeNil, is_nil

mutable struct NodeData
    # Properties
    id::UInt32
    name::String
    visible::Bool
    dirty::Bool

    parent::AbstractNode

    function NodeData()
        NodeData(UInt32(0), "_NoName_")
    end

    function NodeData(id::UInt32, name::String)
        obj = new()

        obj.id = id
        obj.name = name
        obj.visible = true
        obj.dirty = true

        obj.parent = NodeNil()    # default to self
        
        obj
    end

    function NodeData(id::UInt32, name::String, parent::AbstractNode)
        obj = NodeData(id, name)
        # obj.transform = TransformProperties{Float64}()

        obj.parent = parent
        obj
    end
end

struct NodeNil <: AbstractNode
    id::UInt32
    name::String

    function NodeNil()
        new(0, "_Nil_")
    end
end

function is_nil(node::AbstractNode)
    node.id == 0
end

function Base.show(io::IO, node::NodeData)
    print(io, "'", node.name, "' (", node.id, ")");
end

