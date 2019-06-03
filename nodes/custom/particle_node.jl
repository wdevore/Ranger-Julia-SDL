# A very basic particle visual. Use it for debugging, testing or as a template.
mutable struct ParticleNode <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    color::Rendering.Palette

    # The shape of the particle
    polygon::Geometry.Polygon

    particle::Particles.Particle{Float64}

    function ParticleNode(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(name, parent, world)
        o.transform = Nodes.TransformProperties{Float64}()
        o.color = Rendering.White()

        o.polygon = Geometry.Polygon{Float64}()
        o.particle::Particles.Particle{Float64}()

        Geometry.add_vertex!(o.polygon, -0.5, 0.5)
        Geometry.add_vertex!(o.polygon, 0.5, 0.5)
        Geometry.add_vertex!(o.polygon, 0.0, -0.5)

        Geometry.build!(o.polygon)

        Nodes.set_dirty!(o, true)

        o
    end
end

function Nodes.draw(node::ParticleNode, context::Rendering.RenderContext)
    if Nodes.is_dirty(node)
        Rendering.transform!(context, node.polygon)
        Nodes.set_dirty!(node, false)
    end

    Rendering.set_draw_color(context, node.color)
    Rendering.render_outlined_polygon(context, node.polygon, Rendering.CLOSED);
end
