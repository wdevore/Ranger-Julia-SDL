
mutable struct SceneBoot <: Ranger.AbstractScene
    base::NodeData

    replacement::Ranger.AbstractScene

    function SceneBoot(world::Ranger.World, name::String, replacement::Ranger.AbstractScene)
        obj = new()

        obj.base = NodeData(gen_id(world), name, NodeNil())
        obj.replacement = replacement

        obj
    end
end

# --------------------------------------------------------
# Transitioning
# --------------------------------------------------------
function Ranger.Nodes.transition(node::SceneBoot)
    REPLACE_TAKE
end

function Ranger.Nodes.get_replacement(node::SceneBoot)
    node.replacement
end