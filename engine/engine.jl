export Engine

module Engine

include("sdl.jl")
include("io.jl")

export initialize, run

using Printf

using ..Nodes:
    NodeManager,
    pre_visit, post_visit, visit,
    push_node, update, route_events

using ..Ranger:
    World, AbstractScene

using ..Rendering:
    Orange, White,
    draw_text, set_draw_color,
    draw_filled_rectangle, draw_outlined_rectangle

using ..Events:
    KeyboardEvent

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

    # Allow client to build game
    build(world)

    world
end

function run(world::World)
    println("running...")

    running = true

    ns_per_update = UInt64(round(UPDATE_PERIOD))
    # println("ns_per_update: ", ns_per_update, "ns")

    frame_dt = Float64(ns_per_update) / 1000000.0
    # println("frame_dt: ", frame_dt, "ms")

    lag = 0

        # ***************************
        # Debugging only
        # ***************************
    fps_cnt = fps = 0
    ups_cnt = ups = 0
    previous_t = time_ns()
    second_cnt = 0
    avg_render = 0.0
    render_elapsed_cnt = 0

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
            
            if haveEvents
                ev_type = get_event_type(event)

                if (ev_type == SDL2.KEYDOWN)
                    keySym = get_key_code_sym(event)
    
                    if (keySym == SDL2.SDLK_ESCAPE)
                        running = false
                        continue
                    end
                end
                # print_event(event)

                keyboard = KeyboardEvent()
                keyboard.keycode = get_key_code_sym(event)
                keyboard.scancode = get_scancode(event)
                keyboard.modifier = get_modifier(event)
                keyboard.repeat = get_repeat(event)

                # Route event to registered Nodes
                route_events(manager, keyboard)
            end
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

        # sleep(0.01666)

        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
        # Render
        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
        pre_visit(manager)

        # Capture time AFTER pre_visit. If vsync is enabled
        # then time includes the vertical refresh which ~16.667ms
        render_t = time_ns()

        interpolation = Float64(lag) / Float64(ns_per_update)

        more_scenes = visit(manager, interpolation)

        if !more_scenes
            running = false
            continue
        end

        second_cnt += elapsed_t

        # ***************************
        # Debugging only
        # ***************************
        draw_stats(fps, ups, avg_render, world)

        render_elapsed_t =  time_ns() - render_t
        render_elapsed_cnt += render_elapsed_t

        if second_cnt >= SECOND
            avg_render = (Float64(render_elapsed_cnt) /  Float64(fps_cnt)) / 1000000.0
            fps = fps_cnt
            ups = ups_cnt
            # text = @sprintf("fps (%2d), ups(%2d) %2.4f", fps, ups, avg_render)
            # println(text)
            # println("fps (", fps, ") ups (", ups, "), ren ", avg_render)

            fps_cnt = 0
            ups_cnt = 0
            second_cnt = 0
            render_elapsed_cnt = 0
        end

        fps_cnt += 1
        # ***************************

        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
        # Present
        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
        post_visit(manager)
        
    end

    exit();
end

function push(scene::AbstractScene)
    push_node(manager, scene)
end

function exit()
    SDL2.Quit()
    println("Game exited");
end

# ***************************
# Debugging only
# ***************************
orange = Orange()
white = White()

function draw_stats(fps::Integer, ups::Integer, avg_render::Float64, world::World)
    # set_draw_color(manager.context, orange)
    # rect = SDL2.Rect(0, 0, 1, 1)
    # rect.x = 100
    # rect.y = 100
    # rect.w = 400
    # rect.h = 400
    # draw_filled_rectangle(manager.context, rect)
    # set_draw_color(manager.context, white)
    # draw_outlined_rectangle(manager.context, rect)

    set_draw_color(manager.context, orange)
    text = @sprintf("fps(%2d), ups(%2d) rend(%2.4f)", fps, ups, avg_render)
    x = 10
    y = world.window_height - 24
    draw_text(manager.context, x, y, text, 2, 2, false)

end

end # Module -----------------------------------------------------------