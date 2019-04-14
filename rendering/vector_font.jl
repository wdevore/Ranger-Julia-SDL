using ..Geometry

import .Rendering.load_font!

export
    VectorFont,
    load_font!, get_glyph

mutable struct VectorGlyph
    vectors::Array{Geometry.Point{Float64},1}

    function VectorGlyph()
        new([])
    end
end

function add_vector!(glyph::VectorGlyph, x1::Float64, y1::Float64, x2::Float64, y2::Float64)
    push!(glyph.vectors, Point{Float64}(x1, y1))
    push!(glyph.vectors, Point{Float64}(x2, y2))
end

mutable struct VectorFont
    vectors::Array{VectorGlyph,1}
    glyphs::Dict{Char,Int64}

    horizontal_offset::Float64
    vertical_offset::Float64
    scale::Float64

    function VectorFont()
        new([],
        Dict{Char,Int64}(),
        1.2,
        1.2,
        3.0)
    end
end

function load_font!(font::VectorFont, file::String)
    try
        idx = 1
        lines = readlines(file)
        vectors = VectorGlyph()

        for line in lines
            if length(line) == 1
                # println("[", line, "]", idx)
                # Add character to glyph dictionary
                font.glyphs[line[1]] = idx
                idx += 1
                vectors = VectorGlyph()
                continue
            end

            if line == "||"
                push!(font.vectors, vectors)
                continue
            end

            # readlines until end of pixel marker: "||" 
            if line ≠ "||"
                ele = split(line, " ")
                # println("ele: ", ele)
                # Add data to pixel array
                v1 = parse(Float64, ele[1])
                v2 = parse(Float64, ele[2])
                v3 = parse(Float64, ele[3])
                v4 = parse(Float64, ele[4])
                add_vector!(vectors, v1, v2, v3, v4)
            end
        end
    catch ex
        println("******************************************************")
        println(ex)
        println("Exception loading: ", file)
        println("******************************************************")
        return false
    end

    true

end

function get_glyph(font::VectorFont, char::Char) # returns a VectorGlyph
    glyph = font.glyphs[char]
    font.vectors[glyph]
end