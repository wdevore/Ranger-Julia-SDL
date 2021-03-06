export 
    TransformFilter

import .Ranger.Nodes.calc_transform!

# By default the TransformFilter will exclude or "block" rotations and scales from
# propagating to the children, but allow translations.
# 
mutable struct TransformFilter <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    # Collection of nodes.
    children::Array{Ranger.AbstractNode,1}

    # This node's parent translation component
    components::Math.AffineTransform{Float64}

    # What to exclude from the immediate parent
    exclude_translation::Bool
    exclude_rotation::Bool
    exclude_scale::Bool

    function TransformFilter(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(name, parent, world)
        o.transform = Nodes.TransformProperties{Float64}()
        o.children = Array{Ranger.AbstractNode,1}[]

        o.components = Math.AffineTransform{Float64}()

        o.exclude_translation = false
        o.exclude_rotation = true
        o.exclude_scale = true

        o
    end
end

# Filters are special in that they overload the visit() method
function Nodes.visit(node::TransformFilter, context::Rendering.RenderContext, interpolation::Float64)
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

                # Re-introduce only the parent's components as defined by
                # exclusion flags.
                Nodes.calc_filtered_transform!(parent.transform, 
                    node.exclude_translation, node.exclude_rotation, node.exclude_scale,
                    node.components)

                # Combine using pre-multiply
                # "parent.transform.inverse" removes the immediate parent's transform effects
                Math.multiply!(node.components, parent.transform.inverse, node.transform.aft)

                # Merge them with the current context.
                Rendering.apply!(context, node.transform.aft)
            else
                println("TransformFilter::visit: ", node, " has NO parent")
                return;
            end
            
            # Now visit the child with the modified context
            Nodes.visit(child, context, interpolation)

            Rendering.restore!(context)
        end
    end

    Rendering.restore!(context)
end

# Filter nodes calc their own transform on behalf of their children
function Nodes.calc_transform!(node::TransformFilter)
    node.transform.aft
end

# --------------------------------------------------------
# Grouping
# --------------------------------------------------------
function Nodes.get_children(node::TransformFilter)
    node.children
end

# Older version that doesn't set aft
# function Nodes.visit(node::TransformFilter, context::Rendering.RenderContext, interpolation::Float64)
#     if !Nodes.is_visible(node)
#         return;
#     end

#     Rendering.save!(context)

#     children = Nodes.get_children(node)
#     if children ≠ nothing
#         for child in children
#             Rendering.save!(context)

#             if Nodes.has_parent(node)
#                 parent = node.base.parent

#                 # This removes the immediate parent's transform effects
#                 Rendering.apply!(context, parent.transform.inverse)

#                 # Re-introduce only the parent's components as defined by
#                 # exclusion flags.
#                 Nodes.calc_filtered_transform!(parent.transform, 
#                     node.exclude_translation, node.exclude_rotation, node.exclude_scale,
#                     node.components)

#                 # Merge them with the current context.
#                 Rendering.apply!(context, node.components)
#             else
#                 println("TransformFilter::visit: ", node, " has NO parent")
#                 return;
#             end
            
#             # Now visit the child with the modified context
#             Nodes.visit(child, context, interpolation)

#             Rendering.restore!(context)
#         end
#     end

#     Rendering.restore!(context)
# end
