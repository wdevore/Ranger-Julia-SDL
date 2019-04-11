
mutable struct SplashScene <: Ranger.AbstractScene
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}
    transitioning::Nodes.TransitionProperties

    replacement::Ranger.AbstractScene

    mesh::Geometry.Mesh

    function SplashScene(world::Ranger.World, name::String, replacement::Ranger.AbstractScene)
        obj = new()

        # We use "obj" to represent a lack of parent.
        obj.base = Nodes.NodeData(gen_id(world), name, Nodes.NodeNil())
        obj.replacement = replacement   # default to self/obj = No replacement present
        obj.transitioning = Nodes.TransitionProperties()
        obj.transform = Nodes.TransformProperties{Float64}()
        obj.mesh = Geometry.Mesh()

        obj
    end
end

function build(node::SplashScene, world::Ranger.World)
    # The splash scene doesn't not have a transform (aka translate + scale)
    # applied to it so we build the mesh using view-space coordinates
    y = -Float64(world.view_height) / 2.0
    w = 320

    # Construct a checker board grid of rectangles.
    while y <= world.view_height
        x = -Float64(world.view_width) / 2.0
        while x <= world.view_width
            Geometry.add_vertex!(node.mesh, x, y)  # top-left
            Geometry.add_vertex!(node.mesh, x + w, y + w)   # bottom-right
            x += w
        end
        y += w
    end

    Geometry.build!(node.mesh)
end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Nodes.update(node::SplashScene, dt::Float64)
    update(node.transitioning, dt);
end

# --------------------------------------------------------
# Visits
# --------------------------------------------------------
function Nodes.draw(node::SplashScene, context::Rendering.RenderContext)
    if Nodes.is_dirty(node)
        # Transform this node's vertices using the context
        Rendering.transform!(context, node.mesh)
        Nodes.set_dirty!(node, false)
    end

    # Draw background
    Rendering.render_checkerboard(context, node.mesh, RangerGame.darkgray, RangerGame.lightgray)

    Rendering.set_draw_color(context, RangerGame.white)
    Rendering.draw_text(context, 10, 10, node.base.name, 2, 2, false);
end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function Nodes.enter_node(node::SplashScene, man::Nodes.NodeManager)
    println("enter ", node);
    # Register node as a timing target in order to receive updates
    Nodes.register_target(man, node);
end

function Nodes.exit_node(node::SplashScene, man::Nodes.NodeManager)
    println("exit ", node);
    Nodes.unregister_target(man, node);
end

function Nodes.transition(node::SplashScene)
    if Nodes.ready(node.transitioning)
        Scenes.REPLACE_TAKE
    else
        Scenes.NO_ACTION
    end
end

function Nodes.get_replacement(node::SplashScene)
    node.replacement
end