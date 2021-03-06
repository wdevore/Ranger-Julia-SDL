export 
    OrbitSystemNode,
    set!

using Printf

# import ..Nodes.draw

mutable struct OrbitSystemNode <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    # Collection of nodes.
    children::Array{Ranger.AbstractNode,1}

    color::Rendering.Palette

    polygon::Geometry.Polygon

    angular_motion::Animation.AngularMotion{Float64}
    anchor_motion::Animation.AngularMotion{Float64}
    tri_motion::Animation.AngularMotion{Float64}

    anchor::Custom.AnchorNode
    triangle::Custom.OutlinedTriangle

    detection::Nodes.Detection
    inside::Bool

    aabb::Geometry.AABB{Float64}

    function OrbitSystemNode(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(name, parent, world)
        o.transform = Nodes.TransformProperties{Float64}()
        o.children = Array{Ranger.AbstractNode,1}[]
        o.color = Rendering.White()
        o.polygon = Geometry.Polygon{Float64}()
        o.angular_motion = Animation.AngularMotion{Float64}()
        o.anchor_motion = Animation.AngularMotion{Float64}()
        o.tri_motion = Animation.AngularMotion{Float64}()

        o.aabb = Geometry.AABB{Float64}()
        o.detection = Nodes.Detection(Rendering.Lime(), Rendering.Red())
        o.inside = false

        o
    end
end

function build(node::OrbitSystemNode, world::Ranger.World)
    Geometry.add_vertex!(node.polygon, 0.0, 0.0)
    Geometry.add_vertex!(node.polygon, 0.0, 0.0)
    Geometry.add_vertex!(node.polygon, 0.0, 0.0)
    Geometry.add_vertex!(node.polygon, 0.0, 0.0)

    Geometry.build!(node.polygon)

    # amgle is measured in angular-velocity or "degrees/second"
    node.angular_motion.rate = -45.0    # degrees/second

    # The anchor will rotate and we want that rotation to propagate to the
    # children.
    # Another way to say this is:
    # The anchor has a position, rotation and scale. We want to "filter-out" the
    # from any children as the children will determine their own scale.
    node.anchor = Custom.AnchorNode(world, "AnchorNode", node)
    Nodes.set_scale!(node.anchor, 20.0)
    node.anchor.color = RangerGame.lightblue
    node.anchor_motion.rate = 45.0

    # The child filter of the anchor node above.
    anchor_filter = Filters.TransformFilter(world, "AnchorTransformFilter", node.anchor)
    # Change the default rotation flag from "true" to "false".
    anchor_filter.exclude_rotation = false
    push!(node.anchor.children, anchor_filter);

    # Now we add children of the filter.
    node.triangle = Custom.OutlinedTriangle(world, "YellowTriangle", anchor_filter)
    Nodes.set_scale!(node.triangle, 50.0)
    Nodes.set_position!(node.triangle, 200.0, 0.0)
    # Nodes.set_scale!(node.triangle, 2.0)
    # Nodes.set_position!(node.triangle, 3.0, 0.0)
    node.triangle.color = RangerGame.yellow
    push!(anchor_filter.children, node.triangle);
    node.tri_motion.rate = -90.0    # degrees/second
end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Nodes.update(node::OrbitSystemNode, dt::Float64)
    # println("OrbitSystemNode::update : ", layer)
    Animation.update!(node.angular_motion, dt);
    Animation.update!(node.anchor_motion, dt);
    Animation.update!(node.tri_motion, dt);

    Nodes.update!(node.detection, node)

    Nodes.update(node.triangle, dt)
end

function Nodes.interpolate(node::OrbitSystemNode, interpolation::Float64)
    value = Animation.interpolate!(node.angular_motion, interpolation)
    Nodes.set_rotation_in_degrees!(node, value)

    value = Animation.interpolate!(node.anchor_motion, interpolation)
    Nodes.set_rotation_in_degrees!(node.anchor, value)

    value = Animation.interpolate!(node.tri_motion, interpolation)
    Nodes.set_rotation_in_degrees!(node.triangle, value)
end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function Nodes.enter_node(node::OrbitSystemNode, man::Nodes.NodeManager)
    println("enter ", node);
    node.inside = Nodes.check!(node.detection, node, node.base.world)
    # Register node as a timing target in order to receive updates
    Nodes.register_target(man, node)
    Nodes.register_event_target(man, node);
end

function Nodes.exit_node(node::OrbitSystemNode, man::Nodes.NodeManager)
    println("exit ", node);
    Nodes.unregister_target(man, node);
    Nodes.unregister_event_target(man, node);
end


function Nodes.draw(node::OrbitSystemNode, context::Rendering.RenderContext)
    if Nodes.is_dirty(node)
        Rendering.transform!(context, node.polygon)
        Nodes.set_dirty!(node, false)
    end

    Rendering.set_draw_color(context, node.color)
    Rendering.render_outlined_polygon(context, node.polygon, Rendering.CLOSED);

    # Nodes.draw(node.detection, context)
    aabb_color = Nodes.highlight_color(node.detection, node.inside)
    Rendering.set_draw_color(context, aabb_color)

    Geometry.set!(node.aabb, Nodes.get_bucket(node))
    Rendering.render_aabb_rectangle(context, node.aabb)
end

function set!(node::OrbitSystemNode, minx::Float64, miny::Float64, maxx::Float64, maxy::Float64)
    Geometry.set!(node.polygon.mesh.vertices[1], minx, miny)
    Geometry.set!(node.polygon.mesh.vertices[2], minx, maxy)
    Geometry.set!(node.polygon.mesh.vertices[3], maxx, maxy)
    Geometry.set!(node.polygon.mesh.vertices[4], maxx, miny)
    
    Nodes.set_dirty!(node, true)
end

# --------------------------------------------------------
# Events
# --------------------------------------------------------
function Nodes.io_event(node::OrbitSystemNode, event::Events.MouseMotionEvent)
    # println("io_event ", event, ", node: ", node)
    Nodes.set_device_point!(node.detection, Float64(event.x), Float64(event.y))
    node.inside = Nodes.check!(node.detection, node, node.base.world)

    Nodes.io_event(node.triangle, event)
end

# --------------------------------------------------------
# Grouping
# --------------------------------------------------------
function Nodes.get_children(node::OrbitSystemNode)
    node.children
end
