# ----------------------------------------------------------
# Space mappings
# ----------------------------------------------------------

function map_device_to_view(context::Rendering.RenderContext,
    dx::Int32, dy::Int32, view_point::Geometry.Point{Float64})
    Math.transform!(context.inv_view_space, Float64(dx), Float64(dy), view_point);
end

view_point = Geometry.Point{Float64}()
nil_node = Nodes.NodeNil()

function map_device_to_node!(context::Rendering.RenderContext,
    dx::Int32, dy::Int32, node::Ranger.AbstractNode, local_point::Geometry.Point{Float64})
    wtn = world_to_node_transform(node, nil_node)
    # println(wtn)
    map_device_to_view(context, dx, dy, view_point)
    Math.transform!(wtn, view_point.x, view_point.y, local_point)
    # local_point.x *= node.transform.scale.x
    # local_point.y *= node.transform.scale.y
end

function world_to_node_transform(node::Ranger.AbstractNode, psuedoRoot::Ranger.AbstractNode)
    wtn = node_to_world_transform(node, psuedoRoot)
    Math.invert!(wtn)
    wtn
end

function node_to_world_transform(node::Ranger.AbstractNode, psuedoRoot::Ranger.AbstractNode)
    # println("*****************************")
    aft = Nodes.calc_transform!(node.transform)
    # println("node: ", node, ", aft: ", aft)

    # A transform to accumulate the parent transforms.
    comp = Math.copy(aft)

    out = Math.AffineTransform{Float64}()

    # Iterate "upwards" starting with the child towards the parents
    # starting with this child's parent.
    p = node.base.parent
    while (!Nodes.is_nil(p)) 
        # println("p: ", p, ", comp: ", comp)
        parentT = Nodes.calc_transform!(p.transform)
        # println("parentT: ", parentT)

        # Because we are iterating upwards we need to pre-multiply each
        # child. Ex: [child] x [parent]
        # ----------------------------------------------------------
        #           [comp] x [parentT]
        #               |
        #               | out
        #               v
        #             [comp] x [parentT] 
        #                  |
        #                  | out
        #                  v
        #               [comp] x [parentT...]
        #
        # This is a pre-multiply order
        # [child] x [parent of child] x [parent of parent of child]...
        #
        # In other words the child is mutiplied "into" the parent.
        Math.multiply!(comp, parentT, out)
        Math.set!(comp, out)

        if (p == psuedoRoot)
            println("Hit psuedoRoot")
            break;
        end
        
        # next parent upwards 
        p = p.base.parent
    end

    comp
end