export 
    OutlinedCircle,
    set!, update

import ..Nodes.draw
# import ..Nodes.update!

mutable struct OutlinedCircle <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    color::Rendering.Palette

    polygon::Geometry.Polygon

    aabb::Geometry.AABB{Float64}

    detection::Nodes.Detection

    function OutlinedCircle(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(Ranger.gen_id(world), name, parent)
        o.transform = Nodes.TransformProperties{Float64}()
        o.color = Rendering.White()

        o.polygon = Geometry.Polygon{Float64}()

        o.aabb = Geometry.AABB{Float64}()
        o.detection = Nodes.Detection(Rendering.Lime(), Rendering.Red())

        o
    end
end

# --------------------------------------------------------
# Timing: either called by NodeManager or by a parent node
# --------------------------------------------------------
function Nodes.update(node::OutlinedCircle, dt::Float64)
    Nodes.update!(node.detection, node)
end

function Nodes.draw(node::OutlinedCircle, context::Rendering.RenderContext)
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

function set!(node::OutlinedCircle, segment_size::Float64)
    for degree in 0.0:segment_size:360.0
        Geometry.add_vertex!(node.polygon, cos(deg2rad(degree)), sin(deg2rad(degree)))
    end

    Geometry.build!(node.polygon)

    Nodes.set_dirty!(node, true)
end

# --------------------------------------------------------
# Events
# --------------------------------------------------------
function Nodes.io_event(node::OutlinedCircle, event::Events.MouseEvent)
    # println("io_event ", event, ", node: ", node)
    Nodes.set_device_point!(node.detection, Float64(event.x), Float64(event.y))
end

