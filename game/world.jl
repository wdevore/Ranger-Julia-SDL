export World

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
    window_centered::Bool

    view_width::Float64
    view_height::Float64

    function World(title::String)
        window_width = WIDTH
        window_height = UInt32(Float64(WIDTH) / DISPLAY_RATIO)
    
        view_width = Float64(window_width) * VIEW_SCALE
        view_height = Float64(window_height) * VIEW_SCALE

        println("Display dimensions: [$window_width x $window_height]" )
        println("View dimensions: [$view_width x $view_height]")

        new(title,
            WINDOW_POSITION[1], WINDOW_POSITION[2],
            window_width, window_height,
            false,
            view_width, view_height)
    end
end

