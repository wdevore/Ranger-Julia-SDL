# Easing equation based on Robert Penner's work:
# http://robertpenner.com/easing/
# author
#    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
#    Xavier Guzman (dart port)
#    Cleveland (julia port)

abstract type AbstractTweenEquation end

const EASE_IN = 0
const EASE_OUT = 1
const EASE_INOUT = 2

include("expo.jl")
include("quad.jl")