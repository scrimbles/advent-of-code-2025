#!/usr/bin/env julia
# using adventofcode
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
    p₀ = rot.direction == left ? state.position - rot.distance : state.position + rot.distance
    p = p₀ < 0 ? ticks - abs(p₀) % ticks : p₀ % ticks
    DialState(p, p == 0 ? state.resets + 1 : state.resets)
end

Base.show(io::IO, r::Rotation) = print(io, r.direction == left ? "L" : "R", r.distance)

function loudplus(s::DialState, r::Rotation)::DialState
    newstate = s + r
    println("The dial is rotated ", r, " to point at ", newstate.position, ".")
    newstate
end

state = DialState(50, 0)
println("The dial starts by pointing at ", state.position, ".")
result = reduce(loudplus, map(Rotation, readlines(ARGS[1])); init=state)

println("\nBecause the dial points at zero a total of ", result.resets, " times during this process, the password in this example is ", result.resets, ".")
