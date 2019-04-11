
mutable struct SceneBoot <: Ranger.AbstractScene
    base::Nodes.NodeData

    replacement::Ranger.AbstractScene

    function SceneBoot(world::Ranger.World, name::String, replacement::Ranger.AbstractScene)
        obj = new()

        obj.base = Nodes.NodeData(gen_id(world), name, Nodes.NodeNil())
        obj.replacement = replacement

        obj
    end
end

# --------------------------------------------------------
# Transitioning
# --------------------------------------------------------
function Nodes.transition(node::SceneBoot)
    Scenes.REPLACE_TAKE
end

function Nodes.get_replacement(node::SceneBoot)
    node.replacement
end