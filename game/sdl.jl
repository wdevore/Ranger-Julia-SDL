using SimpleDirectMediaLayer

# import SimpleDirectMediaLayer:
#     Window, Renderer

using ..Ranger:
    World

const SDL2 = SimpleDirectMediaLayer

const SAMPLESIZE = 16

mutable struct SDL

    function SDL(world::World)
        SDL2.GL_SetAttribute(SDL2.GL_MULTISAMPLEBUFFERS, SAMPLESIZE)
        SDL2.GL_SetAttribute(SDL2.GL_MULTISAMPLESAMPLES, SAMPLESIZE)

        SDL2.Init(UInt32(SDL2.INIT_VIDEO))

        if world.window_centered
            world.window = SDL2.CreateWindow(
                world.title, Int32(SDL2.WINDOWPOS_CENTERED()), Int32(SDL2.WINDOWPOS_CENTERED()),
                Int32(world.window_width), Int32(world.window_height),
                UInt32(SDL2.WINDOW_SHOWN))
        else
            world.window = SDL2.CreateWindow(
                world.title, Int32(world.window_position_x), Int32(world.window_position_y),
                Int32(world.window_width), Int32(world.window_height),
                UInt32(SDL2.WINDOW_SHOWN))
        end

        SDL2.SetWindowResizable(world.window, false)

        world.renderer = SDL2.CreateRenderer(world.window, Int32(-1),
            UInt32(SDL2.RENDERER_ACCELERATED | SDL2.RENDERER_PRESENTVSYNC))

        # new(win, renderer)
        new()
    end
end
