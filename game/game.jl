module Game

include("sdl.jl")
include("io.jl")

export initialize, run

using ..Nodes
    NodeManager, pre_visit, post_visit

using ..Ranger:
    World

manager = nothing

function initialize(title::String, build::Function)
    world = World(title)

    SDL(world)

    build(world)

    global manager = NodeManager(world)

    world
end

function run(world::World)
    println("running...")

    running = true

    # Main game loop
    while running
        # ^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--
        # Handle Events
        # ^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--
        haveEvents = true

        # Process any events that have been queued.
        while haveEvents
            event, haveEvents = poll_event!()
            ev_type = get_event_type(event)

            if (ev_type == SDL2.KEYDOWN)
                keySym = get_key_code_sym(event)

                if (keySym == SDL2.SDLK_ESCAPE)
                    running = false
                end
            end
            
            # Route event to registered Nodes
            # route_event(nodes)

            handle_events!(event, ev_type)
        end        

        # ^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--
        # Update
        # ^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--

        # ^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--
        # Render
        # ^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--
        pre_visit(manager)

        post_visit(manager)

        # ^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--
        # Present
        # ^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--^--
        # println("Sleep")
        # sleep(0.1)
    end

    exit();
end

function exit()
    SDL2.Quit()
    println("Game exited");
end

end