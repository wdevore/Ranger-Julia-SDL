import Base.show

export Node, AbstractNode
export has_parent

abstract type AbstractNode end

mutable struct Node <: AbstractNode
    # Properties
    id::UInt32
    name::String
    visible::Bool
    dirty::Bool

    parent::AbstractNode

    function Node()
        Node(UInt32(0), "_NoName_")
    end

    function Node(id::UInt32, name::String)
        obj = new()

        obj.id = id
        obj.name = name
        obj.visible = true
        obj.dirty = true

        obj.parent = obj    # default to self
        
        obj
    end

    function Node(id::UInt32, name::String, parent::AbstractNode)
        obj = Node(id, name)
        # obj.transform = TransformProperties{Float64}()

        obj.parent = parent
        obj
    end
end

function Base.show(io::IO, node::Node)
    print(io, "'", node.name, "' (", node.id, ")");
end

