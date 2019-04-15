export
    Detection,
    check!, update!, set_device_point!, draw

using Printf

mutable struct Detection
    local_point::Geometry.Point{Float64}
    device_point::Geometry.Point{Float64}
    inside_node::Bool
    inside_color::Rendering.Palette
    outside_color::Rendering.Palette
   
    function Detection(inside_color::Rendering.Palette, outside_color::Rendering.Palette)
        o = new()

        o.device_point = Geometry.Point{Float64}()
        o.local_point = Geometry.Point{Float64}()
        o.inside_node = false
        o.inside_color = inside_color
        o.outside_color = outside_color

        o
    end
end

# Typically called from a Nodes.draw
function check!(detection::Detection, node::Ranger.AbstractNode, context::Rendering.RenderContext)
    # Map device/mouse coords to local-space of node.
    Nodes.map_device_to_node!(context, 
        Int32(detection.device_point.x), Int32(detection.device_point.y),
        node, detection.local_point)

    if detection.inside_node
        return detection.inside_color
    else
        return detection.outside_color
    end
end

# Typically called from a Nodes.update
function update!(detection::Detection, node::Ranger.AbstractNode)
    detection.inside_node = Geometry.is_point_inside(node.polygon, detection.local_point)
end

# Typically called from a Nodes.io_event
function set_device_point!(detection::Detection, x::Float64, y::Float64)
    Geometry.set!(detection.device_point, x, y)
end

# Draw debug local-space coords
function draw(detection::Detection, context::Rendering.RenderContext)
    if detection.inside_node
        Rendering.set_draw_color(context, detection.inside_color)
    else
        Rendering.set_draw_color(context, detection.outside_color)
    end
    text = @sprintf("L: %2.4f, %2.4f", detection.local_point.x, detection.local_point.y)
    Rendering.draw_text(context, 10, 70, text, 2, 2, false)
end