export Events

module Events

using SimpleDirectMediaLayer
const SDL2 = SimpleDirectMediaLayer

export
    KeyboardEvent, MouseEvent,
    get_key_code_sym, get_scancode, get_modifier, get_repeat,
    poll_event!, get_event_type

using ..Ranger

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
get_repeat(event::Array{UInt8}) = event[13]

SDL_Event() = Array{UInt8}(zeros(56))
event = SDL_Event()

function poll_event!()
    success = (SDL2.PollEvent(event) ≠ 0)
    event, success
end

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

function print_event(event::Array{UInt8})
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

    function KeyboardEvent()
        new(0, 0, 0, 0)
    end
end

struct MouseEvent <: Ranger.AbstractIOEvent end

end