export CrossNode

using ..Rendering:
    White

import ..Nodes.draw

# Required to override Nodes.draw()
using ..Nodes

mutable struct CrossNode <: AbstractNode
    base::NodeData
    transform::TransformProperties{Float64}

    mesh::Mesh

    color::Palette

    function CrossNode(id::UInt32, name::String, parent::AbstractNode)
        o = new()

        o.base = NodeData(id, name, parent)
        o.transform = TransformProperties{Float64}()
        o.mesh = Mesh()
        o.color = White()

        # horizontal
        add_vertex!(o.mesh, -0.5, 0.0)  
        add_vertex!(o.mesh, 0.5, 0.0)   

        # vertical
        add_vertex!(o.mesh, 0.0, -0.5)  
        add_vertex!(o.mesh, 0.0, 0.5)   
        
        build_it!(o.mesh)

        o
    end
end

function Nodes.draw(node::CrossNode, context::RenderContext)
    # Transform this node's vertices using the context
    if is_dirty(node)
        transform!(context, node.mesh)
        set_dirty!(node, false)
    end

    set_draw_color(context, node.color)

    v1 = node.mesh.bucket[1]
    v2 = node.mesh.bucket[2]
    v3 = node.mesh.bucket[3]
    v4 = node.mesh.bucket[4]
    draw_horz_line(context, v1.x, v2.x, v1.y)

    draw_vert_line(context, v3.x, v3.y, v4.y);
end
