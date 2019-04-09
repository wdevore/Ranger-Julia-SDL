
mutable struct SplashScene <: Ranger.AbstractScene
    base::NodeData
    transform::TransformProperties{Float64}
    transitioning::TransitionProperties

    replacement::Ranger.AbstractScene

    mesh::Geometry.Mesh

    function SplashScene(world::Ranger.World, name::String, replacement::Ranger.AbstractScene)
        obj = new()

        # We use "obj" to represent a lack of parent.
        obj.base = NodeData(gen_id(world), name, NodeNil())
        # obj.transform = TransformProperties{Float64}()
        obj.replacement = replacement   # default to self/obj = No replacement present
        obj.transitioning = TransitionProperties()
        obj.transform = TransformProperties{Float64}()
        obj.mesh = Geometry.Mesh()

        obj
    end
end

function build(node::SplashScene, world::Ranger.World)
    Geometry.add_vertex!(node.mesh, -0.1, -0.1)  # top-left
    Geometry.add_vertex!(node.mesh, 1.1, 1.1)   # bottom-right

    Geometry.build_it!(node.mesh)
end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Ranger.Nodes.update(node::SplashScene, dt::Float64)
    update(node.transitioning, dt);
end

# --------------------------------------------------------
# Visits
# --------------------------------------------------------
function Ranger.Nodes.draw(node::SplashScene, context::Rendering.RenderContext)
    if is_dirty(node)
        # Transform this node's vertices using the context
        Rendering.transform!(context, node.mesh)
        println(context.current)
        println(node.mesh.vertices)
        println(node.mesh.bucket)
        set_dirty!(node, false)
    end

    # Draw background
    Rendering.render_checkerboard(context, node.mesh)

    Rendering.set_draw_color(context, GameData.white)
    Rendering.draw_text(context, 10, 10, node.base.name, 2, 2, false);
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
    # if ready(node.transitioning)
    #     REPLACE_TAKE
    # else
    NO_ACTION
    # end
end

function Ranger.Nodes.get_replacement(node::SplashScene)
    node.replacement
end