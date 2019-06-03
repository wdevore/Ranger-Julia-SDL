include("keystate.jl")

mutable struct HostNode <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    # Collection for AnchorNode
    children::Array{Ranger.AbstractNode,1}

    # Colors
    color::Rendering.Palette

    # An icon so we can see the host
    polygon::Geometry.Polygon

    # Total AABB
    aabb::Geometry.AABB{Float64}

    # Hit detection for both projectiles and dragging
    detection::Nodes.Detection
    inside::Bool

    keystate::KeyState
    drag::DragState
    node_point::Geometry.Point{Float64}

    particle_system::Particles.ParticleSystem

    function HostNode(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(name, parent, world)
        o.transform = Nodes.TransformProperties{Float64}()
        o.children = Array{Ranger.AbstractNode,1}[]
        o.color = Rendering.White()

        o.aabb = Geometry.AABB{Float64}()

        o.polygon = Geometry.Polygon{Float64}()
        o.detection = Nodes.Detection(Rendering.Yellow(), Rendering.Red())
        o.inside = false
        o.keystate = KeyState(false, false, Int8(0))
        o.drag = DragState()
        o.node_point = Geometry.Point{Float64}()

        # Setup particle activator
        activator = Particles.Activator360()
        activator.max_life = 3.0

        # Create and activate particle system.
        o.particle_system = Particles.ParticleSystem(activator)
        o.particle_system.active = true
        o.particle_system.auto_trigger = true

        # Add a few particles to the system.
        for i in 1:Particles.MAX_PARTICLES
            p = Particles.Particle{Float64}()
            Particles.add_particle!(o.particle_system, p)

            # Add a particle node to the parent (i.e. a visual).
            pnode = BasicParticleNode(world, "ParticleNode:" * string(i), parent)
            p.visual = pnode
            pnode.color = Rendering.Red()
            pnode.base.id = i # assign an id for lookups.
            Nodes.set_scale!(pnode, Particles.MAX_PARTICE_SIZE) # an initial size

            # Important! We are adding the node to the parent and NOT this host node.
            # We want the particle to be independent of the emitter.
            push!(Nodes.get_children(parent), pnode)
        end

        build(o, world)
        o
    end
end

function build(node::HostNode, world::Ranger.World)
    Geometry.add_vertex!(node.polygon, 0.05, -0.05)
    Geometry.add_vertex!(node.polygon, 0.05, -0.15)
    Geometry.add_vertex!(node.polygon, 0.0, -0.25)
    Geometry.add_vertex!(node.polygon, -0.05, -0.25)
    Geometry.add_vertex!(node.polygon, -0.05, -0.15)
    Geometry.add_vertex!(node.polygon, -0.05, -0.05)

    Geometry.add_vertex!(node.polygon, -0.15, -0.05)
    Geometry.add_vertex!(node.polygon, -0.25, 0.0)
    Geometry.add_vertex!(node.polygon, -0.25, 0.05)
    Geometry.add_vertex!(node.polygon, -0.15, 0.05)
    Geometry.add_vertex!(node.polygon, -0.05, 0.05)

    Geometry.add_vertex!(node.polygon, -0.05, 0.15)
    Geometry.add_vertex!(node.polygon, 0.0, 0.25)
    Geometry.add_vertex!(node.polygon, 0.05, 0.25)
    Geometry.add_vertex!(node.polygon, 0.05, 0.15)
    Geometry.add_vertex!(node.polygon, 0.05, 0.05)

    Geometry.add_vertex!(node.polygon, 0.15, 0.05)
    Geometry.add_vertex!(node.polygon, 0.25, 0.0)
    Geometry.add_vertex!(node.polygon, 0.25, -0.05)
    Geometry.add_vertex!(node.polygon, 0.15, -0.05)
    Geometry.add_vertex!(node.polygon, 0.05, -0.05)

    Geometry.build!(node.polygon)

    Nodes.set_dirty!(node, true);
end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Nodes.update(node::HostNode, dt::Float64)
    Nodes.update!(node.detection, node)
    Particles.update!(node.particle_system, dt)
    
    pos = node.transform.position
    Particles.set_position!(node.particle_system, pos.x, pos.y)
end

# Called during visit/rendering which is AFTER update()
function Nodes.interpolate(node::HostNode, interpolation::Float64)
end

# --------------------------------------------------------
# Rendering
# --------------------------------------------------------
function Nodes.draw(node::HostNode, context::Rendering.RenderContext)
    if Nodes.is_dirty(node)
        Rendering.transform!(context, node.polygon)

        Nodes.set_dirty!(node, false)
    end

    Rendering.set_draw_color(context, node.color)
    Rendering.render_outlined_polygon(context, node.polygon, Rendering.CLOSED);

    aabb_color = Nodes.highlight_color(node.detection, node.inside)
    Rendering.set_draw_color(context, aabb_color)

    Geometry.set!(node.aabb, Nodes.get_bucket(node))
    Rendering.render_aabb_rectangle(context, node.aabb)

end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function Nodes.enter_node(node::HostNode, man::Nodes.NodeManager)
    println("enter ", node);
    Nodes.register_event_target(man, node);

    node.inside = Nodes.check!(node.detection, node, node.base.world)
end

function Nodes.exit_node(node::HostNode, man::Nodes.NodeManager)
    println("exit ", node);
    Nodes.unregister_event_target(man, node);
end

# --------------------------------------------------------
# Events
# --------------------------------------------------------
# Here we elect to receive keyboard events.
function Nodes.io_event(node::HostNode, event::Events.KeyboardEvent)
    # Events.print(event)
    if (event.keycode == Events.KEY_F && event.state == Events.KEY_PRESSED)
        pos = node.transform.position
        Particles.set_position!(node.particle_system, pos.x, pos.y)
        Particles.trigger_oneshot!(node.particle_system)
    end

    if (event.keycode == Events.KEY_E && event.state == Events.KEY_PRESSED)
        pos = node.transform.position
        Particles.set_position!(node.particle_system, pos.x, pos.y)
        Particles.explode!(node.particle_system)
    end

    if (event.keycode == Events.KEY_W && event.state == Events.KEY_PRESSED)
        node.particle_system.auto_trigger = !node.particle_system.auto_trigger
        if node.particle_system.auto_trigger
            println("Autotrigger ON")
        else
            println("Autotrigger OFF")
        end
    end

    set_state!(node.keystate, event)
end

function Nodes.io_event(node::HostNode, event::Events.MouseMotionEvent)
    set_motion_state!(node.drag, event.x, event.y, node)

    dragging = is_dragging(node.drag)
    # println(dragging, ", ", node.inside)
    if dragging && node.inside
        pos = node.transform.position
        Nodes.set_position!(node, pos.x + node.drag.delta.x, pos.y + node.drag.delta.y)
    end

    Nodes.set_device_point!(node.detection, Float64(event.x), Float64(event.y))
    node.inside = Nodes.check!(node.detection, node, node.base.world)    
end

function Nodes.io_event(node::HostNode, event::Events.MouseButtonEvent)
    set_button_state!(node.drag, event.x, event.y, event.button, event.state, node)
end

# --------------------------------------------------------
# Grouping
# --------------------------------------------------------
function Nodes.get_children(node::HostNode)
    node.children
end

# --------------------------------------------------------
# Host specific functionality
# --------------------------------------------------------

