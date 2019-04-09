import Base.show

export NodeData

mutable struct NodeData
    # Properties
    id::UInt32
    name::String
    visible::Bool
    dirty::Bool

    parent::Ranger.AbstractNode

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

    function NodeData(id::UInt32, name::String, parent::Ranger.AbstractNode)
        obj = NodeData(id, name)

        obj.parent = parent
        
        obj
    end
end

function Base.show(io::IO, node::NodeData)
    print(io, "|'", node.name, "' (", node.id, ")|");
end

