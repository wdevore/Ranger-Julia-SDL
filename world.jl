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
    
    # Device properties
    window_position_x::UInt32
    window_position_y::UInt32
    window_width::UInt32
    window_height::UInt32

    window_centered::Bool

    view_width::Float64
    view_height::Float64
    view_centered::Bool

    # view space to device-space projection
    view_space::Math.AffineTransform
    inv_view_space::Math.AffineTransform
    
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
        o.window_centered = true
        o.view_centered = true
        o.view_width = Float64(o.window_width) * VIEW_SCALE
        o.view_height = Float64(o.window_height) * VIEW_SCALE
        o.ids = 0
        o.window = o    # Not assigned yet
        o.renderer = o  # Not assigned yet

        o.view_space = Math.AffineTransform{Float64}()
        o.inv_view_space = Math.AffineTransform{Float64}()

        set_view_space!(o)
        
        println("Display dimensions: [", o.window_width, " x ", o.window_height, "]")
        println("View dimensions: [", o.view_width, " x ", o.view_height, "]")

        o
    end
end

function gen_id(world::World)
    world.ids += 1
    world.ids
end

function set_view_space!(world::Ranger.World)
    center = Math.AffineTransform{Float64}()

    # What separates world from view is the ratio between the device (aka window)
    # and an optional centering translation.
    width_ratio = Float64(world.window_width) / world.view_width
    height_ratio = Float64(world.window_height) / world.view_height

    if world.view_centered 
        Math.make_translate!(center, Float64(world.window_width) / 2.0, Float64(world.window_height) / 2.0)
    end

    Math.scale!(center, width_ratio, height_ratio)
    Math.set!(world.view_space, center)

    Math.invert!(world.view_space, world.inv_view_space)
end
