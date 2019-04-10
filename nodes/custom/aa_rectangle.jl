export AARectangle

export
    set_min!, set_max!

import ..Nodes.draw

mutable struct AARectangle <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    color::Rendering.Palette

    min::Geometry.Point{Float64}
    max::Geometry.Point{Float64}
    buc_min::Geometry.Point{Float64}
    buc_max::Geometry.Point{Float64}

    function AARectangle(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = NodeData(Ranger.gen_id(world), name, parent)
        o.transform = TransformProperties{Float64}()
        o.color = Rendering.White()

        o.min = Geometry.Point{Float64}()
        o.max = Geometry.Point{Float64}()
        o.buc_min = Geometry.Point{Float64}()
        o.buc_max = Geometry.Point{Float64}()

        o
    end
end

function Nodes.draw(node::AARectangle, context::Rendering.RenderContext)
    if Nodes.is_dirty(node)
        Math.transform!(context, node.min, node.max, node.buc_min, node.buc_max)
        Nodes.set_dirty!(node, false)
    end

    Rendering.set_draw_color(context, node.color)
    Rendering.render_aa_rectangle(context, node.buc_min, node.buc_max, Rendering.FILLED);
end

function set_min!(node::AARectangle, x::Float64, y::Float64)
    Geometry.set!(node.min, x, y)
    Nodes.set_dirty!(node, true)
end

function set_max!(node::AARectangle, x::Float64, y::Float64)
    Geometry.set!(node.max, x, y)
    Nodes.set_dirty!(node, true)
end