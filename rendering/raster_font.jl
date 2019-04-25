# A simple Unicode raster 8x8 font
# The raw font data was ported from a Rust crate:
# https://crates.io/crates/font8x8/0.2.3

export
    show_character, show_string, get_glyph, get_glyph_width,
    load_font!

# The pixel data for this font is in assets/raster_font.data
mutable struct RasterFont
    pixels::Array{Array{UInt8},1}
    glyphs::Dict{Char,Int64}

    function RasterFont()
        new([], Dict{Char,Int64}())
    end
end

function load_font!(font::RasterFont, file::String)
    # The format of the file is formatted as follows:
    #
    #      This is the pixel data for the character
    #   |-------------------------------------|
    # ! 0x18 0x3C 0x3C 0x18 0x18 0x00 0x18 0x00
    # ^ 
    # |
    #  \- This is the character = "!"

    try
        idx = 1
        lines = readlines(file)
        for line in lines
            ele = split(line, " ")
            # Add character to glyph dictionary
            font.glyphs[ele[1][1]] = idx
            idx += 1
            # Add data to raw data array
            e2 = parse(UInt8, ele[2])
            e3 = parse(UInt8, ele[3])
            e4 = parse(UInt8, ele[4])
            e5 = parse(UInt8, ele[5])
            e6 = parse(UInt8, ele[6])
            e7 = parse(UInt8, ele[7])
            e8 = parse(UInt8, ele[8])
            e9 = parse(UInt8, ele[9])
            push!(font.pixels, [e2, e3, e4, e5, e6, e7, e8, e9])
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

function get_glyph(font::RasterFont, char::Char)
    glyph = font.glyphs[char]
    font.pixels[glyph]
end

function get_glyph_width()
    8
end

# Shows character at the console
# example:
# "a" =
#░░░░░░░░
#░░░░░░░░
#░████░░░
#░░░░██░░
#░█████░░
#██░░██░░
#░███░██░
#░░░░░░░░
# Helpful debugging functions
function show_character(char::Char)
    row = get_glyph(char)
    for c in row
        # println(bitstring(c))
        for shift in [0,1,2,3,4,5,6,7]
            bit = (c >> shift) & 1
            if bit == 0
                print("░")
            else
                print("█")
            end
        end
        println("")
    end
end

function show_string(text::String)
    for c in text
        show_character(c)
    end
end
