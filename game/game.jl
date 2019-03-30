module Game

include("world.jl")
include("sdl.jl")

export initialize, run

sdl = nothing

function initialize(title::String, build::Function)
    world = World(title)

    sdl = SDL(world, title)

    build(world)

    world
end

function run(world::World)
    println("running...")
    cnt = 0

    running = true

    while running && cnt < 100
        # Handle Events
        haveEvents = true
        
        while haveEvents
            event, haveEvents = poll_event!()
            ev_type = get_event_type(event)

            if (ev_type == SDL2.KEYDOWN)
                keySym = get_key_code_sym(event)

                if (keySym == SDL2.SDLK_ESCAPE)
                    running = false
                end
            end
            
            handle_events!(event, ev_type)
        end        
        # println("Sleep")
        # sleep(0.1)
    end
end

function run2(world::World)
    println("running...")
    cnt = 0

    running = true

    while running && cnt < 100
        event = SDL2.Event(ntuple(i->UInt8(0),56))
        println("-----------------------------")
        SDL2.PollEvent(pointer_from_objref(event))
        println(event)
        
        # if state == SDL2.QUIT
        #     running = false
        # end
        t = UInt32(0)
        for x in event._Event[4:-1:1]
            println("x: ", bitstring(x))
            t = t << (sizeof(x)*8)
            println("t: ", bitstring(t))
            t |= x
        end

        evtype = SDL2.Event(t)
        evtype == nothing && return nothing

        evtype == SDL2.KeyboardEvent && info(event)

        unsafe_load( Ptr{evtype}(pointer_from_objref(event)) )

        sleep(0.5)
    end

    sleep(1.0)
end

function exit()
    SDL2.Quit()
    println("Game exited")
end

end