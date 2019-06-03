export Events

module Events

using SimpleDirectMediaLayer
const SDL2 = SimpleDirectMediaLayer

export
    KeyboardEvent, MouseMotionEvent, MouseWheelEvent, MouseButtonEvent,
    get_key_code_sym, get_scancode, get_modifier, get_repeat,
    poll_event!, get_event_type, set!, print

using ..Ranger

import Base.print

# --------------------------------------------------------------------
# Event utilities
# --------------------------------------------------------------------
# returns a UInt32 in host-endian
function extract_4byte_host(start_index, arr::Array{UInt8})
    # First combine into a single 32 bit value
    word = UInt32(arr[start_index]) << 24 |
        UInt32(arr[start_index + 1]) << 16 |
        UInt32(arr[start_index + 2]) << 8 |
        arr[start_index + 3]
    # Convert to host-endian
    # Note: SDL has a note about endianess: https://wiki.libsdl.org/CategoryEndian
    ntoh(word)
end

function extract_2byte_host(start_index, arr::Array{UInt8})
    # First combine into a single 16 bit value
    word = UInt16(arr[start_index]) << 8 |
        arr[start_index + 1]
    ntoh(word)
end

# Grabs the first 4 bytes and places them into a UInt32 in host-ordering
function get_event_type(event::Array{UInt8})
    extract_4byte_host(1, event) # return UInt32
end

function get_event_type(e::SDL2.Event)
    e._Event[1] # UInt8
end

get_key_code_sym(event::Array{UInt8}) = extract_4byte_host(21, event)
get_scancode(event::Array{UInt8}) = extract_4byte_host(17, event)
get_modifier(event::Array{UInt8}) = extract_2byte_host(25, event)
get_state(event::Array{UInt8}) = event[13]
get_repeat(event::Array{UInt8}) = event[14]

SDL_Event() = Array{UInt8}(zeros(56))
event = SDL_Event()

function poll_event!()
    success = (SDL2.PollEvent(event) ≠ 0)
    event, success
end

# --------------------------------------------------------------
# Key maps
# --------------------------------------------------------------
const KEY_A = SDL2.SDLK_a
const KEY_E = SDL2.SDLK_e
const KEY_F = SDL2.SDLK_f
const KEY_S = SDL2.SDLK_s
const KEY_W = SDL2.SDLK_w
const KEY_UP = SDL2.SDLK_UP
const KEY_DOWN = SDL2.SDLK_DOWN
const KEY_LEFT = SDL2.SDLK_LEFT
const KEY_RIGHT = SDL2.SDLK_RIGHT
const KEY_PRESSED = 1
const KEY_RELEASED = 0
const KEY_REPEATING = 1

# --------------------------------------------------------------
# Debugging printing and misc.
# --------------------------------------------------------------
to_hex(num) = "0x" * string(num, base = 16)

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
    println("type: $b08 $b16 $b24 $b32 <= ", t, " = ", to_hex(t));
end

function print_key_event_state(event::Array{UInt8})
    # SDL_PRESSED or SDL_RELEASED
    e13 = event[13]
    println("state: ($e13) ", to_hex(e13));
end

function print_key_event_repeat(event::Array{UInt8})
    # non-zero if this is a key repeat
    e13 = event[14]
    println("repeat: ($e13) ", to_hex(e13));
end

function print_key_event_sym(event::Array{UInt8})
    scancode = get_scancode(event)
    println("scancode: ($scancode) ", to_hex(scancode))
    keycode = get_key_code_sym(event)
    println("keycode: ($keycode) ", to_hex(keycode))
    mod = get_modifier(event)
    println("mod: ($mod) ", to_hex(mod));
end

# --------------------------------------------------------------
# Keyboard
# --------------------------------------------------------------
function print_keyboard_event(event::Array{UInt8})
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
    print_key_event_repeat(event)
    print_key_event_sym(event)
    println("--------------------------------------------------------------")
end

mutable struct KeyboardEvent <: Ranger.AbstractIOEvent
    keycode::UInt32
    scancode::UInt32
    modifier::UInt16
    repeat::UInt8
    state::UInt8

    function KeyboardEvent()
        new(0, 0, 0, 0)
    end
end

function set!(keyboard::KeyboardEvent, event::Array{UInt8,1})
    keyboard.keycode = get_key_code_sym(event)
    keyboard.scancode = get_scancode(event)
    keyboard.modifier = get_modifier(event)
    keyboard.repeat = get_repeat(event)
    keyboard.state = get_state(event)
end

function print(keyboard::KeyboardEvent)
    println("key: ", keyboard.keycode,
    ", scan: ", keyboard.scancode,
    ", mod: ", keyboard.modifier,
    ", rep: ", keyboard.repeat,
    ", state: ", keyboard.state)
end

# --------------------------------------------------------------
# Mouse
# --------------------------------------------------------------
function print_mouse_event(event::Array{UInt8})
    # mutable struct MouseMotionEvent <: AbstractEvent
    #     _type::Uint32        1:4
    #     timestamp::Uint32    5:8
    #     windowID::Uint32     9:12
    #     which::Uint32        13:16 
    #     state::Uint32
    #     x::Sint32
    #     y::Sint32
    #     xrel::Sint32
    #     yrel::Sint32
    # end
    println("*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--")
    println("event: ", event[1:36])

    type = extract_4byte_host(1, event)
    which = extract_4byte_host(13, event)
    state = extract_4byte_host(17, event)
    x = extract_4byte_host(21, event)
    y = extract_4byte_host(25, event)
    xrel = extract_4byte_host(29, event)
    yrel = extract_4byte_host(33, event)

    println("m-type:     ", event[1:4], " <= ", type)   # Ex: SDL2.MOUSEMOTION
    println("m-which:    ", event[13:16], " <= ", which)
    println("m-state:    ", event[17:20], " <= ", state)
    println("m-x:        ", event[21:24], " <= ", signed(x))
    println("m-y:        ", event[25:28], " <= ", signed(y))
    println("m-xrel:     ", event[29:32], " <= ", signed(xrel))
    println("m-yrel:     ", event[33:36], " <= ", signed(yrel))

    println("--------------------------------------------------------------")
end

mutable struct MouseMotionEvent <: Ranger.AbstractIOEvent
    type::UInt32
    which::UInt32
    state::UInt32
    x::Int32
    y::Int32
    xrel::Int32
    yrel::Int32

    function MouseMotionEvent()
        new(0, 0, 0, 0, 0, 0)
    end
end

function set!(mouse::MouseMotionEvent, event::Array{UInt8,1})
    mouse.type = extract_4byte_host(1, event)
    mouse.which = extract_4byte_host(13, event)
    mouse.state = extract_4byte_host(17, event)
    mouse.x = signed(extract_4byte_host(21, event))
    mouse.y = signed(extract_4byte_host(25, event))
    mouse.xrel = signed(extract_4byte_host(29, event))
    mouse.yrel = signed(extract_4byte_host(33, event))
end

mutable struct MouseWheelEvent <: Ranger.AbstractIOEvent
    type::UInt32
    which::UInt32
    x::Int32
    y::Int32
    direction::UInt32

    function MouseWheelEvent()
        new(0, 0, 0, 0, 0)
    end
end

function set!(mouse::MouseWheelEvent, event::Array{UInt8,1})
    mouse.type = extract_4byte_host(1, event)
    mouse.which = extract_4byte_host(13, event)
    mouse.x = signed(extract_4byte_host(17, event))
    mouse.y = signed(extract_4byte_host(21, event))
    mouse.direction = signed(extract_4byte_host(25, event))
end

mutable struct MouseButtonEvent <: Ranger.AbstractIOEvent
    type::UInt32
    which::UInt32
    button::UInt8
    state::UInt8
    clicks::UInt8
    # padding1 UInt8
    x::Int32
    y::Int32

    function MouseButtonEvent()
        new(0, 0, 0, 0, 0, 0, 0)
    end
end

function set!(mouse::MouseButtonEvent, event::Array{UInt8,1})
    mouse.type = extract_4byte_host(1, event)
    mouse.which = extract_4byte_host(13, event)
    mouse.button = event[17]

    mouse.state = event[18]
    mouse.clicks = event[19]
    # padding at 20
    mouse.x = signed(extract_4byte_host(21, event))
    mouse.y = signed(extract_4byte_host(25, event))
end

function is_left_mouse_down(mouse::MouseButtonEvent)
    mouse.button == 1 && mouse.state == 1
end

function is_left_mouse_up(mouse::MouseButtonEvent)
    mouse.button == 1 && mouse.state == 0
end

end # Module ------------------------------------------------------------