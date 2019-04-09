# ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
# Nodes API interface
# ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
module Nodes

export
    Nodes,
    enter_node

export 
    visit, enter_node, exit_node,
    set_position!

using ..Ranger:
    AbstractNode, AbstractScene, AbstractIOEvent

using ..Geometry

using ..Math:
    AffineTransform,
    to_identity!, make_translate!, rotate!, scale!, invert!, copy

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

# -----------------------------------------------------------------------
# Base defaults
# -----------------------------------------------------------------------
# -----------------------------------------------------------
# Abstract Nodes
# -----------------------------------------------------------
function has_parent(node::AbstractNode)
    !is_nil(node.base.parent)
end

using ..Rendering:
    RenderContext,
    apply!

function visit(node::AbstractNode, context::RenderContext, interpolation::Float64)
    # println("AbstractNode::visit ", node);
    if !is_visible(node)
        return;
    end

    save(context)

    # Because position and angles are dependent
    # on lerping we perform interpolation first.
    interpolate(node, interpolation)

    aft = node.transform.aft

    if is_dirty(node)
        aft = calc_transform!(node.transform)
        # println(node.base.name, " aft: ", aft)
    end

    apply!(context, aft)

    children = get_children(node)
    if children ≠ nothing
        draw(node, context)

        for child in children
            visit(child, context, interpolation)
        end
    else
        draw(node, context)
    end

    restore(context)

    # println("End visit ----------------------------------------------")
end

function interpolate(node::AbstractNode, interpolation::Float64)
    # println("AbstractNode::interpolate ", node);
end

function draw(node::AbstractNode, context::RenderContext)
    # println("AbstractNode::draw ", node);
end

function enter_node(node::AbstractNode, man::NodeManager)
    println("AbstractNode::enter ", node);
end

function exit_node(node::AbstractNode, man::NodeManager)
    println("AbstractNode::exit ", node);
end

function get_children(node::AbstractNode)
    nothing
end

    function io_event(node::AbstractNode, event::AbstractIOEvent)
    println("AbstractScene::io_event ", event)
end

function is_visible(node::AbstractNode)
    node.base.visible
end

function is_dirty(node::AbstractNode)
    node.base.dirty
end

# ripple dirty flag
function set_dirty!(node::AbstractNode, dirty::Bool)
    node.base.dirty = dirty
end

function ripple_dirty!(node::AbstractNode, dirty::Bool)
    children = get_children(node)
    if children ≠ nothing
        for child in children
            ripple_dirty!(child, dirty)
        end
    end
    set_dirty!(node, dirty)
end

function set_position!(node::AbstractNode, x::T, y::T) where {T <: AbstractFloat}
    Geometry.set!(node.transform.position, x, y)
    ripple_dirty!(node, true);
end

function set_rotation_in_degrees!(node::AbstractNode, rotation::T) where {T <: AbstractFloat}
    node.transform.rotation = deg2rad(rotation);
    ripple_dirty!(node, true);
end

function set_scale!(node::AbstractNode, s::T) where {T <: AbstractFloat}
    Geometry.set!(node.transform.scale, s, s);
    ripple_dirty!(node, true);
end

function set_nonuniform_scale!(node::AbstractNode, sx::T, sy::T) where {T <: AbstractFloat}
    Geometry.set!(node.transform.scale, sx, sy)
    ripple_dirty!(node, true);
end

# -----------------------------------------------------------
# Abstract Scenes
# -----------------------------------------------------------
function is_nil(node::AbstractScene)
    node.base.id == 0
end

function has_replacement(node::AbstractScene)
    !is_nil(node.replacement)
end

function has_parent(node::AbstractScene)
    !is_nil(node.base.parent)
end

function enter_node(node::AbstractScene, man::NodeManager)
    println("AbstractScene::enter ", node);
end

function exit_node(node::AbstractScene, man::NodeManager)
    println("AbstractScene::exit ", node);
end

function get_children(node::AbstractScene)
    nothing
end

# --------------------------------------------------------------------------
# Timing
# --------------------------------------------------------------------------
function update(node::AbstractNode, dt::Float64)
    println("AbstractNode::update : ", node)
end


# --------------------------------------------------------------------------
# Misc debugging
# --------------------------------------------------------------------------
import Base.show

function Base.show(io::IO, node::AbstractNode)
    print(io, "|'", node.base.name, "' (", node.base.id, ")|");
end

function print_tree(node::AbstractNode)
    println("---------- Tree ---------------")
    print_branch(UInt32(0), node)

    children = get_children(node)
    if children ≠ nothing
        print_sub_tree(children, UInt32(1))
    end
    println("-------------------------------");
end

function print_sub_tree(children::Array{AbstractNode,1}, level::UInt32)
    for child in children
        sub_children = get_children(child)
        if sub_children ≠ nothing
            print_branch(level, child)
            print_sub_tree(sub_children, level + 1)
        else
            print_branch(level, child)
        end
    end
end

function print_branch(level::UInt32, node::AbstractNode) 
    for _ in 1:level 
        print("  ")
    end
    println(node)
end

end # End Module --------------------------------------------------------