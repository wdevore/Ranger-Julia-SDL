using ..Geometry

export
    VectorFont,
    build_font!, get_glyph

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
    glyphs::Array{VectorGlyph,1}

    horizontal_offset::Float64
    vertical_offset::Float64
    scale::Float64

    function VectorFont()
        new([],
            1.2,
            1.2,
            3.0)
    end
end

function build_font!(font::VectorFont)
    # A
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, 0.0, 0.0, -1.0)
    add_vector!(glyph, 0.5, 0.0, 0.0, -1.0)
    add_vector!(glyph, -0.3, -0.4, 0.3, -0.4)
    push!(font.glyphs, glyph)

    # B
    glyph = VectorGlyph()
    add_vector!(glyph, 0.25, 0.0, -0.5, 0.0)
    add_vector!(glyph, -0.5, 0.0, -0.5, -1.0)
    add_vector!(glyph, -0.5, -1.0, 0.25, -1.0)
    add_vector!(glyph, 0.25, -1.0, 0.5, -0.85)
    add_vector!(glyph, 0.5, -0.85, 0.5, -0.65)
    add_vector!(glyph, 0.5, -0.65, 0.5, -0.55)
    add_vector!(glyph, 0.50, -0.55, 0.25, -0.5)
    add_vector!(glyph, 0.25, -0.50, 0.5, -0.45)
    add_vector!(glyph, 0.5, -0.45, 0.5, -0.35)
    add_vector!(glyph, 0.5, -0.35, 0.25, -0.0)
    add_vector!(glyph, -0.5, -0.5, 0.25, -0.5)
    push!(font.glyphs, glyph)

    # C
    glyph = VectorGlyph()
    add_vector!(glyph, 0.5, -0.25, 0.25, 0.0)
    add_vector!(glyph, 0.25, 0.0, -0.45, 0.0)
    add_vector!(glyph, -0.45, 0.0, -0.5, -0.25)
    add_vector!(glyph, -0.5, -0.25, -0.5, -0.75)
    add_vector!(glyph, -0.5, -0.75, -0.45, -1.0)
    add_vector!(glyph, -0.45, -1.0, 0.25, -1.0)
    add_vector!(glyph, 0.25, -1.0, 0.5, -0.75)
    push!(font.glyphs, glyph)

    # D
    glyph = VectorGlyph()
    add_vector!(glyph, 0.5, -0.25, 0.25, 0.0)
    add_vector!(glyph, 0.25, 0.0, -0.5, 0.0)
    add_vector!(glyph, -0.5, 0.0, -0.5, -1.0)
    add_vector!(glyph, -0.5, -1.0, 0.25, -1.0)
    add_vector!(glyph, 0.25, -1.0, 0.5, -0.75)
    add_vector!(glyph, 0.5, -0.75, 0.5, -0.25)
    push!(font.glyphs, glyph)

    # E
    glyph = VectorGlyph()
    add_vector!(glyph, 0.5, 0.0, -0.5, 0.0)
    add_vector!(glyph, -0.5, 0.0, -0.5, -1.0)
    add_vector!(glyph, -0.5, -1.0, 0.5, -1.0)
    add_vector!(glyph, -0.5, -0.5, 0.40, -0.5)
    push!(font.glyphs, glyph)

    # F
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, 0.0, -0.5, -1.0)
    add_vector!(glyph, -0.5, -1.0, 0.5, -1.0)
    add_vector!(glyph, -0.5, -0.5, 0.4, -0.5)
    push!(font.glyphs, glyph)

    # G
    glyph = VectorGlyph()
    add_vector!(glyph, 0.0, -0.5, 0.4, -0.5)
    add_vector!(glyph, 0.4, -0.5, 0.5, -0.4)
    add_vector!(glyph, 0.5, -0.4, 0.5, -0.25)
    add_vector!(glyph, 0.5, -0.25, 0.4, 0.0)
    add_vector!(glyph, 0.4, 0.0, -0.5, 0.0)
    add_vector!(glyph, -0.5, 0.0, -0.5, -1.0)
    add_vector!(glyph, -0.5, -1.0, 0.45, -1.0)
    add_vector!(glyph, 0.45, -1.0, 0.5, -0.75)
    push!(font.glyphs, glyph)

    # H
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, 0.0, -0.5, -1.0)
    add_vector!(glyph, 0.5, 0.0, 0.5, -1.0)
    add_vector!(glyph, -0.5, -0.5, 0.5, -0.5)
    push!(font.glyphs, glyph)

    # I
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, 0.0, 0.5, 0.0)
    add_vector!(glyph, -0.5, -1.0, 0.5, -1.0)
    add_vector!(glyph, 0.0, 0.0, 0.0, -1.0)
    push!(font.glyphs, glyph)

    # J
    glyph = VectorGlyph()
    add_vector!(glyph, -0.3, -0.75, -0.3, -1.0)
    add_vector!(glyph, -0.3, -1.0, 0.5, -1.0)
    add_vector!(glyph, 0.5, -1.0, 0.5, -0.25)
    add_vector!(glyph, 0.5, -0.25, 0.4, 0.0)
    add_vector!(glyph, 0.4, 0.0, -0.4, 0.0)
    add_vector!(glyph, -0.4, 0.0, -0.5, -0.25)
    push!(font.glyphs, glyph)

    # K
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, 0.0, -0.5, -1.0)
    add_vector!(glyph, -0.5, -0.5, 0.4, -1.0)
    add_vector!(glyph, -0.5, -0.5, 0.5, 0.0)
    push!(font.glyphs, glyph)

    # L
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, 0.0, -0.5, -1.0)
    add_vector!(glyph, -0.5, 0.0, 0.4, 0.0)
    push!(font.glyphs, glyph)

    # M
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, 0.0, -0.5, -1.0)
    add_vector!(glyph, -0.5, -1.0, 0.0, -0.5)
    add_vector!(glyph, 0.0, -0.5, 0.5, -1.0)
    add_vector!(glyph, 0.5, 0.0, 0.5, -1.0)
    push!(font.glyphs, glyph)

    # N
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, 0.0, -0.5, -1.0)
    add_vector!(glyph, -0.5, -1.0, 0.5, 0.0)
    add_vector!(glyph, 0.5, 0.0, 0.5, -1.0)
    push!(font.glyphs, glyph)

    # O
    glyph = VectorGlyph()
    add_vector!(glyph, 0.4, 0.0, -0.4, 0.0)
    add_vector!(glyph, -0.4, 0.0, -0.5, -0.25)
    add_vector!(glyph, -0.5, -0.25, -0.5, -0.75)
    add_vector!(glyph, -0.5, -0.75, -0.4, -1.0)
    add_vector!(glyph, -0.4, -1.0, 0.4, -1.0)
    add_vector!(glyph, 0.4, -1.0, 0.5, -0.75)
    add_vector!(glyph, 0.5, -0.75, 0.5, -0.25)
    add_vector!(glyph, 0.5, -0.25, 0.4, 0.0)
    push!(font.glyphs, glyph)

    # P
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, 0.0, -0.5, -1.0)
    add_vector!(glyph, -0.5, -1.0, 0.4, -1.0)
    add_vector!(glyph, 0.4, -1.0, 0.5, -0.85)
    add_vector!(glyph, 0.5, -0.85, 0.5, -0.65)
    add_vector!(glyph, 0.5, -0.65, 0.4, -0.5)
    add_vector!(glyph, 0.4, -0.5, -0.5, -0.5)
    push!(font.glyphs, glyph)

    # Q
    glyph = VectorGlyph()
    add_vector!(glyph, 0.4, 0.0, -0.4, 0.0)
    add_vector!(glyph, -0.4, 0.0, -0.5, -0.25)
    add_vector!(glyph, -0.5, -0.25, -0.5, -0.75)
    add_vector!(glyph, -0.5, -0.75, -0.4, -1.0)
    add_vector!(glyph, -0.4, -1.0, 0.4, -1.0)
    add_vector!(glyph, 0.4, -1.0, 0.5, -0.75)
    add_vector!(glyph, 0.5, -0.75, 0.5, -0.25)
    add_vector!(glyph, 0.5, -0.25, 0.4, 0.0)
    add_vector!(glyph, 0.0, -0.5, 0.7, 0.2)
    push!(font.glyphs, glyph)

    # R
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, 0.0, -0.5, -1.0)
    add_vector!(glyph, -0.5, -1.0, 0.4, -1.0)
    add_vector!(glyph, 0.4, -1.0, 0.5, -0.85)
    add_vector!(glyph, 0.5, -0.85, 0.5, -0.65)
    add_vector!(glyph, 0.5, -0.65, 0.4, -0.5)
    add_vector!(glyph, 0.4, -0.5, -0.5, -0.5)
    add_vector!(glyph, 0.2, -0.5, 0.5, -0.0)
    push!(font.glyphs, glyph)

    # S
    glyph = VectorGlyph()
    add_vector!(glyph, 0.4, 0.0, -0.4, 0.0)
    add_vector!(glyph, -0.4, 0.0, -0.5, -0.25)
    add_vector!(glyph, -0.5, -0.5, -0.5, -0.75)
    add_vector!(glyph, -0.5, -0.75, -0.4, -1.0)
    add_vector!(glyph, -0.4, -1.0, 0.4, -1.0)
    add_vector!(glyph, 0.4, -1.0, 0.5, -0.75)
    add_vector!(glyph, 0.5, -0.5, 0.5, -0.25)
    add_vector!(glyph, 0.5, -0.25, 0.4, 0.0)
    add_vector!(glyph, -0.5, -0.5, 0.5, -0.5)
    push!(font.glyphs, glyph)

    # T
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, -1.0, 0.5, -1.0)
    add_vector!(glyph, 0.0, 0.0, 0.0, -1.0)
    push!(font.glyphs, glyph)

    # U
    glyph = VectorGlyph()
    add_vector!(glyph, 0.4, 0.0, -0.4, 0.0)
    add_vector!(glyph, -0.4, 0.0, -0.5, -0.25)
    add_vector!(glyph, -0.5, -0.25, -0.5, -1.0)
    add_vector!(glyph, 0.5, -1.0, 0.5, -0.25)
    add_vector!(glyph, 0.5, -0.25, 0.4, 0.0)
    push!(font.glyphs, glyph)

    # V
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, -1.0, 0.0, 0.0)
    add_vector!(glyph, 0.0, 0.0, 0.5, -1.0)
    push!(font.glyphs, glyph)

    # W
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, -1.0, -0.5, 0.0)
    add_vector!(glyph, -0.5, 0.0, 0.0, -0.5)
    add_vector!(glyph, 0.0, -0.5, 0.5, 0.0)
    add_vector!(glyph, 0.5, -1.0, 0.5, 0.0)
    push!(font.glyphs, glyph)

    # X
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, -1.0, 0.5, 0.0)
    add_vector!(glyph, -0.5, 0.0, 0.5, -1.0)
    push!(font.glyphs, glyph)

    # Y
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, -1.0, 0.0, -0.5)
    add_vector!(glyph, 0.0, -0.5, 0.5, -1.0)
    add_vector!(glyph, 0.0, -0.5, 0.0, 0.0)
    push!(font.glyphs, glyph)

    # Z
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, -1.0, 0.5, -1.0)
    add_vector!(glyph, 0.5, -1.0, -0.5, 0.0)
    add_vector!(glyph, -0.5, 0.0, 0.5, 0.0)
    push!(font.glyphs, glyph)

    # 0
    glyph = VectorGlyph()
    add_vector!(glyph, 0.4, 0.0, -0.4, 0.0)
    add_vector!(glyph, -0.4, 0.0, -0.5, -0.25)
    add_vector!(glyph, -0.5, -0.25, -0.5, -0.75)
    add_vector!(glyph, -0.5, -0.75, -0.4, -1.0)
    add_vector!(glyph, -0.4, -1.0, 0.4, -1.0)
    add_vector!(glyph, 0.4, -1.0, 0.5, -0.75)
    add_vector!(glyph, 0.5, -0.75, 0.5, -0.25)
    add_vector!(glyph, 0.5, -0.25, 0.4, 0.0)
    add_vector!(glyph, -0.45, -0.1, 0.45, -0.9)
    push!(font.glyphs, glyph)

    # 1
    glyph = VectorGlyph()
    add_vector!(glyph, -0.2, -0.8, 0.0, -1.0)
    add_vector!(glyph, 0.0, -1.0, 0.0, 0.0)
    add_vector!(glyph, -0.5, 0.0, 0.5, 0.0)
    push!(font.glyphs, glyph)

    # 2
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, -1.0, 0.4, -1.0)
    add_vector!(glyph, 0.4, -1.0, 0.5, -0.75)
    add_vector!(glyph, 0.5, -0.75, -0.5, 0.0)
    add_vector!(glyph, -0.5, 0.0, 0.5, 0.0)
    push!(font.glyphs, glyph)

    # 3
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, -1.0, 0.5, -1.0)
    add_vector!(glyph, 0.5, -1.0, 0.5, 0.0)
    add_vector!(glyph, 0.5, 0.0, -0.5, 0.0)
    add_vector!(glyph, -0.4, -0.5, 0.5, -0.5)
    push!(font.glyphs, glyph)

    # 4
    glyph = VectorGlyph()
    add_vector!(glyph, 0.0, 0.0, 0.0, -1.0)
    add_vector!(glyph, 0.0, -1.0, -0.5, -0.5)
    add_vector!(glyph, -0.5, -0.5, 0.5, -0.5)
    push!(font.glyphs, glyph)

    # 5
    glyph = VectorGlyph()
    add_vector!(glyph, 0.5, -1.0, 0.0, -1.0)
    add_vector!(glyph, 0.0, -1.0, 0.0, -0.5)
    add_vector!(glyph, 0.0, -0.5, 0.4, -0.5)
    add_vector!(glyph, 0.4, -0.5, 0.5, -0.4)
    add_vector!(glyph, 0.5, -0.4, 0.5, -0.25)
    add_vector!(glyph, 0.5, -0.25, 0.4, 0.0)
    add_vector!(glyph, 0.4, 0.0, -0.5, 0.0)
    push!(font.glyphs, glyph)

    # 6
    glyph = VectorGlyph()
    add_vector!(glyph, 0.5, -1.0, -0.5, -0.5)
    add_vector!(glyph, -0.5, -0.5, 0.5, -0.5)
    add_vector!(glyph, 0.5, -0.5, 0.5, 0.0)
    add_vector!(glyph, 0.5, 0.0, -0.5, 0.0)
    add_vector!(glyph, -0.5, 0.0, -0.5, -0.5)
    push!(font.glyphs, glyph)

    # 7
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, -1.0, 0.5, -1.0)
    add_vector!(glyph, 0.5, -1.0, 0.0, 0.0)
    push!(font.glyphs, glyph)

    # 8
    glyph = VectorGlyph()
    add_vector!(glyph, 0.4, 0.0, -0.4, 0.0)
    add_vector!(glyph, -0.4, 0.0, -0.5, -0.25)
    add_vector!(glyph, -0.5, -0.25, -0.5, -0.75)
    add_vector!(glyph, -0.5, -0.75, -0.4, -1.0)
    add_vector!(glyph, -0.4, -1.0, 0.4, -1.0)
    add_vector!(glyph, 0.4, -1.0, 0.5, -0.75)
    add_vector!(glyph, 0.5, -0.75, 0.5, -0.25)
    add_vector!(glyph, 0.5, -0.25, 0.4, 0.0)
    add_vector!(glyph, -0.5, -0.5, 0.5, -0.5)
    push!(font.glyphs, glyph)

    # 9
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, 0.0, 0.5, -0.5)
    add_vector!(glyph, -0.5, -0.5, 0.5, -0.5)
    add_vector!(glyph, 0.5, -0.5, 0.5, -1.0)
    add_vector!(glyph, 0.5, -1.0, -0.5, -1.0)
    add_vector!(glyph, -0.5, -1.0, -0.5, -0.5)
    push!(font.glyphs, glyph)

    # =
    glyph = VectorGlyph()
    add_vector!(glyph, -0.5, -0.3, 0.5, -0.3)
    add_vector!(glyph, -0.5, -0.7, 0.5, -0.7)
    push!(font.glyphs, glyph)

    # ,
    glyph = VectorGlyph()
    add_vector!(glyph, 0.0, -0.3, 0.0, -0.2)
    add_vector!(glyph, 0.0, -0.2, -0.3, -0.0)
    push!(font.glyphs, glyph)

    # .
    glyph = VectorGlyph()
    add_vector!(glyph, -0.1, 0.0, -0.1, -0.1)
    add_vector!(glyph, -0.1, -0.1, 0.1, -0.1)
    add_vector!(glyph, 0.1, -0.1, 0.1, 0.0)
    add_vector!(glyph, 0.1, 0.0, -0.1, 0.0)
    push!(font.glyphs, glyph)

    # "/"
    glyph = VectorGlyph()
    add_vector!(glyph, -0.25, 0.0, 0.25, -1.0)
    push!(font.glyphs, glyph)

    # !
    glyph = VectorGlyph()
    add_vector!(glyph, -0.1, 0.0, -0.1, -0.1)
    add_vector!(glyph, -0.1, -0.1, 0.1, -0.1)
    add_vector!(glyph, 0.1, -0.1, 0.1, 0.0)
    add_vector!(glyph, 0.1, 0.0, -0.1, 0.0)
    add_vector!(glyph, 0.0, -0.2, 0.0, -1.0)
    push!(font.glyphs, glyph)

    # :
    glyph = VectorGlyph()
    add_vector!(glyph, -0.1, 0.0, -0.1, -0.1)
    add_vector!(glyph, -0.1, -0.1, 0.1, -0.1)
    add_vector!(glyph, 0.1, -0.1, 0.1, 0.0)
    add_vector!(glyph, 0.1, 0.0, -0.1, 0.0)
    add_vector!(glyph, -0.1, -0.9, -0.1, -1.0)
    add_vector!(glyph, -0.1, -1.0, 0.1, -1.0)
    add_vector!(glyph, 0.1, -1.0, 0.1, -0.9)
    add_vector!(glyph, 0.1, -0.9, -0.1, -0.9)
    push!(font.glyphs, glyph)

    # _
    glyph = VectorGlyph()
    add_vector!(glyph, -0.45, -0.1, 0.45, -0.1)
    push!(font.glyphs, glyph)

    # -
    glyph = VectorGlyph()
    add_vector!(glyph, -0.40, -0.5, 0.40, -0.5)
    push!(font.glyphs, glyph)

    # " " <-- space
    glyph = VectorGlyph()
    add_vector!(glyph, 0.0, 0.0, 0.0, 0.0)
    push!(font.glyphs, glyph)    
end

VectorFontDict = Dict([
    ('A', 1),
    ('B', 2),
    ('C', 3),
    ('D', 4),
    ('E', 5),
    ('F', 6),
    ('G', 7),
    ('H', 8),
    ('I', 9),
    ('J', 10),
    ('K', 11),
    ('L', 12),
    ('M', 13),
    ('N', 14),
    ('O', 15),
    ('P', 16),
    ('Q', 17),
    ('R', 18),
    ('S', 19),
    ('T', 20),
    ('U', 21),
    ('V', 22),
    ('W', 23),
    ('X', 24),
    ('Y', 25),
    ('Z', 26),
    ('0', 27),
    ('1', 28),
    ('2', 29),
    ('3', 30),
    ('4', 31),
    ('5', 32),
    ('6', 33),
    ('7', 34),
    ('8', 35),
    ('9', 36),
    ('=', 37),
    (',', 38),
    ('.', 39),
    ('/', 40),
    ('!', 41),
    (':', 42),
    ('_', 43),
    ('-', 44),
    (' ', 45)
    ])


function get_glyph(font::VectorFont, char::Char) # returns a VectorGlyph
    glyph = VectorFontDict[char]
    font.glyphs[glyph]
end