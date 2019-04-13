export Engine

module Engine

include("sdl.jl")
include("io.jl")

export initialize, run

using Printf

using ..Nodes
using ..Ranger
using ..Rendering
using ..Events
using ..Geometry

manager = nothing

# billion ns in a second
const SECOND = 1000000000
# Maximum updates per second
const UPDATES_PER_SECOND = 30 

const UPDATE_PERIOD = 1000000000.0 / Float64(UPDATES_PER_SECOND) 

function initialize(title::String, build::Function)
    world = Ranger.World(title)

    SDL(world)

    global manager = Nodes.NodeManager(world)

    # Allow client to build game
    build(world)

    world
end

function run(world::Ranger.World)
    println("running...")

    running = true

    ns_per_update = UInt64(round(UPDATE_PERIOD))
    # println("ns_per_update: ", ns_per_update, "ns")

    frame_dt = Float64(ns_per_update) / 1000000.0
    println("Frame period: ", frame_dt, "ms")

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
    display_coords = true
    display_on = true
    step_enabled = false

    keyboard = Events.KeyboardEvent()
    mouse = Events.MouseEvent()

    # Main game loop
    while running
        current_t = time_ns()

        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
        # Handle Events
        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
        haveEvents = true

        # Process any events that have been queued.
        while haveEvents
            event, haveEvents = Events.poll_event!()
            
            if haveEvents
                ev_type = Events.get_event_type(event)

                if (ev_type == SDL2.KEYDOWN)
                    keySym = Events.get_key_code_sym(event)
    
                    if (keySym == SDL2.SDLK_ESCAPE)
                        running = false
                        continue
                    end

                    Events.set!(keyboard, event)
                    # Events.print_keyboard_event(event)
    
                    if keyboard.keycode == SDL2.SDLK_m
                        display_coords = !display_coords
                    end

                    if keyboard.keycode == SDL2.SDLK_n
                        display_on = !display_on
                    end

                    # Route event to registered Nodes
                    Nodes.route_events(manager, keyboard)
                elseif ev_type == SDL2.MOUSEMOTION
                    Events.set!(mouse, event)

                    Nodes.route_events(manager, mouse)
                end
            end
        end        

        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
        # Update
        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
        elapsed_t = current_t - previous_t
        previous_t = current_t

        if !step_enabled
            lag += elapsed_t
            lagging = true
            while lagging
                if lag >= ns_per_update
                    Nodes.update(manager, frame_dt)
                    lag -= ns_per_update
                    ups_cnt += 1
                else 
                    lagging = false
                end
            end
        end
        
        # sleep(0.01666)

        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
        # Render
        # ~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--
        Nodes.pre_visit(manager)
        # **** Any rendering must occur AFTER this point ****

        # Capture time AFTER pre_visit. If vsync is enabled
        # then time includes the vertical refresh which ~16.667ms
        render_t = time_ns()

        interpolation = Float64(lag) / Float64(ns_per_update)

        more_scenes = Nodes.visit(manager, interpolation)

        if !more_scenes
            running = false
            continue
        end

        second_cnt += elapsed_t

        # ***************************
        # Debugging only
        # ***************************
        if display_on
            if display_coords
                draw_space_coords(mouse.x, mouse.y, world)
            end
            draw_stats(fps, ups, avg_render, world)
        end

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
        Nodes.post_visit(manager)
        
    end

    exit();
end

function push(scene::Ranger.AbstractScene)
    Nodes.push_node(manager, scene)
end

function exit()
    SDL2.Quit()
    println("Game exited");
end

# ***************************
# Debugging only
# ***************************
orange = Rendering.Orange()
white = Rendering.White()
green = Rendering.Lime()
view_point = Geometry.Point{Float64}()

function draw_stats(fps::Integer, ups::Integer, avg_render::Float64, world::Ranger.World)
    Rendering.set_draw_color(manager.context, white)
    text = @sprintf("(%2d)(%2d)(%2.4f)", fps, ups, avg_render)
    x = 10
    y = world.window_height - 24
    Rendering.draw_text(manager.context, x, y, text, 2, 2, false)
end

function draw_space_coords(mx::Int32, my::Int32, world::Ranger.World)
    Rendering.set_draw_color(manager.context, green)
    text = @sprintf("M: %2d, %2d", mx, my)
    x = 10
    y = 30
    Rendering.draw_text(manager.context, x, y, text, 2, 2, false)

    Nodes.map_device_to_view(manager.context, mx, my, view_point)
    text = @sprintf("V: %2d, %2d", view_point.x, view_point.y)
    y += 20
    Rendering.draw_text(manager.context, x, y, text, 2, 2, false)
end

end # Module -----------------------------------------------------------