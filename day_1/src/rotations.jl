module Rotations
import Base.+

# the number of ticks on the safe dial
const ticks = 100 # ||[0,99]|| = 100

struct DialState
    position::Integer
    resets::Integer
end

@enum Direction begin
    left
    right
end

struct Rotation
    direction::Direction
    distance::Integer
end

function Rotation(str::String)
    if length(str) < 2 || str[1] != 'L' && str[1] != 'R'
        throw(ArgumentError("input does not meet the format `^[LR]\\d\$`"))
    end
    dir = str[1] == 'L' ? left : right
    dist = parse(Int, str[2:end])
    Rotation(dir, dist)
end



function Base.:+(state::DialState, rot::Rotation)::DialState
    d = rot.distance % ticks
    p = rot.direction == left ? state.position - d : state.position + d
    p₁ = p < 0 ? p + 100 : p
    p₂ = p₁ % 100
    DialState(p₂, p₂ == 0 ? state.resets + 1 : state.resets)
end

Base.show(io::IO, r::Rotation) = print(io, r.direction == left ? "L" : "R", r.distance)
end