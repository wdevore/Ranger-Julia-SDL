using SimpleDirectMediaLayer
const SDL2 = SimpleDirectMediaLayer

import SimpleDirectMediaLayer:
    Renderer

export RenderContext
export save, restore, post, pre

using ..Ranger:
    World

mutable struct RenderContext
    renderer::Ptr{Renderer}

    function RenderContext(world::World)
        o = new()
        o.renderer = world.renderer

        o
    end
end

function pre(context::RenderContext)
    SDL2.SetRenderDrawColor(context.renderer, 200, 200, 200, 255)
    SDL2.RenderClear(context.renderer);
end

function save(context::RenderContext)
end

function restore(context::RenderContext)
end

function post(context::RenderContext)
    SDL2.RenderPresent(context.renderer)
end