
mutable struct GameLayer <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    # Collection of nodes.
    children::Array{Ranger.AbstractNode,1}

    min::Geometry.Point{Float64}
    max::Geometry.Point{Float64}
    buc_min::Geometry.Point{Float64}
    buc_max::Geometry.Point{Float64}

    out_rect::Custom.OutlinedRectangle
    angle::Float64
    solid_yellow_rect::Custom.AARectangle

    function GameLayer(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(gen_id(world), name, parent)
        o.children = Array{Ranger.AbstractNode,1}[]
        o.transform = Nodes.TransformProperties{Float64}()

        o.min = Geometry.Point{Float64}()
        o.max = Geometry.Point{Float64}()
        o.buc_min = Geometry.Point{Float64}()
        o.buc_max = Geometry.Point{Float64}()

        o.angle = 0.0

        o
    end
end

function build(layer::GameLayer, world::Ranger.World)
    hw = Float64(world.view_width) / 2.0
    hh = Float64(world.view_height) / 2.0

    # top-left
    Geometry.set!(layer.min, -hw, -hh)

    # bottom-right
    Geometry.set!(layer.max, hw, hh)

    solid_yellow_rect = Custom.AARectangle(world, "YellowAARectangle", layer)
    layer.solid_yellow_rect = solid_yellow_rect
    Custom.set_min!(solid_yellow_rect, 200.0, 200.0)
    Custom.set_max!(solid_yellow_rect, 400.0, 400.0)
    solid_yellow_rect.color = GameData.yellow
    push!(layer.children, solid_yellow_rect);
    
    layer.out_rect = Custom.OutlinedRectangle(world, "RedRectangle", layer)
    Custom.set!(layer.out_rect, -0.5, -0.5, 0.5, 0.5)
    Nodes.set_scale!(layer.out_rect, 100.0)
    Nodes.set_position!(layer.out_rect, -100.0, -100.0)
    layer.out_rect.color = GameData.red
    push!(layer.children, layer.out_rect);

    tri = Custom.OutlinedTriangle(world, "YellowTriangle", layer)
    Custom.set!(tri,
        Geometry.Point{Float64}(-0.5, 0.5),
        Geometry.Point{Float64}(0.5, 0.5),
        Geometry.Point{Float64}(0.0, -0.5))
    Nodes.set_scale!(tri, 50.0)
    Nodes.set_position!(tri, 100.0, -100.0)
    tri.color = GameData.yellow
    push!(layer.children, tri);
end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Nodes.update(layer::GameLayer, dt::Float64)
    # println("GameLayer::update : ", layer)
    layer.angle += 1.0
    Nodes.set_rotation_in_degrees!(layer.out_rect, layer.angle)
end

# --------------------------------------------------------
# Visits
# --------------------------------------------------------
# function Ranger.Nodes.visit(layer::GameLayer, context::RenderContext, interpolation::Float64)
#     # println("GameLayer visit ", layer);
# end

function Nodes.draw(layer::GameLayer, context::Rendering.RenderContext)
    # Transform this node's vertices using the context
    if Nodes.is_dirty(layer)
        Rendering.transform!(context, layer.min, layer.max, layer.buc_min, layer.buc_max)
        # Rendering.transform!(context, layer.mesh)
        Nodes.set_dirty!(layer, false)
    end

    Rendering.set_draw_color(context, GameData.darkgray)
    # Rendering.render_aa_rectangle(context, layer.mesh, Rendering.FILLED)
    Rendering.render_aa_rectangle(context, layer.buc_min, layer.buc_max, Rendering.FILLED);

    Rendering.set_draw_color(context, GameData.white)
    Rendering.draw_text(context, 10, 10, layer.base.name, 5, 4, false)
end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function Nodes.enter_node(layer::GameLayer, man::NodeManager)
    println("enter ", layer);
    # Register node as a timing target in order to receive updates
    Nodes.register_target(man, layer)
    Nodes.register_event_target(man, layer);
end

function Nodes.exit_node(layer::GameLayer, man::NodeManager)
    println("exit ", layer);
    Nodes.unregister_target(man, layer);
    Nodes.unregister_event_target(man, layer);
end

# --------------------------------------------------------
# Events
# --------------------------------------------------------
# Here we elect to receive keyboard events.
function Nodes.io_event(node::GameLayer, event::Events.KeyboardEvent)
    # println("io_event ", event, ", node: ", node)
    
    rect = node.solid_yellow_rect
    Nodes.set_position!(rect, rect.transform.position.x + 1.0, rect.transform.position.y)
    # node.angle += 1.0
    # Nodes.set_rotation_in_degrees!(node.out_rect, node.angle)
    # Nodes.set_position!(node, node.transform.position.x + 10.0, node.transform.position.y)
end

# --------------------------------------------------------
# Grouping
# --------------------------------------------------------
function Nodes.get_children(node::GameLayer)
    node.children
end
