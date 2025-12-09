#!/usr/bin/env julia

using Pipe: @pipe

area(p₁, p₂) = (abs(p₁[1] - p₂[1]) + 1) * (abs(p₁[2] - p₂[2]) + 1)
parseline(l) = @pipe(l |> split(_, ',') |> map(n -> parse(Int, n), _))
function combinations(l)
    cs = []
    for (i₁, c₁) in enumerate(l[1:end])
        for c₂ in l[i₁+1:end]
            push!(cs, Pair(c₁, c₂))
        end
    end

    cs
end

part1(f) = @pipe(readlines(f) |> map(parseline, _) |> combinations |> map(p -> area(p...), _) |> maximum(identity, _))

filename = length(ARGS) >= 1 ? ARGS[1] : "input.txt"

println(part1(filename))