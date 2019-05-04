# This node is made up of a circle and 2 rectangles
export
    Ship, set_direction!

# Magnitude needs to high enough such that the ship doens't appear
# to "drive". It should "drift" a bit on turns. Too low and the thrust
# overpowers the momentum.
const MAX_MAGNITUDE = 25.0
const MAX_THRUST_MAGNITUDE = 1.5

# How quickly the ship comes to a rest with no thrust applied
const MOMENTUM_DRAG = 0.025 * 100.0

const THRUST_INCREASE_RATE = 0.03 * 100.0
const THRUST_DECREASE_RATE = -0.05 * 100.0

const TURNING_RATE = 180.0 + 45.0

include("keystate.jl")
include("vector_motion.jl")

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
    vector_motion::VectorMotion

    position_motion::Animation.Linear2DMotion{Float64}

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
        o.vector_motion = VectorMotion()

        o.position_motion = Animation.Linear2DMotion{Float64}()

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
    node.turning_rate = TURNING_RATE
    node.angular_thrust_motion.rate = 0.0
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
    set_direction!(node)
end

function set_direction!(node::Ship)
    node.prev_thrust_angle = node.thrust_angle

    Animation.set!(node.angular_thrust_motion, node.prev_thrust_angle, node.thrust_angle)
    Nodes.set_rotation_in_degrees!(node, node.thrust_angle)

    Math.set_direction!(node.vector_motion.vector_force, node.thrust_angle - 90.0);
end

function set_position!(node::Ship, x::Float64, y::Float64)
    Nodes.set_position!(node, x, y)
    Math.set!(node.position_motion.from, x, y)
    Math.set!(node.position_motion.to, x, y)
    # Nodes.set_dirty!(node, true);
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

    # Default: turning rate isn't changing there should not be any change
    # in the thrust angle (delta angle). This can be done by setting both the
    # previous and current angles equal to each other thus delta = 0.
    node.prev_thrust_angle = node.thrust_angle

    if turning(node.keystate) < 0
        # CCW
        node.prev_thrust_angle = node.thrust_angle
        # By dividing "dt" by 1000 we are mapping to degrees/second rather than
        # degrees/ms. 45 degrees/ms would lead to a blur on the screen. ;-)
        node.thrust_angle -= node.turning_rate * (dt / 1000.0)

        set_direction!(node)
    elseif turning(node.keystate) > 0
        # CW
        node.prev_thrust_angle = node.thrust_angle
        node.thrust_angle += node.turning_rate * (dt / 1000.0)

        set_direction!(node)
    end

    if thrusting(node.keystate)
        apply_thrust!(node, THRUST_INCREASE_RATE * (dt / 1000.0))
    else
        # If there is no thrust being applied then the thrust slowly dies off.
        apply_thrust!(node, THRUST_DECREASE_RATE * (dt / 1000.0))
        # Or Instant turn-off
        # Math.set_magnitude!(node.vector_motion.vector_force, 0.0)
    end


    # Update the ship's position based on the momentum. If there is drag
    # then the momentum will steadily decrease until it reaches a magnitude
    # of zero.
    # Take the ship's current momentum--which is independent of the ship's
    # current thrust direction--and apply thrust/force to it. We want to change the
    # ship's momentum not direction.
    apply_force!(node.vector_motion)
    
    # Now update the ship's position based on the momentum.
    if Math.get_magnitude(node.vector_motion.momentum) > 0.0
        # Apply momentum to get new position
        # Math.apply!(node.vector_motion.momentum, node.transform.position)
        # Nodes.set_dirty!(node, true)

        # Math.set!(node.position_motion.from, node.transform.position.x, node.transform.position.y)
        Math.set!(node.position_motion.from, node.position_motion.to)
        Math.apply!(node.vector_motion.momentum, node.position_motion.to)
        Nodes.set_dirty!(node, true)
    else
        Math.set!(node.position_motion.from, node.transform.position.x, node.transform.position.y)
        Math.set!(node.position_motion.to, node.transform.position.x, node.transform.position.y)
    end

    # Update momentum if there is drag.
    decrease_momentum!(node.vector_motion, MOMENTUM_DRAG * (dt / 1000.0));
end

# Called during visit/rendering which is AFTER update()
function Nodes.interpolate(node::Ship, interpolation::Float64)
    # Each time the direction angle changes we want to interpolate towards the
    # new angle.
    value = Animation.interpolate!(node.angular_thrust_motion, interpolation)
    Nodes.set_rotation_in_degrees!(node, value)

    # We need to interpolate to get the actual position.
    position = Animation.interpolate!(node.position_motion, interpolation)
    Geometry.set!(node.transform.position, position.x, position.y)
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

# --------------------------------------------------------
# Ship specific functionality
# --------------------------------------------------------
function apply_thrust!(node::Ship, mag::Float64)
    increase_force!(node.vector_motion, mag)
end

