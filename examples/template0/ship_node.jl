# This node is made up of a circle and 2 rectangles
export
    Ship, set_direction!

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

    # Thrust vars
    thrust_angle::Float64
    prev_thrust_angle::Float64
    angular_thrust_motion::Animation.AngularMotion{Float64}
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
        o.angular_thrust_motion = Animation.AngularMotion{Float64}()

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

    # vertices are defined such that they are vertically aligned
    # down the +Y axis
    # Left cell horizontally narrow
    Geometry.add_vertex!(node.left_cell, -0.75, 0.0)
    Geometry.add_vertex!(node.left_cell, -0.75, 1.7)
    Geometry.add_vertex!(node.left_cell, -0.30, 1.7)
    Geometry.add_vertex!(node.left_cell, -0.30, 0.0)
    Geometry.build!(node.left_cell)

    # right cell horizontally narrow
    Geometry.add_vertex!(node.right_cell, 0.30, 0.0)
    Geometry.add_vertex!(node.right_cell, 0.30, 1.7)
    Geometry.add_vertex!(node.right_cell, 0.75, 1.7)
    Geometry.add_vertex!(node.right_cell, 0.75, 0.0)
    Geometry.build!(node.right_cell)
    
    node.det_disc = Nodes.Detection(Rendering.Lime(), Rendering.Red())
    node.det_left = Nodes.Detection(Rendering.Lime(), Rendering.Red())
    node.det_right = Nodes.Detection(Rendering.Lime(), Rendering.Red())

    # amgle is measured in angular-velocity or "degrees/second"
    node.turning_rate = 90.0
    node.angular_thrust_motion.angle = 0.0
    node.angular_thrust_motion.auto_wrap = false

    node.thrust_angle = 0.0   # Start in +Y direction (downward)
    node.prev_thrust_angle = 0.0
    
    # Overlays don't want scale transforms which is the default for
    # transform filters
    filter = Filters.TransformFilter(world, "TransformFilter", node)
    # However, we do want the rotation of the ship which means we DON'T
    # want to exclude it. The default was to exclude it.
    filter.exclude_rotation = false
    push!(node.children, filter)

    # Add thrust direction indicator
    node.thrust_line = Custom.LineNode(world, "ThrustLineNode", filter)
    # Set thrust line pointing down the +Y axis
    Custom.set!(node.thrust_line, 0.0, 0.0, 0.0, 1.0)
    Nodes.set_scale!(node.thrust_line, 40.0)

    push!(filter.children, node.thrust_line)

    Nodes.set_dirty!(node, true);
end

function set_direction!(node::Ship, degrees::Float64)
    node.thrust_angle = degrees
    node.prev_thrust_angle = node.thrust_angle
    Animation.set!(node.angular_thrust_motion, node.prev_thrust_angle, node.thrust_angle)
    Nodes.set_rotation_in_degrees!(node, node.thrust_angle)    
end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Nodes.update(node::Ship, dt::Float64)
    Nodes.update!(node.det_disc, node.disc)
    Nodes.update!(node.det_left, node.left_cell)
    Nodes.update!(node.det_right, node.right_cell)

    # Because the ship's thrust direction is irregular using update! doesn't
    # make sense. update! is for motion in a single direction.
    # Animation.update!(node.angular_thrust_motion, dt)

    if firing(node.keystate)
        println("fired")
    end

    if thrusting(node.keystate)
        println("thrusting")
    end

    if turning(node.keystate) < 0
        # CCW
        node.prev_thrust_angle = node.thrust_angle
        # By dividing "dt" by 1000 we are mapping to degrees/second rather than
        # degrees/ms. 45 degrees/ms would lead to a blur on the screen. ;-)
        node.thrust_angle -= node.turning_rate * (dt / 1000.0)
        Animation.set!(node.angular_thrust_motion, node.prev_thrust_angle, node.thrust_angle)
    elseif turning(node.keystate) > 0
        # CW
        node.prev_thrust_angle = node.thrust_angle
        node.thrust_angle += node.turning_rate * (dt / 1000.0)
        Animation.set!(node.angular_thrust_motion, node.prev_thrust_angle, node.thrust_angle)
    else
        # Because the turning rate isn't changing there should not be any change
        # in the thrust angle (delta angle). This can be done by setting both the
        # previous and current angles equal to each other thus delta = 0.
        node.prev_thrust_angle = node.thrust_angle
        # And we need to update the motion accordingly.
        Animation.set!(node.angular_thrust_motion, node.prev_thrust_angle, node.thrust_angle)
    end
end

function Nodes.interpolate(node::Ship, interpolation::Float64)
    # Each time the direction angle changes we want to interpolate towards the
    # new angle.
    value = Animation.interpolate!(node.angular_thrust_motion, interpolation)
    Nodes.set_rotation_in_degrees!(node, value)
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
