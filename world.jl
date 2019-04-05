using SimpleDirectMediaLayer

# import SimpleDirectMediaLayer:
#     Window, Renderer

export World
export gen_id

const DISPLAY_RATIO = 16.0 / 9.0
const WIDTH = 1024 + 512
# Larget number causes the view to encompass more of the world
# which makes objects appear smaller.
const VIEW_SCALE = 1.5

const WINDOW_POSITION = (1000, 100)

mutable struct World
    title::String
    window_position_x::UInt32
    window_position_y::UInt32
    window_width::UInt32
    window_height::UInt32

    view_width::Float64
    view_height::Float64
    view_centered::Bool

    ids::UInt32

    window #::Ptr{Window}
    renderer #::Ptr{Renderer}

    function World(title::String)
        o = new()
        o.title = title
        o.window_position_x = WINDOW_POSITION[1]
        o.window_position_y = WINDOW_POSITION[2]
        o.window_width = WIDTH
        o.window_height = UInt32(Float64(WIDTH) / DISPLAY_RATIO)
        o.view_centered = true
        o.view_width = Float64(o.window_width) * VIEW_SCALE
        o.view_height = Float64(o.window_height) * VIEW_SCALE
        o.ids = 0
        o.window = o    # Not assigned yet
        o.renderer = o  # Not assigned yet

        println("Display dimensions: [", o.window_width, " x ", o.window_height, "]")
        println("View dimensions: [", o.view_width, " x ", o.view_height, "]")

        o
    end
end

function gen_id(world::World)
    world.ids += 1
    world.ids
end