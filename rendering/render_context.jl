using SimpleDirectMediaLayer
const SDL2 = SimpleDirectMediaLayer

import SimpleDirectMediaLayer:
    Renderer

export 
    RenderContext,
    save, restore, post, pre

using ..Ranger:
    World

using .Rendering:
    Palette, Gray

mutable struct RenderContext
    renderer::Ptr{Renderer}

    clear_color::Palette

    # Device/Window dimensions
    width::Int32
    height::Int32

    function RenderContext(world::World)
        o = new()
        o.renderer = world.renderer
        o.clear_color = Gray()
        o.width = world.window_width
        o.height = world.window_height
        o
    end
end

function pre(context::RenderContext)
    # c = context.clear_color
    # SDL2.SetRenderDrawColor(context.renderer, c.r64, c.g64, c.b64, c.a64)
    # SDL2.RenderClear(context.renderer);

    # Draw checkerboard as an clear indicator for debugging
    flip = false
    size = 200
    col = 0
    row = 0
    rect = SDL2.Rect(0, 0, 1, 1)

    while row < context.height 
        while col < context.width 
            if flip 
                SDL2.SetRenderDrawColor(context.renderer, 100, 100, 100, 255)
            else 
                SDL2.SetRenderDrawColor(context.renderer, 80, 80, 80, 255)
            end

            rect.x = col
            rect.y = row
            rect.w = col + size
            rect.h = row + size
            SDL2.RenderFillRect(context.renderer, pointer_from_objref(rect))

            flip = !flip;

            col += size;
        end
        flip = !flip;
        col = 0;
        row += size;
    end
end

function save(context::RenderContext)
end

function restore(context::RenderContext)
end

function post(context::RenderContext)
    SDL2.RenderPresent(context.renderer)
end