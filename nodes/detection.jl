export
    Detection,
    check!, update!, set_device_point!, draw, highlight_color

using Printf

# Detection is for detecting if a device point is within
# the node's polygon.
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

    detection.inside_node
end

function highlight_color(detection::Detection, inside::Bool)
    if inside
        return detection.inside_color
    else
        return detection.outside_color
    end    
end

# Typically called from a Nodes.update
function update!(detection::Detection, node::Ranger.AbstractNode)
    detection.inside_node = Geometry.is_point_inside(node.polygon, detection.local_point)
end

function update!(detection::Detection, polygon::Geometry.Polygon)
    detection.inside_node = Geometry.is_point_inside(polygon, detection.local_point)
end

# Typically called from a Nodes.io_event
function set_device_point!(detection::Detection, x::Float64, y::Float64)
    Geometry.set!(detection.device_point, x, y)
end

# Draw debug local-space coords
function draw(detection::Detection, context::Rendering.RenderContext)
    color = if detection.inside_node
        detection.inside_color
    else
        detection.outside_color
    end
    Rendering.set_draw_color(context, color)
    text = @sprintf("L: %2.4f, %2.4f", detection.local_point.x, detection.local_point.y)
    Rendering.draw_text(context, 10, 70, text, 2, 2, false)
end