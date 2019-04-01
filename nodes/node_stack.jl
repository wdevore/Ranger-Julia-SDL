using .Nodes
    AbstractNode

mutable struct NodeStack
    nodes::Array{AbstractNode, 1}

    next_node::AbstractNode
    running_node::AbstractNode

    function NodeStack()
        o = new()

        o.node = AbstractNode[]
        o.next_node = o     # Setting node to stack == not present
        o.running_node = o

        o
    end
end

function is_empty(stack::NodeStack)
    length(stack) == 0
end

function has_next_node(stack::NodeStack)
    # If node == stack then node isn't considered present
    !(stack.next_node === stack)
end

function has_running_node(stack::NodeStack)
    !(stack.running_node === stack)
end

function set_next_node_nil(stack::NodeStack)
    # Setting node to stack means nil
    stack.next_node == stack;
end

function set_running_node_nil(stack::NodeStack)
    # Setting node to stack means nil
    stack.running_node == stack;
end

function set_running_node(stack::NodeStack)
    stack.running_node == stack.next_node;
end

function push(stack::NodeStack, node::AbstractNode)
    stack.next_node = node

    println("Pushing node: ", stack.next_node)

    push!(stack.nodes, node);
end

function pop(stack::NodeStack)
    if !is_empty(stack)
        top = pop!(stack.nodes)
        stack.next_node = node
        println("NodeStack: popped: ", top);
    else
        println("NodeStack -- no nodes to pop.");
    end
end

function replace(stack::NodeStack, replacement::AbstractNode)
    stack.next_node = replacement

    println("Replacing with : ", replacement)

    # Replacement is the act of popping and pushing. i.e. replacing
    # the stack top with the new node.
    if !is_empty(stack)
        top = pop!(stack.nodes)
        println("NodeStack: popped for replacement: ", top);
    else
        println("NodeStack: replace WARNING, nothing popped");
    end

    push!(stack.nodes, replacement);
end