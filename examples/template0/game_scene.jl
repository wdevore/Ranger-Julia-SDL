export SplashScene

using .Ranger.Nodes:
    NodeData, NodeNil, AbstractNode

using .Ranger.Nodes.Scenes:
    AbstractScene, SceneActions, SceneNil

using .Ranger:
    gen_id

using .Ranger.Game:
    World

using .Ranger.Rendering:
    RenderContext

mutable struct GameScene <: AbstractScene
    base::NodeData

    replacement::AbstractScene

    # children::

    function GameScene(world::World, name::String)
        obj = new()

        # We use "obj" to represent a lack of parent.
        obj.base = NodeData(gen_id(world), name, NodeNil())
        # obj.transform = TransformProperties{Float64}()
        obj.replacement = SceneNil()

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
function enter_node(node::GameScene)
    println("enter ", node);
end

function exit_node(node::GameScene)
    println("exit ", node);
end

function transition(node::GameScene)
    REPLACE_TAKE
end

function get_replacement(node::GameScene)
    node.replacement
end