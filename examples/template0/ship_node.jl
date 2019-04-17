# This node is made up of a circle and 2 rectangles
export Ship

mutable struct Ship <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    # Colors
    color::Rendering.Palette

    # Geometry for each component
    disc::Geometry.Polygon
    left_cell::Geometry.Polygon
    right_cell::Geometry.Polygon

    # Total AABB
    aabb::Geometry.AABB{Float64}

    # Hit detection for both projectiles and dragging
    det_disc::Nodes.Detection
    det_left::Nodes.Detection
    det_right::Nodes.Detection

    function Ship(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(gen_id(world), name, parent)
        o.transform = Nodes.TransformProperties{Float64}()
        o.color = Rendering.White()

        o.aabb = Geometry.AABB{Float64}()

        o.disc = Geometry.Polygon{Float64}()
        o.det_disc = Nodes.Detection(Rendering.Yellow(), Rendering.Red())

        o.left_cell = Geometry.Polygon{Float64}()
        o.det_left = Nodes.Detection(Rendering.Yellow(), Rendering.Red())

        o.right_cell = Geometry.Polygon{Float64}()
        o.det_right = Nodes.Detection(Rendering.Yellow(), Rendering.Red())

        build(o, world)
        o
    end
end

function build(node::Ship, world::Ranger.World)
    segment_size = 36
        
    # Build Geometry. Disc has radius of 1.0
    for degree in 0.0:segment_size:360.0
        Geometry.add_vertex!(node.disc, cos(deg2rad(degree)), sin(deg2rad(degree)))
    end
    Geometry.build!(node.disc)

    # Left cell vertically narrow
    Geometry.add_vertex!(node.left_cell, -0.75, 0.0)
    Geometry.add_vertex!(node.left_cell, -0.75, 1.7)
    Geometry.add_vertex!(node.left_cell, -0.30, 1.7)
    Geometry.add_vertex!(node.left_cell, -0.30, 0.0)
    Geometry.build!(node.left_cell)

    # right cell vertically narrow
    Geometry.add_vertex!(node.right_cell, 0.30, 0.0)
    Geometry.add_vertex!(node.right_cell, 0.30, 1.7)
    Geometry.add_vertex!(node.right_cell, 0.75, 1.7)
    Geometry.add_vertex!(node.right_cell, 0.75, 0.0)
    Geometry.build!(node.right_cell)
    
    Nodes.set_dirty!(node, true)
end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Nodes.update(node::Ship, dt::Float64)
end

# --------------------------------------------------------
# Rendering
# --------------------------------------------------------
function Nodes.draw(node::Ship, context::Rendering.RenderContext)
    if Nodes.is_dirty(node)
        Rendering.transform!(context, node.disc)
        Rendering.transform!(context, node.left_cell)
        Rendering.transform!(context, node.right_cell)
        Nodes.set_dirty!(node, false)
    end

    Rendering.set_draw_color(context, node.color)
    Rendering.render_outlined_polygon(context, node.disc, Rendering.CLOSED);
    Rendering.render_outlined_polygon(context, node.left_cell, Rendering.CLOSED);
    Rendering.render_outlined_polygon(context, node.right_cell, Rendering.CLOSED);

end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function Nodes.enter_node(node::Ship, man::Nodes.NodeManager)
    println("enter ", node);
end

function Nodes.exit_node(node::Ship, man::Nodes.NodeManager)
    println("exit ", node);
end

# --------------------------------------------------------
# Events
# --------------------------------------------------------
# Here we elect to receive keyboard events.
# function Nodes.io_event(node::GameLayer, event::Events.KeyboardEvent)
# end

function Nodes.io_event(node::Ship, event::Events.MouseEvent)
    # Nodes.io_event(node.circle, event)
end
