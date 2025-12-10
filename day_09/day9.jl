#!/usr/bin/env julia

using Pipe: @pipe
using Memoization: @memoize

@memoize area(p₁, p₂) = (abs(p₁[1] - p₂[1]) + 1) * (abs(p₁[2] - p₂[2]) + 1)
parseline(l) = @pipe(l |> split(_, ',') |> map(n -> parse(Int, n), _) |> tuple(_...))

function rect_in_loop(L, r)
    p₁, p₂ = r

    x₋, x₊ = min(p₁[1], p₂[1]) + 1, max(p₁[1], p₂[1]) - 1
    y₋, y₊ = min(p₁[2], p₂[2]) + 1, max(p₁[2], p₂[2]) - 1

    !any(l -> x₋ <= l[1] <= x₊ && y₋ <= l[2] <= y₊, L)
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

function loopᵥ(coords)
    corners = [zip(coords[1:end-1], coords[2:end])..., (coords[end], coords[1])]
    Lₚ = 0
    for ((x₁, y₁), (x₂, y₂)) in corners
        Lₚ += abs(x₂ - x₁) + abs(y₂ - y₁)
    end

    valid = Array{Tuple}(undef, Lₚ)
    i = 1
    for ((x₁, y₁), (x₂, y₂)) in corners
        x₋, x₊ = sort([x₁, x₂])
        y₋, y₊ = sort([y₁, y₂])
        green = x₋ == x₊ ? [(x₋, i) for i in y₋:y₊-1] : [(i, y₋) for i in x₋:x₊-1]
        for greentile in green
            valid[i] = greentile
            i += 1
        end
    end

    valid
end

function loop(coords)
    valid = Set()

    for ((x₁, y₁), (x₂, y₂)) in [zip(coords[1:end-1], coords[2:end])..., (coords[end], coords[1])]
        x₋, x₊ = sort([x₁, x₂])
        y₋, y₊ = sort([y₁, y₂])
        green = x₋ == x₊ ? [(x₋, i) for i in y₋:y₊] : [(i, y₋) for i in x₋:x₊]
        valid = valid ∪ green
    end

    valid
end

part1(f) = @pipe(readlines(f) |> map(parseline, _) |> combinations |> map(p -> area(p...), _) |> maximum(identity, _))

function main(f)
    coords = map(parseline, readlines(f))
    looptiles = Set(loopᵥ(coords))
    rects = combinations(coords)

    sort!(rects; by=r -> area(r...), lt=Base.:>) # reverse sort by area, since it's fast to calculate

    A = 0
    Threads.@threads for candidate in rects
        if rect_in_loop(looptiles, candidate)
            A = area(candidate...)
            break
        end
    end
    #     Part I       Part II
    area(rects[1]...), A
end

filename = length(ARGS) >= 1 ? ARGS[1] : "input.txt"

println(main(filename))