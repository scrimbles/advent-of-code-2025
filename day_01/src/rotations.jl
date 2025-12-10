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

z₀(p) = p == 0 ? 1 : 0
function z₁(p₀, p₁, r)
    Δ = floor(r.distance / ticks)
    δ = r.distance % ticks
    δ₊ = p₀ == 0 ? false : δ > (r.direction == left ? p₀ : ticks - p₀)
    p₊ = p₁ == 0
    Δ + (δ₊ || p₊ ? 1 : 0)
end


function Base.:+(s::DialState, r::Rotation)::DialState
    d = r.distance % ticks
    p = r.direction == left ? s.position - d : s.position + d
    p₁ = (p < 0 ? p + 100 : p) % 100
    # z = z₀(p₁) # Part I
    z = z₁(s.position, p₁, r)
    DialState(p₁, s.resets + z)
end

Base.show(io::IO, r::Rotation) = print(io, r.direction == left ? "L" : "R", r.distance)
end