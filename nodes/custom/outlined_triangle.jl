export 
    OutlinedTriangle,
    set!

import ..Nodes.draw

mutable struct OutlinedTriangle <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    color::Rendering.Palette

    polygon::Geometry.Polygon

    aabb::Geometry.AABB{Float64}

    detection::Nodes.Detection

    function OutlinedTriangle(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(Ranger.gen_id(world), name, parent)
        o.transform = Nodes.TransformProperties{Float64}()
        o.color = Rendering.White()

        o.polygon = Geometry.Polygon{Float64}()

        o.aabb = Geometry.AABB{Float64}()
        o.detection = Nodes.Detection(Rendering.Lime(), Rendering.Red())
        
        Geometry.add_vertex!(o.polygon, -0.5, 0.5)
        Geometry.add_vertex!(o.polygon, 0.5, 0.5)
        Geometry.add_vertex!(o.polygon, 0.0, -0.5)

        Geometry.build!(o.polygon)

        Nodes.set_dirty!(o, true)

        o
    end
end

# --------------------------------------------------------
# Timing: either called by NodeManager or by a parent node
# --------------------------------------------------------
function Nodes.update(node::OutlinedTriangle, dt::Float64)
    Nodes.update!(node.detection, node)
end

function Nodes.draw(node::OutlinedTriangle, context::Rendering.RenderContext)
    if Nodes.is_dirty(node)
        Rendering.transform!(context, node.polygon)
        Nodes.set_dirty!(node, false)
    end

    Rendering.set_draw_color(context, node.color)
    Rendering.render_outlined_polygon(context, node.polygon, Rendering.CLOSED);

    inside = Nodes.check!(node.detection, node, context)
    aabb_color = Nodes.highlight_color(node.detection, inside)
    Rendering.set_draw_color(context, aabb_color)

    Geometry.set!(node.aabb, Nodes.get_bucket(node))
    Rendering.render_aabb_rectangle(context, node.aabb)
end

# --------------------------------------------------------
# Events
# --------------------------------------------------------
function Nodes.io_event(node::OutlinedTriangle, event::Events.MouseEvent)
    # println("io_event ", event, ", node: ", node)
    Nodes.set_device_point!(node.detection, Float64(event.x), Float64(event.y))
end

function set!(node::OutlinedTriangle, v1::Point{Float64}, v2::Point{Float64}, v3::Point{Float64})
    Geometry.set!(node.polygon.mesh.vertices[1], v1)
    Geometry.set!(node.polygon.mesh.vertices[2], v2)
    Geometry.set!(node.polygon.mesh.vertices[3], v3)
    
    Nodes.set_dirty!(node, true)
end

