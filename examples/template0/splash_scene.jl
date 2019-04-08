using .Ranger.Nodes:
    NodeData, NodeNil, NodeManager,
    AbstractScene,
    TransitionProperties, update, ready,
    register_target, unregister_target

using .Ranger.Nodes.Scenes:
    REPLACE_TAKE, NO_ACTION
    
using .Ranger:
    gen_id

using .Ranger.Engine:
    World

using .Ranger.Rendering:
    RenderContext,
    White,
    set_draw_color, draw_text

mutable struct SplashScene <: AbstractScene
    base::NodeData
    transitioning::TransitionProperties

    replacement::AbstractScene

    # transform::TransformProperties

    function SplashScene(world::World, name::String, replacement::AbstractScene)
        obj = new()

        # We use "obj" to represent a lack of parent.
        obj.base = NodeData(gen_id(world), name, NodeNil())
        # obj.transform = TransformProperties{Float64}()
        obj.replacement = replacement   # default to self/obj = No replacement present
        obj.transitioning = TransitionProperties()
        obj
    end
end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Ranger.Nodes.update(node::SplashScene, dt::Float64)
    # println("SplashScene::update : ", node)
    update(node.transitioning, dt);
end

# --------------------------------------------------------
# Visits
# --------------------------------------------------------
white = White()

function Ranger.Nodes.visit(node::SplashScene, context::RenderContext, interpolation::Float64)
    # println("SplashScene visit ", node);
    set_draw_color(context, white)
    draw_text(context, 10, 10, node.base.name, 3, 2, false)
end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function Ranger.Nodes.enter_node(node::SplashScene, man::NodeManager)
    println("enter ", node);
    # Register node as a timing target in order to receive updates
    register_target(man, node);
end

function Ranger.Nodes.exit_node(node::SplashScene, man::NodeManager)
    println("exit ", node);
    unregister_target(man, node);
end

function Ranger.Nodes.transition(node::SplashScene)
    if ready(node.transitioning)
        REPLACE_TAKE
    else
        NO_ACTION
    end
end

function Ranger.Nodes.get_replacement(node::SplashScene)
    node.replacement
end