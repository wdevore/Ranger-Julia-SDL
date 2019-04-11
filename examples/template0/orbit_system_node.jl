export 
    OrbitSystemNode,
    set!

import ..Nodes.draw

mutable struct OrbitSystemNode <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    color::Rendering.Palette

    polygon::Geometry.Polygon

    angle::Float64

    function OrbitSystemNode(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(Ranger.gen_id(world), name, parent)
        o.transform = Nodes.TransformProperties{Float64}()
        o.color = Rendering.White()

        o.polygon = Geometry.Polygon{Float64}()

        Geometry.add_vertex!(o.polygon, 0.0, 0.0)
        Geometry.add_vertex!(o.polygon, 0.0, 0.0)
        Geometry.add_vertex!(o.polygon, 0.0, 0.0)
        Geometry.add_vertex!(o.polygon, 0.0, 0.0)

        Geometry.build!(o.polygon)

        o
    end
end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Nodes.update(node::OrbitSystemNode, dt::Float64)
    # println("OrbitSystemNode::update : ", layer)
    node.angle += 1.0
    Nodes.set_rotation_in_degrees!(node, node.angle)
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

