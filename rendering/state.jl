using ..Math:
    AffineTransform

import ..Math:
    copy

const STATE_STACK_DEPTH = 100

# Stack state
mutable struct State 
    clear_color::Palette
    draw_color::Palette
    current::AffineTransform

    function State()
        new(Gray(),
            Gray(),
            AffineTransform{Float64}())
    end

    function State(clear::Palette, draw::Palette, curr::AffineTransform)
        new(clear,
            draw,
            copy(curr))
    end
end

# copy specializations
copy(s::State) = State(s.clear_color, s.draw_color, s.current)
