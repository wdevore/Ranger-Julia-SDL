export SceneBoot

export transition, get_replacement

using ..Nodes:
    Node

using .Scenes:
    AbstractScene, SceneActions

using ...Ranger:
    gen_id

using ...Ranger:
    World 

using ...Rendering:
    RenderContext

mutable struct SceneBoot <: AbstractScene
    base::Node

    replacement::AbstractScene

    function SceneBoot(world::World, name::String, replacement::AbstractScene)
        obj = new()

        # We use "obj" to represent a lack of parent.
        obj.base = Node(gen_id(world), name, obj)
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