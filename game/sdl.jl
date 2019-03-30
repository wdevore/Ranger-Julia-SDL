using SimpleDirectMediaLayer

import SimpleDirectMediaLayer:
    Window, Renderer

using .Game:
    World

const SDL2 = SimpleDirectMediaLayer 

mutable struct SDL
    win::Ptr{Window}
    renderer::Ptr{Renderer}

    function SDL(world::World, title="Ranger")
        SDL2.GL_SetAttribute(SDL2.GL_MULTISAMPLEBUFFERS, 16)
        SDL2.GL_SetAttribute(SDL2.GL_MULTISAMPLESAMPLES, 16)

        SDL2.Init(UInt32(SDL2.INIT_VIDEO))

        if world.window_centered
            win = SDL2.CreateWindow(
                title, Int32(SDL2.WINDOWPOS_CENTERED()), Int32(SDL2.WINDOWPOS_CENTERED()),
                Int32(world.window_width), Int32(world.window_height), 
                UInt32(SDL2.WINDOW_SHOWN))
        else
            win = SDL2.CreateWindow(
                title, Int32(world.window_position_x), Int32(world.window_position_y),
                Int32(world.window_width), Int32(world.window_height), 
                UInt32(SDL2.WINDOW_SHOWN))
        end

        SDL2.SetWindowResizable(win, false)

        renderer = SDL2.CreateRenderer(win, Int32(-1),
            UInt32(SDL2.RENDERER_ACCELERATED | SDL2.RENDERER_PRESENTVSYNC))

        new(win, renderer)
    end
end

# --------------------------------------------------------------------
# Event system
# --------------------------------------------------------------------
to_hex(num) = "0x" * string(num, base=16)

function bitcat(outType::Type{T}, bits) where {T <:Number}
    # Create a variable shaped like T, for example, zero(UInt32) = 0x00000000
    out = zero(outType)
    for bit in bits
        out = out << sizeof(bit)*8
        # the `convert` prevents signed T from promoting to Int64.
        out |= convert(T, bit)
    end
    out
end

function extract_4byte_host(start_index, arr::Array{UInt8})
    # First combine into a single 32 bit value
    word = UInt32(arr[start_index]) << 24 |
        UInt32(arr[start_index+1]) << 16 |
        UInt32(arr[start_index+2]) << 8 |
        arr[start_index+3]
    # Convert to host endian
    # Note: SDL has a note about endian: https://wiki.libsdl.org/CategoryEndian
    ntoh(word)
end

function extract_2byte_host(start_index, arr::Array{UInt8})
    # First combine into a single 32 bit value
    word = UInt16(arr[start_index]) << 8 |
        arr[start_index+1]
    # Convert to host endian
    # Note: SDL has a note about endian: https://wiki.libsdl.org/CategoryEndian
    ntoh(word)
end

# Grabs the first 4 bytes and places them into a UInt32
function get_event_type(event::Array{UInt8})
    extract_4byte_host(1, event)
end

function print_key_event_type(event::Array{UInt8})
    e32 = event[1]
    e24 = event[2]
    e16 = event[3]
    e08 = event[4]
    b32 = bitstring(e32)
    b24 = bitstring(e24)
    b16 = bitstring(e16)
    b08 = bitstring(e08)
    t = get_event_type(event)
    println("type: $b08 $b16 $b24 $b32 <= ", t, " = ", to_hex(t))
end

function print_key_event_state(event::Array{UInt8})
    # SDL_PRESSED or SDL_RELEASED
    e13 = event[13]
    println("state: ($e13) ", to_hex(e13))
end

function print_key_event_repeat(event::Array{UInt8})
    # non-zero if this is a key repeat
    e13 = event[14]
    println("repeat: ($e13) ", to_hex(e13))
end

function print_key_event_sym(event::Array{UInt8})
    scancode = extract_4byte_host(17, event)
    println("scancode: ($scancode) ", to_hex(scancode))
    keycode = extract_4byte_host(21, event)
    println("keycode: ($keycode) ", to_hex(keycode))
    mod = extract_2byte_host(25, event)
    println("mod: ($mod) ", to_hex(mod))
end

function poll_event!()
    #SDL2.Event() = [SDL2.Event(NTuple{56, Uint8}(zeros(56,1)))]
    SDL_Event() = Array{UInt8}(zeros(56))
    e = SDL_Event()
    success = (SDL2.PollEvent(e) != 0)
    e, success
end

function get_event_type(e::SDL2.Event)
    e._Event[1]
end

get_key_code_sym(event) = extract_4byte_host(21, event) #bitcat(UInt32, event[24:-1:21])

function handle_key_press(event)
    print_key_event_sym(event)
    keySym = get_key_code_sym(event)

    if (keySym == SDL2.SDLK_ESCAPE)
        println("!!!!!!!!!!! Escape")
    end
end

function handle_events!(event::Array{UInt8}, ev_type)
    # struct KeyboardEvent <: AbstractEvent
    #     _type::Uint32       1   4
    #     timestamp::Uint32   5   4 
    #     windowID::Uint32    9   4
    #     state::UInt8 13     13  1
    #     repeat::UInt8 14    14  1
    #     padding2::UInt8 15  15  1
    #     padding3::UInt8 16  16  1
    #     keysym::Keysym      17 
    # end
    # struct Keysym
    #     scancode::Scancode Sint32 17  4
    #     sym::Keycode Sint32       21  4
    #     mod::Uint16               25  2
    #     unused::Uint32            27
    # end
    if (ev_type == SDL2.KEYDOWN)# || ev_type == SDL2.KEYUP)
        println("*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--")
        println("event: ", event[1:31])
        println("f-type:     ", event[1:4])   # Ex: SDL2.KEYDOWN
        println("f-state:    ", event[13:13])
        println("f-repeat:   ", event[14:14])
        println("f-scancode: ", event[17:20]) # Ex: SDL2.SCANCODE_C
        println("f-keycode:  ", event[21:24]) # Ex: SDL2.SDLK_c
        println("f-mod:      ", event[25:25]) # Ex: SDL2.KMOD_LCTRL

        print_key_event_type(event)
        print_key_event_state(event)
        handle_key_press(event)
        println("--------------------------------------------------------------")
        false
    elseif (ev_type == SDL2.QUIT)
        println("Quit detected")
        true
    end
end
