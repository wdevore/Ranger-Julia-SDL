export Palette,
    Gray
    
struct Palette
    # SDL requires Int64 not UInt8
    r::Int64
    g::Int64
    b::Int64
    a::Int64

    function Palette()
        new(0, 0, 0, 255)
    end

    function Palette(r::Integer, g::Integer, b::Integer)
        new(Int64(r), Int64(g), Int64(b), 255)
    end

    function Palette(r::Integer, g::Integer, b::Integer, a::Integer)
        new(Int64(r), Int64(g), Int64(b), Int64(a))
    end

    # 0xrrggbbaa
    function Palette(color::UInt32)
        r = Integer((color & 0xff000000) >> 24)
        g = Integer((color & 0x00ff0000) >> 16)
        b = Integer((color & 0x0000ff00) >> 8)
        a = Integer(color & 0x000000ff)
        new(Int64(r), Int64(g), Int64(b), Int64(a))
    end
end

function White()
    Palette(255, 255, 255)
end

function Black()
    Palette()
end

function Red()
    Palette(255, 0, 0)
end

function Green()
    Palette(0, 255, 0)
end

function Blue()
    Palette(0, 0, 255)
end

function DarkerGray()
    Palette(64, 64, 64)
end

function DarkGray()
    Palette(80, 80, 80)
end

function LightGray()
    Palette(100, 100, 100)
end

function Gray()
    Palette(0xAAAAAAFF)
end

function Silver()
    Palette(0xDDDDDDFF)
end

# ----------------------------------------------------
# Yellow hues
# ----------------------------------------------------
function Orange()
    Palette(255, 127, 0)
end
function SoftOrange()
    Palette(0xFF851BFF)
end
function Yellow()
    Palette(0xFFDC00FF)
end

# ----------------------------------------------------
# Green hues
# ----------------------------------------------------
function SoftGreen()
    Palette(0x2ECC40FF)
end
function Olive()
    Palette(0x3D9970FF)
end
function Teal()
    Palette(0x39CCCCFF)
end
function Lime()
    Palette(0x01FF70FF)
end

# ----------------------------------------------------
# Blue hues
# ----------------------------------------------------
function SoftBlue()
    Palette(0x0074D9FF)
end
function Navy()
    Palette(0x001f3fFF)
end
function Aqua()
    Palette(0x7FDBFFFF)
end
function LightPurple()
    Palette(0xaaaaffFF)
end

