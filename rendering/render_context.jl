using SimpleDirectMediaLayer
const SDL2 = SimpleDirectMediaLayer

using SimpleDirectMediaLayer:
    Renderer

export 
    RenderContext,
    save, restore, post, pre

using ..Ranger:
    World

using .Rendering:
    Palette, Gray, get_glyph, get_glyph_width

using ..Math:
    AffineTransform, make_translate!, scale!, multiply!

mutable struct RenderContext
    renderer::Ptr{Renderer}

    # State management
    state::Array{State}
    stack_top::Integer

    clear_color::Palette
    draw_color::Palette

    # Device/Window dimensions
    width::Int32
    height::Int32

    # The current transform based on top
    current::AffineTransform

    post::AffineTransform   # A preallocated cache
    
    # view space to device-space projection
    view_space::AffineTransform

    function RenderContext(world::World)
        o = new()
        o.renderer = world.renderer
        o.state = []
        o.stack_top = 1
        o.clear_color = Gray()
        o.draw_color = Orange()
        o.width = world.window_width
        o.height = world.window_height
        o.current = AffineTransform{Float64}()
        o.post = AffineTransform{Float64}()
        o.view_space = AffineTransform{Float64}()
        o
    end
end

# const SAMPLESIZE = 16

function initialize(context::RenderContext, world::World)
    # SDL2.GL_SetAttribute(SDL2.GL_MULTISAMPLEBUFFERS, SAMPLESIZE)
    # SDL2.GL_SetAttribute(SDL2.GL_MULTISAMPLESAMPLES, SAMPLESIZE)
    # SDL2.SetHint(SDL2.HINT_RENDER_SCALE_QUALITY, "1")

    SDL2.SetRenderDrawBlendMode(context.renderer, SDL2.BLENDMODE_BLEND);
    
    state = State()

    for _ in 0:STATE_STACK_DEPTH
        push!(context.state, copy(state))
    end

    set_view_space(context, world)
end

function set_view_space(context::RenderContext, world::World)
    # Apply view-space matrix
    center = AffineTransform{Float64}()

    # What separates world from view is the ratio between the device (aka window)
    # and an optional centering translation.
    width_ratio = Float64(context.width) / world.view_width
    height_ratio = Float64(context.height) / world.view_height

    if world.view_centered 
        make_translate!(center, Float64(context.width) / 2.0, Float64(context.height) / 2.0)
    end

    scale!(center, width_ratio, height_ratio)
    context.view_space = center

    apply(context, center);
end

function apply(context::RenderContext, aft::AffineTransform) 
    # Concat this transform onto the current transform but don't push it.
    # Use post multiply
    multiply!(aft, context.current, context.post)
    context.current = context.post;
end

function pre(context::RenderContext)
    # c = context.clear_color
    # SDL2.SetRenderDrawColor(context.renderer, c.r, c.g, c.b, c.a)
    # SDL2.RenderClear(context.renderer);

    # Draw checkered board as an clear indicator for debugging
    # NOTE: disable this code for release builds
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

    nothing
end

# Push the current state onto the stack
function save(context::RenderContext)
    top = context.state[context.stack_top]

    top.clear_color = context.clear_color
    top.draw_color = context.draw_color
    top.current = context.current

    context.stack_top += 1;

    # debugging
    rect = SDL2.Rect(0, 0, 1, 1)
    rect.x = 100
    rect.y = 100
    rect.w = 400
    rect.h = 400

    SDL2.SetRenderDrawColor(context.renderer, 255, 127, 0, 255)
    draw_text(context, 100, 100, "Ranger", 3, 2, false)
    # draw_filled_rectangle(context, rect)
    # SDL2.SetRenderDrawColor(context.renderer, 255, 255, 255, 255)
    # draw_outlined_rectangle(context, rect)
end

# Pop the current state
function restore(context::RenderContext)
    context.stack_top -= 1

    top = context.state[context.stack_top]

    context.clear_color = top.clear_color
    context.draw_color = top.draw_color
    context.current = top.current

    c = context.clear_color
    SDL2.SetRenderDrawColor(context.renderer, c.r, c.g, c.b, c.a)
end

function post(context::RenderContext)
    SDL2.RenderPresent(context.renderer);
end

# ,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.
# Draw functions render directly to the device.
# The Render functions use the Draw functions.
# ,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.

function draw_point(context::RenderContext, x::Int32, y::Int32)
    SDL2.RenderDrawPoint(context.renderer, x, y);
end

function draw_line(context::RenderContext, x1::Int32, y1::Int32, x2::Int32, y2::Int32)
    SDL2.RenderDrawLine(context.renderer, x1, y1, x2, y2);
end

function draw_outlined_rectangle(context::RenderContext, rect::SDL2.Rect)
    SDL2.RenderDrawRect(context.renderer, pointer_from_objref(rect));
end

function draw_filled_rectangle(context::RenderContext, rect::SDL2.Rect)
    SDL2.RenderFillRect(context.renderer, pointer_from_objref(rect));
end

rect_draw = SDL2.Rect(0, 0, 1, 1)

function draw_outlined_rectangle(context::RenderContext, minx::Int32, miny::Int32, maxx::Int32, maxy::Int32)
    rect_draw.x = minx
    rect_draw.y = miny
    rect_draw.w = maxx - minx
    rect_draw.h = maxy - miny
    SDL2.RenderDrawRect(context.renderer, pointer_from_objref(rect_draw));
end

function draw_filled_rectangle(context::RenderContext, minx::Int32, miny::Int32, maxx::Int32, maxy::Int32)
    rect_draw.x = minx
    rect_draw.y = miny
    rect_draw.w = maxx - minx
    rect_draw.h = maxy - miny
    SDL2.RenderFillRect(context.renderer, pointer_from_objref(rect_draw));
end

function draw_horz_line(context::RenderContext, x1::Int32, x2::Int32, y::Int32)
    SDL2.RenderDrawLine(context.renderer, x1, y, x2, y);
end

function draw_vert_line(context::RenderContext, x::Int32, y1::Int32, y2::Int32)
    SDL2.RenderDrawLine(context.renderer, x, y1, x, y2);
end

# This type of font doesn't support transforms. It will always be axis aligned.
function draw_text(context::RenderContext, x::Integer, y::Integer, text::String, scale::Integer, fill::Integer, invert::Bool)
    shifts = [0,1,2,3,4,5,6,7]
    cx = Int32(x)
    s = Int32(scale)
    row_width = Int32(get_glyph_width())

    # Is the text colored or the space around it (aka inverted)
    bit_invert = invert ? 0 : 1

    for char in text
        gy = Int32(y) # move y back to the "top" for each char
        glyph = get_glyph(char)
        for g in glyph
            gx = cx # set to current column
            for shift in shifts # scan each pixel in the glyph
                bit = (g >> shift) & 1

                if bit == bit_invert
                    if scale == 1
                        SDL2.RenderDrawPoint(context.renderer, gx, gy)
                    else
                        fillet = fill
                        if fill > scale 
                            fillet = 0
                        end
                        for xl in 0:(scale - fillet)
                            for yl in 0:(scale - fillet)
                                SDL2.RenderDrawPoint(context.renderer, Int32(gx + xl), Int32(gy + yl));
                            end
                        end
                    end
                end
                
                gx += s
            end
            gy += s # move to next pixel-row in char
        end
        cx += row_width * s # move to next column/char/glyph
    end

end