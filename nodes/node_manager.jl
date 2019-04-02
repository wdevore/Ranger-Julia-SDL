using SimpleDirectMediaLayer
const SDL2 = SimpleDirectMediaLayer

export NodeManager
export pre_visit, post_visit, visit, update
export pop_node, push_node

using ..Rendering:
    RenderContext,
    save, restore, pre, post

using ..Ranger:
    World

using .Nodes:
    NodeStack,
    has_running_node, has_next_node, set_running_node

using .Scenes:
    AbstractScene,
    enter_node, transition,
    REPLACE_TAKE

import .Scenes:
    visit

mutable struct NodeManager
    clear_background::Bool

    context::RenderContext

    # A stack of nodes
    stack::NodeStack

    # timing_targets: RefCell<Vec<RNode>>,

    function NodeManager(world::World)
        o = new()
        
        o.clear_background = true
        o.context = RenderContext(world)
        o.stack = NodeStack()

        o
    end
end

function pre_visit(man::NodeManager)
    # Typically Scenes/Layers will clear the background themselves so the default
    # is to NOT perform a clear here.
    if man.clear_background
        # If vsync is enabled then this takes nearly 1/fps milliseconds.
        # For example, 60fps -> 1/60 = ~16.666ms
        pre(man.context)
    end
end

function visit(man::NodeManager, interpolation::Float64)
    if is_empty(man.stack)
        println("NodeManager: no more nodes to visit.")
        return false
    end

    if has_next_node(man.stack)
        set_next_node(man)
    end

    # This will save view-space matrix
    save(man.context)

    # If mouse coords changed then update view coords.
    # self.global_data.update_view_coords(&mut self.context);
    println("Transition..........")
    action = transition(man.stack.running_node)
    println("action ", action)

    if action == REPLACE_TAKE
        repl = get_replacement(man.stack.running_node)
        replace(man.stack, repl)
    end

    # Visit the running node
    visit(man.stack.running_node, man.context, interpolation)

    restore(man.context)

    true # continue to draw.
end

function post_visit(man::NodeManager)
    post(man.context);
end

function set_next_node(man::NodeManager)
    if has_running_node(man.stack)
        exit_node(man.stack.running_node)
    end

    set_running_node(man.stack)

    set_next_node_nil(man.stack)

    println("--- Running node --- ", man.stack.running_node)

    enter_node(man.stack.running_node);
end

function pop_node(man::NodeManager)
    pop(man.stack);
end

function push_node(man::NodeManager, node::AbstractNode)
    man.stack.next_node = node
    println("Pushing : ", node)
    push(man.stack, node);
end

# --------------------------------------------------------------------------
# Timing
# --------------------------------------------------------------------------
function update(man::NodeManager, dt::Float64)
end