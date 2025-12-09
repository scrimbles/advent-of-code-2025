#!/usr/bin/env julia

using Pipe: @pipe
using Memoization: @memoize

@memoize area(p₁, p₂) = (abs(p₁[1] - p₂[1]) + 1) * (abs(p₁[2] - p₂[2]) + 1)
parseline(l) = @pipe(l |> split(_, ',') |> map(n -> parse(Int, n), _) |> tuple(_...))
validline(L, p₁, p₂) = length(filter(c -> c ∈ L, [(x, y) for x in p₁[1]:p₂[1] for y in p₁[2]:p₂[2]])) != 1

function validrect(L, r)
    p₁, p₂ = r

    x₋, x₊ = min(p₁[1], p₂[1]) + 1, max(p₁[1], p₂[1]) - 1
    y₋, y₊ = min(p₁[2], p₂[2]) + 1, max(p₁[2], p₂[2]) - 1

    if x₋ == x₊ || y₋ == y₊
        return validline(L, (x₋, y₋), (x₊, y₊))
    end

    edgetiles = union(
        [(x, y₊) for x in x₋:x₊],
        [(x, y₋) for x in x₋:x₊],
        [(x₋, y) for y in y₋:y₊],
        [(x₊, y) for y in y₋:y₊]
    )

    !any(tile -> tile ∈ L, edgetiles)
end

function combinations(l)
    cs = []
    for (i₁, c₁) in enumerate(l[1:end])
        for c₂ in l[i₁+1:end]
            push!(cs, Pair(c₁, c₂))
        end
    end

    cs
end

function loop(coords)
    valid = Set()
    Y₋, Y₊ = 1000, 0
    X₋, X₊ = 1000, 0

    for ((x₁, y₁), (x₂, y₂)) in [zip(coords[1:end-1], coords[2:end])..., (coords[end], coords[1])]
        x₋, x₊ = sort([x₁, x₂])
        y₋, y₊ = sort([y₁, y₂])
        green = x₋ == x₊ ? [(x₋, i) for i in y₋:y₊] : [(i, y₋) for i in x₋:x₊]
        valid = union(valid, green)
        Y₋, Y₊ = min(Y₋, y₋), max(Y₊, y₊)
        X₋, X₊ = min(X₋, x₋), max(X₊, x₊)
    end

    valid
end

part1(f) = @pipe(readlines(f) |> map(parseline, _) |> combinations |> map(p -> area(p...), _) |> maximum(identity, _))

function part2(f)
    coords = map(parseline, readlines(f))
    looptiles = loop(coords)
    rects = combinations(coords)

    sort!(rects; by=r -> area(r...), lt=Base.:>) # reverse sort by area, since it's fast to calculate
    println("Largest rectangle: ", area(rects[1]...))

    count = 0
    Threads.@threads for candidate in rects[47000:end]
        count += 1
        print("Trying candidate: ", count, "                                                  \r")
        if validrect(looptiles, candidate)
            A = area(candidate...)
            println("\nFound new max rectangle: ", candidate, " ", A, " units²")
            return A
        end
    end
end

filename = length(ARGS) >= 1 ? ARGS[1] : "input.txt"

println(part2(filename))