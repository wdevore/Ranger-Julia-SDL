export SceneBoot

export transition, get_replacement

using ..Nodes:
    NodeData, NodeNil, AbstractScene

using .Scenes:
    REPLACE_TAKE

using ...Ranger:
    World, gen_id

mutable struct SceneBoot <: AbstractScene
    base::NodeData

    replacement::AbstractScene

    function SceneBoot(world::World, name::String, replacement::AbstractScene)
        obj = new()

        obj.base = NodeData(gen_id(world), name, NodeNil())
        obj.replacement = replacement

        obj
    end
end

# --------------------------------------------------------
# Transitioning
# --------------------------------------------------------
function Nodes.transition(node::SceneBoot)
    REPLACE_TAKE
end

function Nodes.get_replacement(node::SceneBoot)
    node.replacement
end