# export NodeNil, is_nil

# import .Nodes.is_nil

# This node is used mostly for tests
mutable struct TrivialNode <: Ranger.AbstractNode
    id::UInt32
    name::String

    # NOTE A test field
    transform::Nodes.TransformProperties{Float64}

    function TrivialNode()
        o = new()
        o.id = 0
        o.name = "TrivialNode"
        o.transform = Nodes.TransformProperties{Float64}()
        o
    end
end

