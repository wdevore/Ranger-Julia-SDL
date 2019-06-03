mutable struct DragState
    dragging::Bool
    down::Bool

    position_down::Geometry.Point{Float64}
    position_up::Geometry.Point{Float64}
    
    position::Geometry.Point{Float64}
    delta::Geometry.Point{Float64}

    map_point::Geometry.Point{Float64}

    function DragState()
        o = new()
        o.position_down = Geometry.Point{Float64}()
        o.position_up = Geometry.Point{Float64}()
        o.delta = Geometry.Point{Float64}()
        o.position = Geometry.Point{Float64}()
        o.map_point = Geometry.Point{Float64}()
        o
    end
end

function is_dragging(state::DragState)
    state.dragging
end

function set_motion_state!(drag::DragState, x::Int32, y::Int32, node::Ranger.AbstractNode)
    if drag.down
        drag.dragging = true
        # We need to map to parent space for dragging because the parent may contain
        # a scaling factor. Using view-space will result in drifting from scale difference.
        Nodes.map_device_to_node!(node.base.world, x, y, node.base.parent, drag.map_point)

        Geometry.set!(drag.delta, drag.map_point.x - drag.position.x, drag.map_point.y - drag.position.y)
        Geometry.set!(drag.position, drag.map_point.x, drag.map_point.y)
    else
        drag.dragging = false
    end
end

function set_button_state!(drag::DragState,
        x::Int32, y::Int32,
        button::UInt8, state::UInt8,
        node::Ranger.AbstractNode)
    drag.down = button == 1 && state == 1

    Nodes.map_device_to_node!(node.base.world, x, y, node.base.parent, drag.map_point)

    if drag.down
        Geometry.set!(drag.position_down, drag.map_point.x, drag.map_point.y)
        Geometry.set!(drag.position, drag.position_down)
    else
        Geometry.set!(drag.position_up, drag.map_point.x, drag.map_point.y)
    end
end

function set_motion_state!(state::DragState, x::Float64, y::Float64)
    if state.down
        state.dragging = true
        Geometry.set!(state.delta, x - state.position.x, y - state.position.y)
        Geometry.set!(state.position, x, y)
    else
        state.dragging = false
    end
end

function set_button_state!(drag::DragState, x::Float64, y::Float64, button::UInt8, state::UInt8)
    drag.down = button == 1 && state == 1

    if drag.down
        Geometry.set!(drag.position_down, x, y)
        Geometry.set!(drag.position, drag.position_down)
    else
        Geometry.set!(drag.position_up, x, y)
    end
end
