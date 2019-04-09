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
    # println("############")
    # println(v1)
    # println(v2)
    # println(v3)
    # println(v4)
    # println("@@@@@@@@@@@@@2")
    draw_horz_line(context, Int32(round(v1.x)), Int32(round(v2.x)), Int32(round(v1.y)))

    draw_vert_line(context, Int32(round(v3.x)), Int32(round(v3.y)), Int32(round(v4.y)));
end
