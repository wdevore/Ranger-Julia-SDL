export SplashScene, transition

using .Ranger.Nodes:
    NodeData, NodeNil, AbstractNode, NodeManager,
    AbstractScene

using .Ranger.Nodes.Scenes:
    REPLACE_TAKE
    
using .Ranger:
    gen_id

using .Ranger.Engine:
    World

mutable struct SplashScene <: AbstractScene
    base::NodeData

    replacement::AbstractScene

    # transform::TransformProperties

    function SplashScene(world::World, name::String, replacement::AbstractScene)
        obj = new()

        # We use "obj" to represent a lack of parent.
        obj.base = NodeData(gen_id(world), name, NodeNil())
        # obj.transform = TransformProperties{Float64}()
        obj.replacement = replacement   # default to self/obj = No replacement present

        obj
    end
end

# --------------------------------------------------------
# Visits
# --------------------------------------------------------
function Ranger.Nodes.visit(node::SplashScene, man::NodeManager, interpolation::Float64)
    println("SplashScene visit ", node);
end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function Ranger.Nodes.enter_node(node::SplashScene)
    println("enter ", node);
end

function Ranger.Nodes.exit_node(node::SplashScene)
    println("exit ", node);
end

function Ranger.Nodes.transition(node::SplashScene)
    REPLACE_TAKE
end

function Ranger.Nodes.get_replacement(node::SplashScene)
    node.replacement
end