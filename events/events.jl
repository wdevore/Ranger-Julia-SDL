export Events

module Events

export
    KeyboardEvent, MouseEvent

using ..Ranger:
    AbstractIOEvent

mutable struct KeyboardEvent <: AbstractIOEvent
    keycode::UInt32
    scancode::UInt32
    modifier::UInt16
    repeat::UInt8

    function KeyboardEvent()
        new(0, 0, 0, 0)
    end
end

struct MouseEvent <: AbstractIOEvent end

end