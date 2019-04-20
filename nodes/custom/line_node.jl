export
    LineNode,
    set!

import ..Nodes.draw

mutable struct LineNode <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    mesh::Geometry.Mesh

    color::Rendering.Palette

    function LineNode(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(Ranger.gen_id(world), name, parent)
        o.transform = Nodes.TransformProperties{Float64}()
        o.mesh = Geometry.Mesh()
        o.color = Rendering.White()

        Geometry.add_vertex!(o.mesh, 0.0, 0.0)
        Geometry.add_vertex!(o.mesh, 0.0, 0.0)

        Geometry.build!(o.mesh)

        o
    end
end

function Nodes.draw(node::LineNode, context::Rendering.RenderContext)
    if Nodes.is_dirty(node)
        Rendering.transform!(context, node.mesh)
        Nodes.set_dirty!(node, false)
    end

    Rendering.set_draw_color(context, node.color)

    v1 = node.mesh.bucket[1]
    v2 = node.mesh.bucket[2]
    Rendering.draw_line(context, v1.x, v1.y, v2.x, v2.y);

end

function set!(node::LineNode, x1::Float64, y1::Float64, x2::Float64, y2::Float64)
    Geometry.set!(node.mesh.vertices[1], x1, y1)
    Geometry.set!(node.mesh.vertices[2], x2, y2)

    Nodes.set_dirty!(node, true);
end
