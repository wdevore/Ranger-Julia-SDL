mutable struct BasicParticleNode <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    color::Rendering.Palette

    polygon::Geometry.Polygon

    function BasicParticleNode(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(name, parent, world)
        o.base.visible = false
        o.transform = Nodes.TransformProperties{Float64}()
        o.color = Rendering.White()

        o.polygon = Geometry.Polygon{Float64}()

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
function Nodes.update(node::BasicParticleNode, dt::Float64)
end

function Nodes.draw(node::BasicParticleNode, context::Rendering.RenderContext)
    if Nodes.is_dirty(node)
        Rendering.transform!(context, node.polygon)
        Nodes.set_dirty!(node, false)
    end

    Rendering.set_draw_color(context, node.color)
    Rendering.render_outlined_polygon(context, node.polygon, Rendering.CLOSED);
end
