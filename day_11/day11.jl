#!/usr/bin/env julia

using Pipe: @pipe
using DataStructures
using Memoization: @memoize

parseinput(filename) = @pipe(
    filename
    |> readlines(_)
    |> map(l -> split(l, ": "), _)
    |> map(p -> (Symbol(p[1]), map(Symbol, split(p[2]))), _)
    |> foldl((d, (source, dests)) -> begin
            d[source] = dests
            d
        end, _; init=DefaultDict([]))
)

@memoize function numpaths(start, finish; avoid=nothing)
    if start == avoid
        return 0
    end

    if start == finish
        return 1
    end

    paths = 0
    for child in GRAPH[start]
        paths += numpaths(child, finish; avoid)
    end

    paths
end

function part2()
    srv2fft = numpaths(:svr, :fft; avoid=:dac)
    fft2dac = numpaths(:fft, :dac)
    dac2out = numpaths(:dac, :out; avoid=:fft)

    srv2dac = numpaths(:svr, :dac; avoid=:fft)
    dac2fft = numpaths(:dac, :fft)
    fft2out = numpaths(:fft, :out; avoid=:dac)

    srv2fft * fft2dac * dac2out + srv2dac * dac2fft * fft2out
end

filename = length(ARGS) >= 1 ? ARGS[1] : "input.txt"

GRAPH = parseinput(filename)
println("Part I: ", numpaths(:you, :out))
println("Part II: ", part2())