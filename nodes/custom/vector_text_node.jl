export
    VectorTextNode,
    set_text!

import ..Nodes.draw

using ..Rendering

mutable struct VectorTextNode <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    text::String

    color::Palette

    # Holds font vector lines
    mesh::Geometry.Mesh

    function VectorTextNode(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(name, parent, world)
        o.transform = Nodes.TransformProperties{Float64}()
        o.color = Rendering.White()
        o.mesh = Geometry.Mesh()

        o
    end
end

function set_text!(node::VectorTextNode, text::String)
    node.text = text
    Nodes.set_dirty!(node, true);
end

function rebuild!(node::VectorTextNode, context::Rendering.RenderContext)
    # Use glyph properties to adjust char location.
    xpos = 0.0

    for c in node.text
        glyph = Rendering.get_glyph(context.vector_font, c)

        for vertex in glyph.vectors
            Geometry.add_vertex!(node.mesh, vertex.x + xpos, vertex.y)
        end

        xpos += context.vector_font.horizontal_offset
    end

    Geometry.build!(node.mesh)
end

function Nodes.draw(node::VectorTextNode, context::Rendering.RenderContext)
    # Transform this node's vertices using the context
    if Nodes.is_dirty(node)
        rebuild!(node, context)
        Rendering.transform!(context, node.mesh)
        Nodes.set_dirty!(node, false)
    end

    Rendering.set_draw_color(context, node.color)
    Rendering.render_lines(context, node.mesh);
end
