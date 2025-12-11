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

function numpaths(graph, start, finish)
    paths = 0
    generation = graph[start]

    while length(generation) > 0
        outs = findall(s -> s == finish, generation)
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

part1(graph) = numpaths(graph, "you", "out")

filename = length(ARGS) >= 1 ? ARGS[1] : "input.txt"
graph = parseinput(filename)
println(part1(graph))
println(part2(graph))