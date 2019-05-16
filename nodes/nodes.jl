export Nodes

# ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
# Nodes API interface
# ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
module Nodes

export 
    visit, enter_node, exit_node,
    set_position!, calc_transform!

using ..Geometry
using ..Ranger
using ..Math

using Base.Math:
    deg2rad, rad2deg


# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function enter_node end
function exit_node end

function transition end
function get_replacement end
function take_replacement end
function visit end
function draw end
function interpolate end

function has_parent end
function is_nil end
function has_replacement end
function has_parent end

function update end
function calc_transform! end

function get_children end

function io_event end

# ---------- INCLUDES --------------------------------------------------
include("transition_properties.jl")
include("timing_properties.jl")
include("transform_properties.jl")

include("node_data.jl")
include("node_nil.jl")
include("node_stack.jl")

include("scenes/scenes.jl")
include("scenes/scene_nil.jl")

include("node_manager.jl")

include("filters/filters.jl")

include("space_mappings.jl")
include("detection.jl")

# -----------------------------------------------------------
# Abstract Nodes
# -----------------------------------------------------------
function is_nil(node::Ranger.AbstractNode)
    node.base.id == 0
end

function has_parent(node::Ranger.AbstractNode)
    !is_nil(node.base.parent)
end

using ..Rendering

# visit() traverse "downward" the heirarchy while space-mappings traverse upward.
function visit(node::Ranger.AbstractNode, context::Rendering.RenderContext, interpolation::Float64)
    # println("AbstractNode::visit ", node);
    if !is_visible(node)
        return;
    end

    Rendering.save!(context)

    # Because position and angles are dependent
    # on lerping we perform interpolation first.
    interpolate(node, interpolation)

    aft = calc_transform!(node)

    Rendering.apply!(context, aft)

    children = get_children(node)
    if children ≠ nothing
        draw(node, context)

        for child in children
            visit(child, context, interpolation)
        end
    else
        draw(node, context)
    end

    Rendering.restore!(context)

    # println("End visit ----------------------------------------------")
end

function calc_transform!(node::Ranger.AbstractNode)
    tr = node.transform

    if is_dirty(node)
        # println("calc_transform dirty: ", node.base.name)
        make_translate!(tr.aft, tr.position.x, tr.position.y)

        if tr.rotation ≠ 0.0
            rotate!(tr.aft, tr.rotation)
        end

        if tr.scale.x ≠ 1.0 || tr.scale.y ≠ 1.0
            scale!(tr.aft, tr.scale.x, tr.scale.y)
        end

        Math.invert!(tr.aft, tr.inverse)
    end

    tr.aft
end

function get_transform(node::Ranger.AbstractNode)
    node.transform.aft
end

function interpolate(node::Ranger.AbstractNode, interpolation::Float64)
    # println("AbstractNode::interpolate ", node);
end

function draw(node::Ranger.AbstractNode, context::RenderContext)
    # println("AbstractNode::draw ", node);
end

function interpolate(node::Ranger.AbstractNode, interpolation::Float64)
end

function enter_node(node::Ranger.AbstractNode, man::NodeManager)
    # println("AbstractNode::enter ", node);
end

function exit_node(node::Ranger.AbstractNode, man::NodeManager)
    # println("AbstractNode::exit ", node);
end

function io_event(node::Ranger.AbstractNode, event::Ranger.AbstractIOEvent)
    # println("AbstractScene::io_event ", event)
end

function is_visible(node::Ranger.AbstractNode)
    node.base.visible
end

function is_dirty(node::Ranger.AbstractNode)
    node.base.dirty
end

# ripple dirty flag
function set_dirty!(node::Ranger.AbstractNode, dirty::Bool)
    # if node.base.name == "ZoomNode"
    #     println(stacktrace())
    # end
    # println("set_dirty: ", node.base.name)
    node.base.dirty = dirty
end

function ripple_dirty!(node::Ranger.AbstractNode, dirty::Bool)
    children = get_children(node)
    if children ≠ nothing
        for child in children
            ripple_dirty!(child, dirty)
        end
    end

    # println("ripple_dirty: ", node.base.name)
    set_dirty!(node, dirty)
end

function set_position!(node::Ranger.AbstractNode, x::T, y::T) where {T <: AbstractFloat}
    Geometry.set!(node.transform.position, x, y)
    ripple_dirty!(node, true);
end

function set_rotation_in_degrees!(node::Ranger.AbstractNode, rotation::T) where {T <: AbstractFloat}
    node.transform.rotation = deg2rad(rotation);

    ripple_dirty!(node, true);
end

function set_scale!(node::Ranger.AbstractNode, s::T) where {T <: AbstractFloat}
    Geometry.set!(node.transform.scale, s, s);
    ripple_dirty!(node, true);
end

function set_nonuniform_scale!(node::Ranger.AbstractNode, sx::T, sy::T) where {T <: AbstractFloat}
    Geometry.set!(node.transform.scale, sx, sy)
    ripple_dirty!(node, true);
end

# -----------------------------------------------------------
# Abstract Scenes
# -----------------------------------------------------------
function is_nil(node::Ranger.AbstractScene)
    node.base.id == 0
end

function has_replacement(node::Ranger.AbstractScene)
    !is_nil(node.replacement)
end

function has_parent(node::Ranger.AbstractScene)
    !is_nil(node.base.parent)
end

function enter_node(node::Ranger.AbstractScene, man::NodeManager)
    println("AbstractScene::enter ", node);
end

function exit_node(node::Ranger.AbstractScene, man::NodeManager)
    println("AbstractScene::exit ", node);
end

# --------------------------------------------------------
# Grouping
# --------------------------------------------------------
function get_children(node::Ranger.AbstractScene)
    nothing
end

function get_children(node::Ranger.AbstractNode)
    nothing
end

# --------------------------------------------------------
# Polygons
# --------------------------------------------------------
function get_bucket(node::Ranger.AbstractNode)
    node.polygon.mesh.bucket # return AbstractArray{Geometry.Point{T}}
end

# --------------------------------------------------------------------------
# Timing
# --------------------------------------------------------------------------
function update(node::Ranger.AbstractNode, dt::Float64)
    # println("AbstractNode::update : ", node)
end


# --------------------------------------------------------------------------
# Misc debugging
# --------------------------------------------------------------------------
import Base.show

function Base.show(io::IO, node::Ranger.AbstractNode)
    print(io, "|'", node.base.name, "' (", node.base.id, ")|");
end

function print_tree(node::Ranger.AbstractNode)
    println("---------- Tree ---------------")
    print_branch(UInt32(0), node)

    children = get_children(node)
    if children ≠ nothing
        print_sub_tree(children, UInt32(1))
    end
    println("-------------------------------");
end

function print_sub_tree(children::Array{Ranger.AbstractNode,1}, level::UInt32)
    for child in children
        sub_children = get_children(child)
        if sub_children ≠ nothing
            print_branch(level, child)
            print_sub_tree(sub_children, UInt32(level + 1))
        else
            print_branch(level, child)
        end
    end
end

function print_branch(level::UInt32, node::Ranger.AbstractNode) 
    for _ in 1:level 
        print("  ")
    end
    println(node)
end

end # End Module --------------------------------------------------------