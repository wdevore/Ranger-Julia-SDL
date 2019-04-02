export SceneBoot

export transition, get_replacement

using ..Nodes:
    NodeData, NodeNil

using .Scenes:
    AbstractScene, SceneActions

using ...Ranger:
    gen_id

using ...Ranger:
    World 

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
function transition(node::SceneBoot)
    REPLACE_TAKE
end

function get_replacement(node::SceneBoot)
    node.replacement
end