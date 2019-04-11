export
    NodeManager,
    pre_visit, post_visit, visit, update,
    pop_node, push_node,
    register_target, unregister_target,
    register_event_target, unregister_event_target

using ..Rendering
using ...Ranger
using .Nodes
using .Scenes
using ..Events

import .Nodes.visit

mutable struct NodeManager
    clear_background::Bool

    context::RenderContext

    # A stack of nodes
    stack::NodeStack

    timing_targets::Array{Ranger.AbstractNode,1}
    event_targets::Array{Ranger.AbstractNode,1}

    function NodeManager(world::Ranger.World)
        o = new()
        
        o.clear_background = true

        o.context = Rendering.RenderContext(world)
        Rendering.initialize(o.context, world)

        o.stack = Nodes.NodeStack()

        o.timing_targets = Array{Ranger.AbstractNode,1}[]
        o.event_targets = Array{Ranger.AbstractNode,1}[]

        o
    end
end

function pre_visit(man::NodeManager)
    # Typically Scenes/Layers will clear the background themselves so the default
    # is to NOT perform a clear here.
    if man.clear_background
        # If vsync is enabled then this takes nearly 1/fps milliseconds.
        # For example, 60fps -> 1/60 = ~16.666ms
        Rendering.pre(man.context)
    end
end

function visit(man::NodeManager, interpolation::Float64)
    if Nodes.is_empty(man.stack)
        println("NodeManager: no more nodes to visit.")
        return false
    end

    if Nodes.has_next_node(man.stack)
        Nodes.set_next_node(man)
    end

    # This will save view-space matrix
    Rendering.save(man.context)

    # If mouse coords changed then update view coords.
    # self.global_data.update_view_coords(&mut self.context);
    action = Nodes.transition(man.stack.running_node)

    if action == Scenes.REPLACE_TAKE
        repl = Nodes.get_replacement(man.stack.running_node)
        Nodes.replace(man.stack, repl)

        # Immediately switch to the new runner
        if Nodes.has_next_node(man.stack)
            Nodes.set_next_node(man)
        end
    end

    # Visit the running node
    Nodes.visit(man.stack.running_node, man.context, interpolation)

    Rendering.restore(man.context)

    true # continue to draw.
end

function post_visit(man::NodeManager)
    Rendering.post(man.context);
end

function set_next_node(man::NodeManager)
    if Nodes.has_running_node(man.stack)
        exit_nodes(man.stack.running_node, man)
    end

    Nodes.set_running_node(man.stack)

    Nodes.set_next_node_nil(man.stack)

    println("Running node ", man.stack.running_node)

    enter_nodes(man.stack.running_node, man);
end

function enter_nodes(node::Ranger.AbstractNode, man::NodeManager)
    Nodes.enter_node(node, man)

    children = get_children(node)
    if children ≠ nothing
        for child in children
            enter_nodes(child, man)
        end
    end
end

function exit_nodes(node::Ranger.AbstractNode, man::NodeManager)
    exit_node(node, man)

    children = get_children(node)
    if children ≠ nothing
        for child in children
            exit_nodes(child, man)
        end
    end
end

function pop_node(man::NodeManager)
    Nodes.pop(man.stack);
end

function push_node(man::NodeManager, node::Ranger.AbstractNode)
    man.stack.next_node = node
    println("Pushing : ", node)
    Nodes.push(man.stack, node);
end

# --------------------------------------------------------------------------
# Timing
# --------------------------------------------------------------------------
function update(man::NodeManager, dt::Float64)
    # println("NodeManager::update")
    for target in man.timing_targets
        Nodes.update(target, dt)
    end
end

function register_target(man::NodeManager, target::Ranger.AbstractNode)
    println("Register ", target, " target")
    push!(man.timing_targets, target);
end

function unregister_target(man::NodeManager, target::Ranger.AbstractNode)
    idx = findfirst(isequal(target), man.timing_targets)
    if idx ≠ nothing
        println("UnRegistering idx:(", idx, ") ", man.timing_targets[idx], " target");
        node = deleteat!(man.timing_targets, idx)
    else
        println("Unable to UnRegister ", target, " target");
    end
end

# --------------------------------------------------------------------------
# IO events
# --------------------------------------------------------------------------
function register_event_target(man::NodeManager, target::Ranger.AbstractNode)
    println("Register ", target, " event target")
    push!(man.event_targets, target);
end

function unregister_event_target(man::NodeManager, target::Ranger.AbstractNode)
    idx = findfirst(isequal(target), man.event_targets)
    if idx ≠ nothing
        println("UnRegistering idx:(", idx, ") ", man.event_targets[idx], " event target");
        node = deleteat!(man.event_targets, idx)
    else
        println("Unable to UnRegister ", target, " event target");
    end
end

function route_events(man::NodeManager, keyboard::Events.KeyboardEvent)
    # println(keyboard)
    for target in man.event_targets
        Nodes.io_event(target, keyboard)
    end
end

function route_events(man::NodeManager, mouse::Events.MouseEvent)
    println(mouse)
end