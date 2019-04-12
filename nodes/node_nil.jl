export NodeNil, is_nil

import .Nodes.is_nil

struct NodeNil <: Ranger.AbstractNode
    id::UInt32
    name::String

    function NodeNil()
        new(0, "_Nil_")
    end
end

function is_nil(node::NodeNil)
    node.id == 0
end


