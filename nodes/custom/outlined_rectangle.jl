export 
    OutlinedRectangle,
    set!, update

import ..Nodes.draw
# import ..Nodes.update!

mutable struct OutlinedRectangle <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    color::Rendering.Palette

    polygon::Geometry.Polygon

    aabb::Geometry.AABB{Float64}
    detection::Nodes.Detection
    inside::Bool

    function OutlinedRectangle(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(name, parent, world)
        o.transform = Nodes.TransformProperties{Float64}()
        o.color = Rendering.White()

        o.aabb = Geometry.AABB{Float64}()
        o.detection = Nodes.Detection(Rendering.Lime(), Rendering.Red())
        o.inside = false

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
# Timing: either called by NodeManager or by a parent node
# --------------------------------------------------------
function Nodes.update(node::OutlinedRectangle, dt::Float64)
    Nodes.update!(node.detection, node)
end

function Nodes.draw(node::OutlinedRectangle, context::Rendering.RenderContext)
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

function set!(node::OutlinedRectangle, minx::Float64, miny::Float64, maxx::Float64, maxy::Float64)
    Geometry.set!(node.polygon.mesh.vertices[1], minx, miny)
    Geometry.set!(node.polygon.mesh.vertices[2], minx, maxy)
    Geometry.set!(node.polygon.mesh.vertices[3], maxx, maxy)
    Geometry.set!(node.polygon.mesh.vertices[4], maxx, miny)
    
    Nodes.set_dirty!(node, true)
end

# --------------------------------------------------------
# Events
# --------------------------------------------------------
function Nodes.io_event(node::OutlinedRectangle, event::Events.MouseMotionEvent)
    # println("io_event ", event, ", node: ", node)
    Nodes.set_device_point!(node.detection, Float64(event.x), Float64(event.y))
    node.inside = Nodes.check!(node.detection, node, node.base.world)
end

