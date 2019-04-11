export 
    TranslateFilter

mutable struct TranslateFilter <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    # Collection of nodes.
    children::Array{Ranger.AbstractNode,1}

    # This node's parent translation component
    translate_component::Math.AffineTransform{Float64}

    function TranslateFilter(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(Ranger.gen_id(world), name, parent)
        o.transform = Nodes.TransformProperties{Float64}()
        o.children = Array{Ranger.AbstractNode,1}[]
        o.translate = Math.AffineTransform{Float64}()

        o
    end
end

# Filters are special in that they overload the visit() method
# Because this is a translate filter we "filter out" everything
# but translation component from the immediate parent.
function Nodes.visit(node::TranslateFilter, context::Rendering.RenderContext, interpolation::Float64)
    if !Nodes.is_visible(node)
        return;
    end

    Rendering.save!(context)

    children = Nodes.get_children(node)
    if children ≠ nothing
        for child in children
            Rendering.save!(context)

            if Nodes.has_parent(node)
                parent = node.base.parent
                inverse = parent.transform.inverse

                # This removes the immediate parent's transform effects
                Rendering.apply!(context, inverse)

                # Re-introduce only the parent's translation component by
                # excluding the other components
                Nodes.calc_filtered_transform!(parent.transform, false, true, true, node.translate_component)

                Rendering.apply!(context, node.translate_component)
            else
                println("TranslateFilter::visit: ", node, " has NO parent")
                return;
            end
            
            # Now visit the child with the modified context
            visit(child, context, interpolation)

            Rendering.restore!(context)
        end
    end

    Rendering.restore!(context)
end

# --------------------------------------------------------
# Grouping
# --------------------------------------------------------
function Nodes.get_children(node::TranslateFilter)
    node.children
end
