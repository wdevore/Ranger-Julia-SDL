using Printf

mutable struct GameLayer <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    # Collection of nodes.
    children::Array{Ranger.AbstractNode,1}

    min::Geometry.Point{Float64}
    max::Geometry.Point{Float64}
    buc_min::Geometry.Point{Float64}
    buc_max::Geometry.Point{Float64}

    orbit_system::OrbitSystemNode
    yellow_rect::Custom.OutlinedRectangle

    device_point::Geometry.Point{Float64}
    local_point::Geometry.Point{Float64}
    aabb::Geometry.AABB{Float64}
    inside_rect::Bool

    function GameLayer(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(gen_id(world), name, parent)
        o.children = Array{Ranger.AbstractNode,1}[]
        o.transform = Nodes.TransformProperties{Float64}()

        o.min = Geometry.Point{Float64}()
        o.max = Geometry.Point{Float64}()
        o.buc_min = Geometry.Point{Float64}()
        o.buc_max = Geometry.Point{Float64}()

        o.device_point = Geometry.Point{Float64}()
        o.local_point = Geometry.Point{Float64}()
        o.aabb = Geometry.AABB{Float64}()
        o.inside_rect = false

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

    layer.orbit_system = OrbitSystemNode(world, "OrbitSystemNode", layer)
    build(layer.orbit_system, world)
    set!(layer.orbit_system, -0.5, -0.5, 0.5, 0.5)
    Nodes.set_scale!(layer.orbit_system, 100.0)
    Nodes.set_position!(layer.orbit_system, 100.0, -100.0)
    layer.orbit_system.color = RangerGame.red
    push!(layer.children, layer.orbit_system);

    rect = Custom.OutlinedRectangle(world, "YellowOutlinedRectangle", layer)
    layer.yellow_rect = rect
    Custom.set!(rect, -0.5, -0.5, 0.5, 0.5) # centered
    Nodes.set_scale!(rect, 200.0)
    Nodes.set_position!(rect, -300.0, 300.0)
    Nodes.set_rotation_in_degrees!(rect, 30.0)
    rect.color = RangerGame.yellow
    push!(layer.children, rect);
end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Nodes.update(layer::GameLayer, dt::Float64)
    # println("GameLayer::update : ", layer)
    inside = Geometry.is_point_inside(layer.yellow_rect.polygon, layer.local_point)
    layer.inside_rect = inside
end

# --------------------------------------------------------
# Visits
# --------------------------------------------------------
# function Ranger.Nodes.visit(layer::GameLayer, context::RenderContext, interpolation::Float64)
#     # println("GameLayer visit ", layer);
# end

function Nodes.draw(layer::GameLayer, context::Rendering.RenderContext)
    if Nodes.is_dirty(layer)
        Rendering.transform!(context, layer.min, layer.max, layer.buc_min, layer.buc_max)
        Nodes.set_dirty!(layer, false)
    end

    # Render background (i.e. a solid gray color)
    Rendering.set_draw_color(context, RangerGame.darkgray)
    Rendering.render_aa_rectangle(context, layer.buc_min, layer.buc_max, Rendering.FILLED)

    # Draw debug layer name
    Rendering.set_draw_color(context, RangerGame.white)
    Rendering.draw_text(context, 10, 10, layer.base.name, 2, 2, false)

    # Map device/mouse coords to local-space of node.
    Nodes.map_device_to_node!(context, Int32(layer.device_point.x), Int32(layer.device_point.y),
        layer.yellow_rect, layer.local_point)

    # Draw debug local-space coords
    Rendering.set_draw_color(context, RangerGame.lime)
    text = @sprintf("L: %2.4f, %2.4f", layer.local_point.x, layer.local_point.y)
    Rendering.draw_text(context, 10, 70, text, 2, 2, false)

    # Draw AABB box around yellow triangle
    if layer.inside_rect
        Rendering.set_draw_color(context, RangerGame.lime)
    else
        Rendering.set_draw_color(context, RangerGame.red)
    end
    Geometry.expand!(layer.aabb, Nodes.get_bucket(layer.yellow_rect))
    Rendering.render_aabb_rectangle(context, layer.aabb)
end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function Nodes.enter_node(layer::GameLayer, man::Nodes.NodeManager)
    println("enter ", layer);
    # Register node as a timing target in order to receive updates
    Nodes.register_target(man, layer)
    Nodes.register_event_target(man, layer);
end

function Nodes.exit_node(layer::GameLayer, man::Nodes.NodeManager)
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
    
    # tnode = node.orbit_system
    # Nodes.set_position!(tnode, tnode.transform.position.x + 5.0, tnode.transform.position.y)
end

function Nodes.io_event(node::GameLayer, event::Events.MouseEvent)
    # println("io_event ", event, ", node: ", node)
    Geometry.set!(node.device_point, Float64(event.x), Float64(event.y))
    # tnode = node.orbit_system
    # Nodes.set_position!(tnode, tnode.transform.position.x + 5.0, tnode.transform.position.y)
end

# --------------------------------------------------------
# Grouping
# --------------------------------------------------------
function Nodes.get_children(node::GameLayer)
    node.children
end
