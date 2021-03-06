using .Nodes:
    NodeNil, is_nil

mutable struct NodeStack
    nodes::Array{Ranger.AbstractNode,1}

    next_node::Ranger.AbstractNode
    running_node::Ranger.AbstractNode

    function NodeStack()
        o = new()

        o.nodes = Array{Ranger.AbstractNode,1}[]
        o.next_node = NodeNil()
        o.running_node = NodeNil()

        o
    end
end

function is_empty(stack::NodeStack)
    length(stack.nodes) == 0
end

function has_next_node(stack::NodeStack)
    !is_nil(stack.next_node)
end

function has_running_node(stack::NodeStack)
    !is_nil(stack.running_node)
end

function set_next_node_nil(stack::NodeStack)
    # Setting node to stack means nil
    stack.next_node = NodeNil();
end

function set_running_node_nil(stack::NodeStack)
    # Setting node to stack means nil
    stack.running_node = NodeNil();
end

function set_running_node(stack::NodeStack)
    stack.running_node = stack.next_node;
end

function push(stack::NodeStack, node::Ranger.AbstractNode)
    stack.next_node = node

    println("Pushing node: ", stack.next_node)

    push!(stack.nodes, node);
end

function pop(stack::NodeStack)
    if !is_empty(stack)
        top = pop!(stack.nodes)
        stack.next_node = top
        println("NodeStack: popped: ", top);
    else
        println("NodeStack -- no nodes to pop.");
    end
end

function replace(stack::NodeStack, replacement::Ranger.AbstractNode)
    stack.next_node = replacement

    # Replacement is the act of popping and pushing. i.e. replacing
    # the stack top with the new node.
    if !is_empty(stack)
        top = pop!(stack.nodes)
        println("NodeStack: popped ", top, " for replacement with ", replacement);
    else
        println("NodeStack: replace WARNING, nothing popped");
    end

    push!(stack.nodes, replacement);
end