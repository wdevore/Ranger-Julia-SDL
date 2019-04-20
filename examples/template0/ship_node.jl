# This node is made up of a circle and 2 rectangles
export Ship

include("keystate.jl")

mutable struct Ship <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    # Collection for overlays
    children::Array{Ranger.AbstractNode,1}

    # Colors
    color::Rendering.Palette

    # Geometry for each component
    disc::Geometry.Polygon
    left_cell::Geometry.Polygon
    right_cell::Geometry.Polygon

    # Total AABB
    aabb::Geometry.AABB{Float64}

    # Hit detection for both projectiles and dragging
    det_disc::Nodes.Detection
    det_left::Nodes.Detection
    det_right::Nodes.Detection

    keystate::KeyState
    thrust_angle::Float64
    turning_rate::Float64  # degrees/second
    thrust_line::Custom.LineNode

    function Ship(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(gen_id(world), name, parent)
        o.transform = Nodes.TransformProperties{Float64}()
        o.children = Array{Ranger.AbstractNode,1}[]
        o.color = Rendering.White()

        o.aabb = Geometry.AABB{Float64}()

        o.disc = Geometry.Polygon{Float64}()
        o.det_disc = Nodes.Detection(Rendering.Yellow(), Rendering.Red())

        o.left_cell = Geometry.Polygon{Float64}()
        o.det_left = Nodes.Detection(Rendering.Yellow(), Rendering.Red())

        o.right_cell = Geometry.Polygon{Float64}()
        o.det_right = Nodes.Detection(Rendering.Yellow(), Rendering.Red())

        o.keystate = KeyState(false, false, Int8(0))

        build(o, world)
        o
    end
end

function build(node::Ship, world::Ranger.World)
    segment_size = 36
        
    # Build Geometry. Disc has radius of 1.0
    for degree in 0.0:segment_size:360.0
        Geometry.add_vertex!(node.disc, cos(deg2rad(degree)), sin(deg2rad(degree)))
    end
    Geometry.build!(node.disc)

    # Left cell vertically narrow
    Geometry.add_vertex!(node.left_cell, -0.75, 0.0)
    Geometry.add_vertex!(node.left_cell, -0.75, 1.7)
    Geometry.add_vertex!(node.left_cell, -0.30, 1.7)
    Geometry.add_vertex!(node.left_cell, -0.30, 0.0)
    Geometry.build!(node.left_cell)

    # right cell vertically narrow
    Geometry.add_vertex!(node.right_cell, 0.30, 0.0)
    Geometry.add_vertex!(node.right_cell, 0.30, 1.7)
    Geometry.add_vertex!(node.right_cell, 0.75, 1.7)
    Geometry.add_vertex!(node.right_cell, 0.75, 0.0)
    Geometry.build!(node.right_cell)
    
    node.det_disc = Nodes.Detection(Rendering.Lime(), Rendering.Red())
    node.det_left = Nodes.Detection(Rendering.Lime(), Rendering.Red())
    node.det_right = Nodes.Detection(Rendering.Lime(), Rendering.Red())

    # amgle is measured in angular-velocity or "degrees/second"
    node.turning_rate = 45.0    # degrees/second
    node.thrust_angle = 90.0   # Start in +Y direction (downward)

    # Overlays don't want scale transforms which is the default for
    # transform filters
    filter = Filters.TransformFilter(world, "TransformFilter", node)
    # However, we do want the rotation of the ship which means we DON'T
    # want to exclude it. The default was to exclude it.
    filter.exclude_rotation = false
    push!(node.children, filter)

    # Add thrust line indicator
    node.thrust_line = Custom.LineNode(world, "ThrustLineNode", filter)
    Custom.set!(node.thrust_line, 0.0, 0.0, 1.0, 0.0)
    Nodes.set_scale!(node.thrust_line, 50.0)
    Nodes.set_rotation_in_degrees!(node.thrust_line, node.thrust_angle)

    push!(filter.children, node.thrust_line)

    Nodes.set_dirty!(node, true);
end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Nodes.update(node::Ship, dt::Float64)
    Nodes.update!(node.det_disc, node.disc)
    Nodes.update!(node.det_left, node.left_cell)
    Nodes.update!(node.det_right, node.right_cell)

    if firing(node.keystate)
        println("fired")
    end

    if thrusting(node.keystate)
        println("thrusting")
    end

    if turning(node.keystate) < 0
        # println("turning ccw")
        node.thrust_angle -= node.turning_rate * (dt / 1000.0)
        println(node.thrust_angle)
    elseif turning(node.keystate) > 0
        # println("turning cw")
        node.thrust_angle += node.turning_rate * (dt / 1000.0)
        println(node.thrust_angle)
    end
end

# --------------------------------------------------------
# Rendering
# --------------------------------------------------------
function Nodes.draw(node::Ship, context::Rendering.RenderContext)
    if Nodes.is_dirty(node)
        Rendering.transform!(context, node.disc)
        Rendering.transform!(context, node.left_cell)
        Rendering.transform!(context, node.right_cell)

        Nodes.set_dirty!(node, false)
    end

    Rendering.set_draw_color(context, node.color)
    Rendering.render_outlined_polygon(context, node.disc, Rendering.CLOSED);
    Rendering.render_outlined_polygon(context, node.left_cell, Rendering.CLOSED);
    Rendering.render_outlined_polygon(context, node.right_cell, Rendering.CLOSED);

    inside = Nodes.check!(node.det_right, node, context)
    if !inside
        inside = Nodes.check!(node.det_left, node, context)
        if !inside
            inside = Nodes.check!(node.det_disc, node, context)
        end
    end
    
    Nodes.draw(node.det_disc, context)
    aabb_color = Nodes.highlight_color(node.det_disc, inside)
    Rendering.set_draw_color(context, aabb_color)

    Geometry.set!(node.aabb, node.disc.mesh.bucket)
    Geometry.expand!(node.aabb, node.left_cell.mesh.bucket)
    Geometry.expand!(node.aabb, node.right_cell.mesh.bucket)
    Rendering.render_aabb_rectangle(context, node.aabb)

end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function Nodes.enter_node(node::Ship, man::Nodes.NodeManager)
    println("enter ", node);
end

function Nodes.exit_node(node::Ship, man::Nodes.NodeManager)
    println("exit ", node);
end

# --------------------------------------------------------
# Events
# --------------------------------------------------------
# Here we elect to receive keyboard events.
function Nodes.io_event(node::Ship, event::Events.KeyboardEvent)
    # Events.print(event)

    set_state!(node.keystate, event)
end

function Nodes.io_event(node::Ship, event::Events.MouseEvent)
    # Nodes.io_event(node.circle, event)
    Nodes.set_device_point!(node.det_disc, Float64(event.x), Float64(event.y))
    Nodes.set_device_point!(node.det_left, Float64(event.x), Float64(event.y))
    Nodes.set_device_point!(node.det_right, Float64(event.x), Float64(event.y))
end

# --------------------------------------------------------
# Grouping
# --------------------------------------------------------
function Nodes.get_children(node::Ship)
    node.children
end
