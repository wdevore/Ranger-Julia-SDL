export 
    ZoomNode

mutable struct ZoomNode <: Ranger.AbstractNode
    base::Nodes.NodeData
    zoom::Math.ZoomTransform

    # Collection of nodes.
    children::Array{Ranger.AbstractNode,1}

    # State management
    mouse_window_position::Geometry.Point{Float64}
    mouse_moved::Bool
    zoom_point::Geometry.Point{Float64}
    wheel_direction::Int32   # 0 = not active, 1 = zoom-in, -1 = zoom-out

    function ZoomNode(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(Ranger.gen_id(world), name, parent)
        o.zoom = Math.ZoomTransform{Float64}()
        o.children = Array{Ranger.AbstractNode,1}[]

        o.mouse_window_position = Geometry.Point{Float64}()
        o.zoom_point = Geometry.Point{Float64}()
        o.wheel_direction = Int32(0)
        o.mouse_moved = false

        o
    end
end

function Nodes.draw(node::ZoomNode, context::Rendering.RenderContext)
    # Map window/device-space to view-space
    if node.mouse_moved
        Nodes.map_device_to_node!(context, 
            Int32(node.mouse_window_position.x), Int32(node.mouse_window_position.y),
            node,
            node.zoom_point)

        Custom.set_focal_point!(node, node.zoom_point.x, node.zoom_point.y)
        node.mouse_moved = false
    end

    if node.wheel_direction == 1
        # Zoom in
        Custom.zoom_in!(node)
    elseif node.wheel_direction == -1
        Custom.zoom_out!(node)
    end

    node.wheel_direction = 0;
end

# --------------------------------------------------------
# Grouping
# --------------------------------------------------------
function Nodes.get_children(node::ZoomNode)
    node.children
end

# --------------------------------------------------------
# Transforms
# --------------------------------------------------------
# Zoom node manages its own transform differently.
function Nodes.calc_transform!(node::ZoomNode)
    if Nodes.is_dirty(node)
        Math.update!(node.zoom)
        Nodes.set_dirty!(node, false)
    end

    node.zoom.transform
end

# --------------------------------------------------------
# Zooming
# --------------------------------------------------------
function set_position!(node::ZoomNode, x::Float64, y::Float64)
    Math.set_position!(node.zoom, x, y)
    Nodes.ripple_dirty!(node, true);
end

function set_focal_point!(node::ZoomNode, x::Float64, y::Float64)
    Math.set_zoom_at!(node.zoom, x, y)
    Nodes.ripple_dirty!(node, true);
end

function zoom_by!(node::ZoomNode, delta_x::Float64, delta_y::Float64)
    Math.zoom_by!(node.zoom, delta_x, delta_y)
    Nodes.ripple_dirty!(node, true);
end

function translate_by!(node::ZoomNode, delta_x::Float64, delta_y::Float64)
    Math.translate_by!(node.zoom, delta_x, delta_y)
    Nodes.ripple_dirty!(node, true);
end

function zoom_in!(node::ZoomNode)
    Math.zoom_by!(node.zoom, 0.1, 0.1)
    Nodes.ripple_dirty!(node, true);
end

function zoom_out!(node::ZoomNode)
    Math.zoom_by!(node.zoom, -0.1, -0.1)
    Nodes.ripple_dirty!(node, true);
end

# --------------------------------------------------------
# Events
# --------------------------------------------------------
function Nodes.io_event(node::ZoomNode, event::Events.MouseEvent)
    Geometry.set!(node.mouse_window_position, Float64(event.x), Float64(event.y))
    node.mouse_moved = true
end

function Nodes.io_event(node::ZoomNode, event::Events.MouseWheelEvent)
    # Mouse.y:
    # Forward = 1 = zoom in
    # Toward = -1 = zoom out
    node.wheel_direction = event.y
end
