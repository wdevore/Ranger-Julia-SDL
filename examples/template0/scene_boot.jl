
mutable struct SceneBoot <: Ranger.AbstractScene
    base::Nodes.NodeData

    replacement::Ranger.AbstractScene

    function SceneBoot(world::Ranger.World, name::String, replacement::Ranger.AbstractScene)
        obj = new()

        obj.base = Nodes.NodeData(name, Nodes.NodeNil(), world)
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