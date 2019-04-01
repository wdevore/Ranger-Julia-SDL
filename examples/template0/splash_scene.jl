export SplashScene

using .Ranger.Nodes:
    Node, AbstractNode, NodeManager

using .Ranger.Nodes.Scenes:
    AbstractScene, SceneActions

using .Ranger:
    gen_id

using .Ranger.Game:
    World

mutable struct SplashScene <: AbstractScene
    base::Node

    replacement::AbstractScene

    # transform::TransformProperties

    function SplashScene(world::World, name::String, replacement::AbstractScene)
        obj = new()

        # We use "obj" to represent a lack of parent.
        obj.base = Node(gen_id(world), name, obj)
        # obj.transform = TransformProperties{Float64}()
        obj.replacement = replacement   # default to self/obj = No replacement present

        obj
    end
end

# --------------------------------------------------------
# Visits
# --------------------------------------------------------
function visit(node::SplashScene, man::NodeManager, interpolation::Float64)
    println("visit ", node);
end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function enter(node::SplashScene)
    println("enter ", node);
end

function exit(node::SplashScene)
    println("exit ", node);
end

function transition(node::SplashScene)
    REPLACE_TAKE
end

function get_replacement(node::SplashScene)
    node.replacement
end