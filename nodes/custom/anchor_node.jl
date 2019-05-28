export AnchorNode

import ..Nodes.draw

# This is an opionated node. It will automatically inject a filter node
# between the given parent and this anchor node.

mutable struct AnchorNode <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    # Collection of nodes.
    children::Array{Ranger.AbstractNode,1}

    mesh::Geometry.Mesh

    color::Rendering.Palette

    function AnchorNode(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        # Automatically insert a filter between the parent and this anchor node.
        # filter uses the default behaviour of the transform filter.
        filter = Filters.TransformFilter(world, "AnchorTransformFilter", parent)
        # Add the filter as a child of parent.
        push!(parent.children, filter)
        # Now make the anchor a child of the filter.
        push!(filter.children, o)

        o.base = Nodes.NodeData(name, filter, world)
        o.transform = Nodes.TransformProperties{Float64}()
        o.children = Array{Ranger.AbstractNode,1}[]
        o.mesh = Geometry.Mesh()
        o.color = Rendering.White()

        # horizontal
        Geometry.add_vertex!(o.mesh, -0.5, -0.5)
        Geometry.add_vertex!(o.mesh, 0.5, 0.5)

        # vertical
        Geometry.add_vertex!(o.mesh, -0.5, 0.5)
        Geometry.add_vertex!(o.mesh, 0.5, -0.5)
        
        Geometry.build!(o.mesh)

        o
    end
end

function Nodes.draw(node::AnchorNode, context::Rendering.RenderContext)
    if Nodes.is_dirty(node)
        Rendering.transform!(context, node.mesh)
        Nodes.set_dirty!(node, false)
    end

    Rendering.set_draw_color(context, node.color)

    v1 = node.mesh.bucket[1]
    v2 = node.mesh.bucket[2]
    v3 = node.mesh.bucket[3]
    v4 = node.mesh.bucket[4]
    Rendering.draw_line(context, v1.x, v1.y, v2.x, v2.y)

    Rendering.draw_line(context, v3.x, v3.y, v4.x, v4.y);
end

# --------------------------------------------------------
# Grouping
# --------------------------------------------------------
function Nodes.get_children(node::AnchorNode)
    node.children
end
