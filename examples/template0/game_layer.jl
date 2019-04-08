
mutable struct GameLayer <: AbstractNode
    base::NodeData

    # Collection of nodes.
    children::Array{AbstractNode,1}

    function GameLayer(world::World, name::String, parent::AbstractNode)
        obj = new()

        obj.base = NodeData(gen_id(world), name, parent)
        obj.children = Array{AbstractNode,1}[]

        obj
    end
end

function build(layer::GameLayer, world::World)
    # println("GameLayer has parent: ", has_parent(node))
end

# --------------------------------------------------------
# Timing
# --------------------------------------------------------
function Ranger.Nodes.update(layer::GameLayer, dt::Float64)
    # println("GameLayer::update : ", layer)
end

# --------------------------------------------------------
# Visits
# --------------------------------------------------------
function Ranger.Nodes.visit(layer::GameLayer, context::RenderContext, interpolation::Float64)
    # println("GameLayer visit ", layer);
    set_draw_color(context, white)
    draw_text(context, 10, 10, layer.base.name, 3, 2, false)
end

# --------------------------------------------------------
# Life cycle events
# --------------------------------------------------------
function Ranger.Nodes.enter_node(layer::GameLayer, man::NodeManager)
    println("enter ", layer);
    # Register node as a timing target in order to receive updates
    register_target(man, layer)
    register_event_target(man, layer);
end

function Ranger.Nodes.exit_node(layer::GameLayer, man::NodeManager)
    println("exit ", layer);
    unregister_target(man, layer);
    unregister_event_target(man, layer);
end

function Ranger.Nodes.transition(layer::GameLayer)
    NO_ACTION
end

function Ranger.Nodes.get_replacement(layer::GameLayer)
    layer.replacement
end

# --------------------------------------------------------
# Events
# --------------------------------------------------------
# Here we elect to receive keyboard events.
function Ranger.Nodes.io_event(node::GameLayer, event::KeyboardEvent)
    println("io_event ", event)
end
