
mutable struct GameLayer <: AbstractNode
    base::NodeData
    transform::TransformProperties{Float64}

    # Collection of nodes.
    children::Array{AbstractNode,1}

    mesh::Mesh

    function GameLayer(world::World, name::String, parent::AbstractNode)
        obj = new()

        obj.base = NodeData(gen_id(world), name, parent)
        obj.children = Array{AbstractNode,1}[]
        obj.transform = TransformProperties{Float64}()
        obj.mesh = Mesh()

        obj
    end
end

function build(layer::GameLayer, world::World)
    add_vertex!(layer.mesh, -0.5, -0.5)  # top-left
    add_vertex!(layer.mesh, 0.5, 0.5)   # bottom-right

    build_it!(layer.mesh)

    set_nonuniform_scale!(layer, world.view_width, world.view_height);
end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Ranger.Nodes.update(layer::GameLayer, dt::Float64)
    # println("GameLayer::update : ", layer)
end

# --------------------------------------------------------
# Visits
# --------------------------------------------------------
# function Ranger.Nodes.visit(layer::GameLayer, context::RenderContext, interpolation::Float64)
#     # println("GameLayer visit ", layer);
# end

function Ranger.Nodes.draw(layer::GameLayer, context::RenderContext)
    # Transform this node's vertices using the context
    if is_dirty(layer)
        # println("GameLayer::draw DIRTY", layer);
        transform!(context, layer.mesh)
        set_dirty!(layer, false)
    end

    set_draw_color(context, darkgray)
    render_aa_rectangle(context, layer.mesh, FILLED)

    set_draw_color(context, white)
    draw_text(context, 10, 10, layer.base.name, 2, 2, false)
end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function Ranger.Nodes.enter_node(layer::GameLayer, man::NodeManager)
    println("enter ", layer);
    # Register node as a timing target in order to receive updates
    register_target(man, layer)
    register_event_target(man, layer);
end

function Ranger.Nodes.exit_node(layer::GameLayer, man::NodeManager)
    println("exit ", layer);
    unregister_target(man, layer);
    unregister_event_target(man, layer);
end

# --------------------------------------------------------
# Events
# --------------------------------------------------------
# Here we elect to receive keyboard events.
function Ranger.Nodes.io_event(node::GameLayer, event::KeyboardEvent)
    println("io_event ", event)
    
    # set_position!(node, node.transform.position.x + 10.0, node.transform.position.y)
end
