export 
    OrbitSystemNode,
    set!

import ..Nodes.draw

mutable struct OrbitSystemNode <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    # Collection of nodes.
    children::Array{Ranger.AbstractNode,1}

    color::Rendering.Palette

    polygon::Geometry.Polygon

    angular_motion::Animation.AngularMotion{Float64}

    function OrbitSystemNode(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(Ranger.gen_id(world), name, parent)
        o.transform = Nodes.TransformProperties{Float64}()
        o.children = Array{Ranger.AbstractNode,1}[]
        o.color = Rendering.White()
        o.polygon = Geometry.Polygon{Float64}()
        o.angular_motion = Animation.AngularMotion{Float64}()

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
    node.angular_motion.angle = -45.0    # degrees/second

    tri = Custom.OutlinedTriangle(world, "YellowTriangle", node)
    Custom.set!(tri,
        Geometry.Point{Float64}(-0.5, 0.5),
        Geometry.Point{Float64}(0.5, 0.5),
        Geometry.Point{Float64}(0.0, -0.5))
    # Nodes.set_scale!(tri, 50.0)
    # Nodes.set_position!(tri, 100.0, -100.0)
    Nodes.set_scale!(tri, 1.0)
    Nodes.set_position!(tri, 3.0, 0.0)
    tri.color = RangerGame.yellow
    push!(node.children, tri);


end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Nodes.update(node::OrbitSystemNode, dt::Float64)
    # println("OrbitSystemNode::update : ", layer)
    Animation.update!(node.angular_motion, dt);
end

function Nodes.interpolate(node::OrbitSystemNode, interpolation::Float64)
    value = Animation.interpolate!(node.angular_motion, interpolation)
    Nodes.set_rotation_in_degrees!(node, value)
end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function Nodes.enter_node(node::OrbitSystemNode, man::Nodes.NodeManager)
    println("enter ", node);
    # Register node as a timing target in order to receive updates
    Nodes.register_target(man, node)
end

function Nodes.exit_node(node::OrbitSystemNode, man::Nodes.NodeManager)
    println("exit ", node);
    Nodes.unregister_target(man, node);
end


function Nodes.draw(node::OrbitSystemNode, context::Rendering.RenderContext)
    if Nodes.is_dirty(node)
        Rendering.transform!(context, node.polygon)
        Nodes.set_dirty!(node, false)
    end

    Rendering.set_draw_color(context, node.color)
    Rendering.render_outlined_polygon(context, node.polygon, Rendering.CLOSED);
end

function set!(node::OrbitSystemNode, minx::Float64, miny::Float64, maxx::Float64, maxy::Float64)
    Geometry.set!(node.polygon.mesh.vertices[1], minx, miny)
    Geometry.set!(node.polygon.mesh.vertices[2], minx, maxy)
    Geometry.set!(node.polygon.mesh.vertices[3], maxx, maxy)
    Geometry.set!(node.polygon.mesh.vertices[4], maxx, miny)
    
    Nodes.set_dirty!(node, true)
end

# --------------------------------------------------------
# Grouping
# --------------------------------------------------------
function Nodes.get_children(node::OrbitSystemNode)
    node.children
end
