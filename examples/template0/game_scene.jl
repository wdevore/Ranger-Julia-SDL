export SplashScene

using .Ranger.Nodes:
    NodeData, SceneNil, AbstractNode, NodeManager,
    AbstractScene

using .Ranger.Nodes.Scenes:
    NO_ACTION

using .Ranger:
    gen_id

using .Ranger.Engine:
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
function Ranger.Nodes.visit(node::GameScene, context::RenderContext, interpolation::Float64)
    # println("GameScene visit ", node);
end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function Ranger.Nodes.enter_node(node::GameScene, man::NodeManager)
    println("enter ", node);
end

function Ranger.Nodes.exit_node(node::GameScene, man::NodeManager)
    println("exit ", node);
end

function Ranger.Nodes.transition(node::GameScene)
    NO_ACTION
end

function Ranger.Nodes.get_replacement(node::GameScene)
    node.replacement
end