export
    VectorTextNode,
    set_text!

import ..Nodes.draw

using ..Rendering

mutable struct VectorTextNode <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::TransformProperties{Float64}

    color::Palette

    # Holds font vector lines
    mesh::Geometry.Mesh

    function VectorTextNode(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = NodeData(Ranger.gen_id(world), name, parent)
        o.transform = TransformProperties{Float64}()
        o.color = Rendering.White()
        o.mesh = Geometry.Mesh()

        o
    end
end

function set_text!(node::VectorTextNode, font::Rendering.VectorFont, text::String)
    # Use glyph properties to adjust char location.
    xpos = 0.0

    for c in text
        glyph = Rendering.get_glyph(font, c)

        for vertex in glyph.vectors
            Geometry.add_vertex!(node.mesh, vertex.x + xpos, vertex.y)
        end

        xpos += font.horizontal_offset
    end

    Geometry.build!(node.mesh)

    Nodes.set_dirty!(node, true);
end

function Nodes.draw(node::VectorTextNode, context::Rendering.RenderContext)
    # Transform this node's vertices using the context
    if Nodes.is_dirty(node)
        Rendering.transform!(context, node.mesh)
        Nodes.set_dirty!(node, false)
    end

    Rendering.set_draw_color(context, node.color)
    Rendering.render_lines(context, node.mesh);
end
