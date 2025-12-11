#!/usr/bin/env julia

using Pipe: @pipe
using DataStructures

parseinput(filename) = @pipe(
    filename
    |> readlines(_)
    |> map(l -> split(l, ": "), _)
    |> map(p -> (p[1], split(p[2])), _)
    |> foldl((d, (source, dests)) -> begin
            d[source] = dests
            d
        end, _; init=DefaultDict([]))
)

function part1(filename)
    graph = parseinput(filename)

    paths = 0
    generation = graph["you"]

    while length(generation) > 0
        outs = findall(s -> s == "out", generation)
        paths += length(outs)
        deleteat!(generation, outs)

        generation′ = []
        for k in generation
            append!(generation′, graph[k])
        end
        generation = generation′
    end

    paths
end

filename = length(ARGS) >= 1 ? ARGS[1] : "input.txt"

println(part1(filename))