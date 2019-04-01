export SplashScene

using .Ranger.Nodes:
    Node, AbstractNode

using .Ranger.Nodes.Scenes:
    AbstractScene, SceneActions

using .Ranger:
    gen_id

using .Ranger.Game:
    World

using .Ranger.Rendering:
    RenderContext

mutable struct GameScene <: AbstractScene
    base::Node

    replacement::AbstractScene

    # transform::TransformProperties

    function GameScene(world::World, name::String)
        obj = new()

        # We use "obj" to represent a lack of parent.
        obj.base = Node(gen_id(world), name, obj)
        # obj.transform = TransformProperties{Float64}()
        obj.replacement = obj   # default to self/obj = No replacement present

        obj
    end
end

# --------------------------------------------------------
# Visits
# --------------------------------------------------------
function visit(node::GameScene, context::RenderContext, interpolation::Float64)
    println("visit ", node);
end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function enter(node::GameScene)
    println("enter ", node);
end

function exit(node::GameScene)
    println("exit ", node);
end

function transition(node::GameScene)
    REPLACE_TAKE
end

function get_replacement(node::GameScene)
    node.replacement
end