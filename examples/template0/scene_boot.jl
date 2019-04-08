using .Ranger.Nodes:
    NodeData, NodeNil, AbstractNode,
    AbstractScene

using .Ranger.Nodes.Scenes:
    REPLACE_TAKE
    
using .Ranger:
    gen_id

using .Ranger.Engine:
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
function Ranger.Nodes.transition(node::SceneBoot)
    REPLACE_TAKE
end

function Ranger.Nodes.get_replacement(node::SceneBoot)
    node.replacement
end