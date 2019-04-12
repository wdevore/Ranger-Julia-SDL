export 
    OutlinedTriangle,
    set!

import ..Nodes.draw

mutable struct OutlinedTriangle <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    color::Rendering.Palette

    polygon::Geometry.Polygon

    function OutlinedTriangle(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(Ranger.gen_id(world), name, parent)
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

function Nodes.draw(node::OutlinedTriangle, context::Rendering.RenderContext)
    if Nodes.is_dirty(node)
        Rendering.transform!(context, node.polygon)
        Nodes.set_dirty!(node, false)
    end

    Rendering.set_draw_color(context, node.color)
    Rendering.render_outlined_polygon(context, node.polygon, Rendering.CLOSED);
end

function set!(node::OutlinedTriangle, v1::Point{Float64}, v2::Point{Float64}, v3::Point{Float64})
    Geometry.set!(node.polygon.mesh.vertices[1], v1)
    Geometry.set!(node.polygon.mesh.vertices[2], v2)
    Geometry.set!(node.polygon.mesh.vertices[3], v3)
    
    Nodes.set_dirty!(node, true)
end

