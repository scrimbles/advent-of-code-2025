#!/usr/bin/env julia
# using adventofcode
include("src/rotations.jl")
using .Rotations: Rotation, DialState

function loudplus(s::DialState, r::Rotation)::DialState
    newstate = s + r
    if newstate.resets > s.resets && newstate.position != 0
        println("The dial is rotated ", r, " to point at ", newstate.position, ", crossing through zero ", newstate.resets - s.resets, " times.")
    else
        println("The dial is rotated ", r, " to point at ", newstate.position, ".")
    end
    newstate
end

state = DialState(50, 0)
println("The dial starts by pointing at ", state.position, ".")
result = reduce(loudplus, map(Rotation, readlines(ARGS[1])); init=state)
println("\nBecause the dial points at zero a total of ", result.resets, " times during this process, the password in this example is ", result.resets, ".")
