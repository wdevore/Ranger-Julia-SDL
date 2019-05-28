import Base.show

export NodeData

mutable struct NodeData
    # Properties
    id::UInt32
    name::String
    visible::Bool
    dirty::Bool
    world::Ranger.World

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

    function NodeData(name::String, parent::Ranger.AbstractNode, world::Ranger.World)
        obj = NodeData(Ranger.gen_id(world), name)

        obj.parent = parent
        obj.world = world
        obj
    end
end

function Base.show(io::IO, node::NodeData)
    print(io, "|'", node.name, "' (", node.id, ")|");
end

