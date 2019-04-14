using SimpleDirectMediaLayer
const SDL2 = SimpleDirectMediaLayer

using SimpleDirectMediaLayer:
    Renderer

export 
    RenderContext,
    save!, restore!, post, pre, apply!,
    render_line, render_lines, render_aa_rectangle, render_outlined_polygon

using .Rendering
using ..Math
using ..Geometry

import ..Math.transform!

@enum RenderStyle FILLED OUTLINE BOTH
@enum PolygonState OPEN CLOSED

mutable struct RenderContext
    renderer::Ptr{Renderer}

    raster_font::RasterFont
    vector_font::VectorFont

    # State management
    state::Array{State}
    stack_top::Integer

    clear_color::Palette
    draw_color::Palette

    # Device/Window dimensions
    width::Int32
    height::Int32

    # The current transform based on top
    current::Math.AffineTransform

    post::Math.AffineTransform   # A preallocated cache
    
    # view space to device-space projection
    view_space::Math.AffineTransform
    inv_view_space::Math.AffineTransform

    # Scratch working variables
    v1::Geometry.Point{Float64}
    v2::Geometry.Point{Float64}

    function RenderContext(world::Ranger.World, raster_font::RasterFont, vector_font::Rendering.VectorFont)
        o = new()
        
        o.renderer = world.renderer
        o.raster_font = raster_font
        o.vector_font = vector_font
        o.state = []
        o.stack_top = 1
        o.clear_color = Orange()
        o.draw_color = White()
        o.width = world.window_width
        o.height = world.window_height
        
        o.current = AffineTransform{Float64}()
        o.post = AffineTransform{Float64}()
        o.view_space = AffineTransform{Float64}()
        o.inv_view_space = AffineTransform{Float64}()

        o.v1 = Geometry.Point{Float64}()
        o.v2 = Geometry.Point{Float64}()

        o
    end
end

# const SAMPLESIZE = 16

function initialize(context::RenderContext, world::Ranger.World)
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

function set_view_space(context::RenderContext, world::Ranger.World)
    # Apply view-space matrix
    center = Math.AffineTransform{Float64}()

    # What separates world from view is the ratio between the device (aka window)
    # and an optional centering translation.
    width_ratio = Float64(context.width) / world.view_width
    height_ratio = Float64(context.height) / world.view_height

    if world.view_centered 
        Math.make_translate!(center, Float64(context.width) / 2.0, Float64(context.height) / 2.0)
    end

    Math.scale!(center, width_ratio, height_ratio)
    context.view_space = center

    Math.invert!(context.view_space, context.inv_view_space)

    apply!(context, center);
    # println("View center: ", center)
end

function apply!(context::RenderContext, aft::AffineTransform) 
    # Concat this transform onto the current transform but don't push it.
    # Use post multiply
    Math.multiply!(aft, context.current, context.post)
    Math.set!(context.current, context.post)
end

function pre(context::RenderContext)
    c = context.clear_color
    SDL2.SetRenderDrawColor(context.renderer, c.r, c.g, c.b, c.a)
    SDL2.RenderClear(context.renderer);

    # Draw checkered board as an clear indicator for debugging
    # NOTE: disable this code for release builds
    # draw_checkerboard(context);
end

# Push the current state onto the stack
function save!(context::RenderContext)
    top = context.state[context.stack_top]

    top.clear_color = context.clear_color
    top.draw_color = context.draw_color
    Math.set!(top.current, context.current)

    context.stack_top += 1;

    # debugging
    # rect = SDL2.Rect(0, 0, 1, 1)
    # rect.x = 100
    # rect.y = 100
    # rect.w = 400
    # rect.h = 400

    # SDL2.SetRenderDrawColor(context.renderer, 255, 127, 0, 255)
    # draw_text(context, 100, 100, "Ranger", 3, 2, false)
    # draw_filled_rectangle(context, rect)
    # SDL2.SetRenderDrawColor(context.renderer, 255, 255, 255, 255)
    # draw_outlined_rectangle(context, rect)
end

# Pop the current state
function restore!(context::RenderContext)
    context.stack_top -= 1

    top = context.state[context.stack_top]

    context.clear_color = top.clear_color
    context.draw_color = top.draw_color
    Math.set!(context.current, top.current)

    c = context.clear_color
    SDL2.SetRenderDrawColor(context.renderer, c.r, c.g, c.b, c.a)
end

function post(context::RenderContext)
    SDL2.RenderPresent(context.renderer);
end

# Transform a Point
function transform!(context::RenderContext, p::Geometry.Point{Float64}, out::Geometry.Point{Float64})
    Math.transform!(context.current, p, out)
end

# Transform a line or rectangle corners
function transform!(context::RenderContext, p1::Geometry.Point{Float64}, p2::Geometry.Point{Float64}, out1::Geometry.Point{Float64}, out2::Geometry.Point{Float64})
    Math.transform!(context.current, p1, out1)
    Math.transform!(context.current, p2, out2)
end

function transform!(context::RenderContext, vertices::Array{Geometry.Point{Float64},1}, bucket::Array{Point{Float64},1})
    for (idx, vertex) in enumerate(vertices)
        Math.transform!(context.current, vertex, bucket[idx])
    end
end

function transform!(context::RenderContext, mesh::Geometry.Mesh)
    for (idx, vertex) in enumerate(mesh.vertices)
        Math.transform!(context.current, vertex, mesh.bucket[idx])
    end
end

function transform!(context::RenderContext, polygon::Math.Polygon)
    for (idx, vertex) in enumerate(polygon.mesh.vertices)
        Math.transform!(context.current, vertex, polygon.mesh.bucket[idx])
    end
end

# ,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.
# Draw functions render directly to the device.
# ,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.
function set_draw_color(context::RenderContext, color::Palette) 
    context.draw_color = color
    SDL2.SetRenderDrawColor(context.renderer, color.r, color.g, color.b, color.a)
end


function draw_point(context::RenderContext, x::Int32, y::Int32)
    SDL2.RenderDrawPoint(context.renderer, x, y);
end

function draw_line(context::RenderContext, x1::Float64, y1::Float64, x2::Float64, y2::Float64)
    SDL2.RenderDrawLine(context.renderer, Int32(round(x1)), Int32(round(y1)), Int32(round(x2)), Int32(round(y2)));
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

function draw_horz_line(context::RenderContext, x1::AbstractFloat, x2::AbstractFloat, y::AbstractFloat)
    SDL2.RenderDrawLine(context.renderer, Int32(round(x1)), Int32(round(y)), Int32(round(x2)), Int32(round(y)));
end

function draw_vert_line(context::RenderContext, x::Int32, y1::Int32, y2::Int32)
    SDL2.RenderDrawLine(context.renderer, x, y1, x, y2);
end

function draw_vert_line(context::RenderContext, x::AbstractFloat, y1::AbstractFloat, y2::AbstractFloat)
    SDL2.RenderDrawLine(context.renderer, Int32(round(x)), Int32(round(y1)), Int32(round(x)), Int32(round(y2)));
end

const shifts = [0,1,2,3,4,5,6,7]

# This type of font doesn't support transforms. It will always be axis aligned.
function draw_text(context::RenderContext, x::Integer, y::Integer, text::String, scale::Integer, fill::Integer, invert::Bool)
    cx = Int32(x)
    s = Int32(scale)
    row_width = Int32(get_glyph_width())

    # Is the text colored or the space around it (aka inverted)
    bit_invert = invert ? 0 : 1

    for char in text
        if char == ' '
            cx += row_width * s # move to next column/char/glyph
            continue
        end

        gy = Int32(y) # move y back to the "top" for each char
        glyph = get_glyph(context.raster_font, char)
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

function draw_checkerboard(context::RenderContext)
    flip = false
    size = 200
    col = 0
    row = 0

    while row < context.height
        while col < context.width
            if flip
                SDL2.SetRenderDrawColor(context.renderer, 100, 100, 100, 255)
            else 
                SDL2.SetRenderDrawColor(context.renderer, 80, 80, 80, 255)
            end

            rect_draw.x = col
            rect_draw.y = row
            rect_draw.w = col + size
            rect_draw.h = row + size
            
            SDL2.RenderFillRect(context.renderer, pointer_from_objref(rect_draw))

            flip = !flip;
            col += size;
        end

        flip = !flip;
        col = 0;
        row += size;
    end
end

# ,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.,--.
# Render functions render based on transformed vertices
# The Render functions use the Draw functions.
# ,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.,__.
function render_line(context::RenderContext, x1::Float64, y1::Float64, x2::Float64, y2::Float64)
    draw_line(context, Int32(round(x1)), Int32(round(y1)), Int32(round(x2)), Int32(round(y2)));
end

function render_lines(context::RenderContext, mesh::Geometry.Mesh)
    first = true
        
    for v in mesh.bucket
        if first
            context.v1 = v
            first = false
            continue
        else
            context.v2 = v
            first = true
        end

        draw_line(context, 
            context.v1.x, context.v1.y,
            context.v2.x, context.v2.y);
    end
end

function render_checkerboard(context::RenderContext, mesh::Geometry.Mesh, oddColor::Palette, evenColor::Palette)
    # render a grid of rectangles defined by min/max points
    flip = false
    vertices = mesh.bucket
    build = true
        
    # TODO detect negative change in X so that the flip value
    # alternates correctly for even grid sizes. To lazy to fix at the moment.
    for (idx, vertex) in enumerate(mesh.bucket)
        if build
            Geometry.set!(context.v1, vertex)
            build = false
            continue
        else
            Geometry.set!(context.v2, vertex)
            build = true
        end

        if flip 
            SDL2.SetRenderDrawColor(context.renderer, oddColor.r, oddColor.g, oddColor.b, oddColor.a)
        else 
            SDL2.SetRenderDrawColor(context.renderer, evenColor.r, evenColor.g, evenColor.b, evenColor.a)
        end
        
        # upper-left
        minx = Int32(round(context.v1.x))
        miny = Int32(round(context.v1.y))

        # bottom-right
        maxx = Int32(round(context.v2.x))
        maxy = Int32(round(context.v2.y))

        rect_draw.x = minx
        rect_draw.y = miny
        rect_draw.w = maxx - minx
        rect_draw.h = maxy - miny
        
        SDL2.RenderFillRect(context.renderer, pointer_from_objref(rect_draw))

        flip = !flip;
    end
end

# Render an axis aligned rectangle. Rotating any of the vertices
# will cause strange rendering behaviours
function render_aa_rectangle(context::RenderContext, min::Geometry.Point{Float64}, max::Geometry.Point{Float64}, fillStyle::RenderStyle)
    # upper-left
    minx = Int32(round(min.x))
    miny = Int32(round(min.y))

    # bottom-right
    maxx = Int32(round(max.x))
    maxy = Int32(round(max.y))

    if fillStyle == FILLED
        draw_filled_rectangle(context, minx, miny, maxx, maxy)
    elseif fillStyle == OUTLINE
        draw_outlined_rectangle(context, minx, miny, maxx, maxy)
    else
        draw_filled_rectangle(context, minx, miny, maxx, maxy)
        draw_outlined_rectangle(context, minx, miny, maxx, maxy)
    end
end

function render_aabb_rectangle(context::RenderContext, aabb::Geometry.AABB)
    # upper-left
    minx = Int32(round(aabb.min.x))
    miny = Int32(round(aabb.min.y))

    # bottom-right
    maxx = Int32(round(aabb.max.x))
    maxy = Int32(round(aabb.max.y))

    draw_outlined_rectangle(context, minx, miny, maxx, maxy)
end

function render_outlined_polygon(context::RenderContext, polygon::Geometry.Polygon, state::PolygonState)
    bucs = polygon.mesh.bucket

    for idx in 1:(length(bucs) - 1)
        SDL2.RenderDrawLine(context.renderer,
            Int32(round(bucs[idx].x)), Int32(round(bucs[idx].y)),
            Int32(round(bucs[idx + 1].x)), Int32(round(bucs[idx + 1].y)))
    end

    if state == CLOSED
        SDL2.RenderDrawLine(context.renderer,
            Int32(round(bucs[length(bucs)].x)), Int32(round(bucs[length(bucs)].y)),
            Int32(round(bucs[1].x)), Int32(round(bucs[1].y)))
    end
end