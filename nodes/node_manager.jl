using SimpleDirectMediaLayer
const SDL2 = SimpleDirectMediaLayer

export NodeManager
export pre_visit, post_visit

using ..Rendering:
    RenderContext, save, restore, pre, post

using ..Ranger:
    World

using .Nodes
    NodeStack

using .Scenes
    SceneActions

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

    action = transition(man.stack.running_node)

    if action == REPLACE
        repl = get_replacement(man.stack.running_node)
        replace(man.stack, repl)
    end

    # Visit the running node
    visit(man.stack.running_node, man, interpolation)

    restore(man.context)

    true # continue to draw.
end

function post_visit(man::NodeManager)
    post(man.context)
end

function set_next_node(man::NodeManager)
end