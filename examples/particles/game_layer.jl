using Printf

mutable struct GameLayer <: Ranger.AbstractNode
    base::Nodes.NodeData
    transform::Nodes.TransformProperties{Float64}

    # Collection of nodes.
    children::Array{Ranger.AbstractNode,1}

    min::Geometry.Point{Float64}
    max::Geometry.Point{Float64}
    buc_min::Geometry.Point{Float64}
    buc_max::Geometry.Point{Float64}

    host_node::HostNode
    
    function GameLayer(world::Ranger.World, name::String, parent::Ranger.AbstractNode)
        o = new()

        o.base = Nodes.NodeData(name, parent, world)
        o.children = Array{Ranger.AbstractNode,1}[]
        o.transform = Nodes.TransformProperties{Float64}()

        o.min = Geometry.Point{Float64}()
        o.max = Geometry.Point{Float64}()
        o.buc_min = Geometry.Point{Float64}()
        o.buc_max = Geometry.Point{Float64}()

        o
    end
end

function build(layer::GameLayer, world::Ranger.World)
    hw = Float64(world.view_width) / 2.0
    hh = Float64(world.view_height) / 2.0

    # top-left
    Geometry.set!(layer.min, -hw, -hh)

    # bottom-right
    Geometry.set!(layer.max, hw, hh)

    layer.host_node = HostNode(world, "HostNode", layer)
    Nodes.set_scale!(layer.host_node, 150.0)
    push!(layer.children, layer.host_node);

end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Nodes.update(layer::GameLayer, dt::Float64)
end

# --------------------------------------------------------
# Rendering
# --------------------------------------------------------
function Nodes.draw(layer::GameLayer, context::Rendering.RenderContext)
    if Nodes.is_dirty(layer)
        Rendering.transform!(context, layer.min, layer.max, layer.buc_min, layer.buc_max)
        Nodes.set_dirty!(layer, false)
    end

    # Render background (i.e. a solid gray color)
    Rendering.set_draw_color(context, RangerGame.darkgray)
    Rendering.render_aa_rectangle(context, layer.buc_min, layer.buc_max, Rendering.FILLED)

    # Draw layer name
    Rendering.set_draw_color(context, RangerGame.white)
    Rendering.draw_text(context, 10, 10, layer.base.name, 2, 2, false)
end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function Nodes.enter_node(layer::GameLayer, man::Nodes.NodeManager)
    println("enter ", layer)

    # Register node as a timing target in order to receive updates
    Nodes.register_target(man, layer)

    # Register host so it too can get updates
    Nodes.register_target(man, layer.host_node)

    # Register for io events such as keyboard or mouse
    Nodes.register_event_target(man, layer)
end

function Nodes.exit_node(layer::GameLayer, man::Nodes.NodeManager)
    println("exit ", layer)
    Nodes.unregister_target(man, layer)
    Nodes.unregister_target(man, layer.host_node)

    Nodes.unregister_event_target(man, layer)
end

# --------------------------------------------------------
# Events
# --------------------------------------------------------

# --------------------------------------------------------
# Grouping
# --------------------------------------------------------
function Nodes.get_children(node::GameLayer)
    node.children
end
