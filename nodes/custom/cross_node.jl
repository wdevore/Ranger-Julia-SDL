export CrossNode

import ..Nodes.draw

mutable struct CrossNode <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    mesh::Geometry.Mesh

    color::Rendering.Palette

    function CrossNode(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(Ranger.gen_id(world), name, parent)
        o.transform = Nodes.TransformProperties{Float64}()
        o.mesh = Geometry.Mesh()
        o.color = Rendering.White()

        # horizontal
        Geometry.add_vertex!(o.mesh, -Float64(world.view_width) / 2.0, 0.0)  
        Geometry.add_vertex!(o.mesh, Float64(world.view_width), 0.0)   

        # vertical
        Geometry.add_vertex!(o.mesh, 0.0, -Float64(world.view_height))  
        Geometry.add_vertex!(o.mesh, 0.0, Float64(world.view_height))   
        
        Geometry.build!(o.mesh)

        o
    end
end

function Nodes.draw(node::CrossNode, context::Rendering.RenderContext)
    if Nodes.is_dirty(node)
        Rendering.transform!(context, node.mesh)
        Nodes.set_dirty!(node, false)
    end

    Rendering.set_draw_color(context, node.color)

    v1 = node.mesh.bucket[1]
    v2 = node.mesh.bucket[2]
    v3 = node.mesh.bucket[3]
    v4 = node.mesh.bucket[4]
    Rendering.draw_horz_line(context, v1.x, v2.x, v1.y)

    Rendering.draw_vert_line(context, v3.x, v3.y, v4.y);
end
