module Engine

include("sdl.jl")
include("io.jl")

export initialize, run

using ..Nodes:
    AbstractScene,
    NodeManager,
    pre_visit, post_visit, visit,
    push_node, update

using ..Ranger:
    World

manager = nothing

# billion ns in a second
const SECOND = 1000000000
# Maximum updates per second
const UPDATES_PER_SECOND = 30 

const UPDATE_PERIOD = 1000000000.0 / Float64(UPDATES_PER_SECOND) 

function initialize(title::String, build::Function)
    world = World(title)

    SDL(world)

    global manager = NodeManager(world)

    build(world)

    world
end

function run(world::World)
    println("running...")

    running = true

    ns_per_update = UInt64(round(UPDATE_PERIOD))
    println("ns_per_update: ", ns_per_update, "ns")

    frame_dt = Float64(ns_per_update) / 1000000.0
    println("frame_dt: ", frame_dt, "ms")

    lag = 0
    ups_cnt = 0
    fps_cnt = 0
    previous_t = time_ns()
    second_cnt = 0

    # Main game loop
    while running
        current_t = time_ns()

        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
        # Handle Events
        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
        haveEvents = true

        # Process any events that have been queued.
        while haveEvents
            event, haveEvents = poll_event!()
            ev_type = get_event_type(event)

            if (ev_type == SDL2.KEYDOWN)
                keySym = get_key_code_sym(event)

                if (keySym == SDL2.SDLK_ESCAPE)
                    running = false
                    continue
                end
            end
            
            # Route event to registered Nodes
            # route_event(nodes)

            handle_events!(event, ev_type)
        end        

        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
        # Update
        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
        elapsed_t = current_t - previous_t
        previous_t = current_t
        lag += elapsed_t

        lagging = true
        while lagging
            if lag >= ns_per_update
                update(manager, frame_dt)
                lag -= ns_per_update
                ups_cnt += 1
            else 
                lagging = false
            end
        end


        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
        # Render
        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
        interpolation = Float64(lag) / Float64(ns_per_update)

        pre_visit(manager)

        more_scenes = visit(manager, interpolation)

        if !more_scenes
            running = false
            continue
        end

        post_visit(manager)

        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
        # Present
        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--

        second_cnt += elapsed_t

        if second_cnt >= SECOND
            # println("fps_cnt (", fps_cnt, ") ups_cnt (", ups_cnt, ")")

            fps_cnt = 0
            second_cnt = 0
            ups_cnt = 0
        end

        fps_cnt += 1
        
        # sleep(0.1)
    end

    exit();
end

function push(scene::AbstractScene)
    # Auto-add SceneBoot
    push_node(manager, scene)
end

function exit()
    SDL2.Quit()
    println("Game exited");
end

end