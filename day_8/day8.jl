#!/usr/bin/env julia

using Pipe: @pipe
using Memoization: @memoize
using Distances: euclidean

@memoize dists(c₁::Set, c₂::Set) = [(j₁, j₂, dist(j₁, j₂)) for j₁ in c₁ for j₂ in c₂]
@memoize dist(v₁::Vector, v₂::Vector) = euclidean(v₁, v₂)

coords(line) = @pipe(
    line
    |> split(_, ',')
    |> map(n -> parse(Int, n), _)
)

function minⱼ(J)
    js = length(J)
    L = Inf
    I₁ = nothing
    I₂ = nothing
    J₁ = nothing
    J₂ = nothing

    for i₁ in 1:js
        for i₂ in i₁+1:js
            ls = dists(J[i₁], J[i₂])
            l, i = findmin(d -> d[3], ls)
            j₁ = ls[i][1]
            j₂ = ls[i][2]

            if L > l
                L, I₁, I₂, J₁, J₂ = l, i₁, i₂, j₁, j₂
            end
        end
    end

    I₁, I₂, J₁, J₂
end

function connections(js)
    c = []
    for (i₁, j₁) in enumerate(js[1:end])
        for j₂ in js[i₁+1:end]
            push!(c, Pair(j₁, j₂))
        end
    end

    c
end


function part1(filename, N)
    jxns = @pipe(
        filename
        |> readlines(_)
        |> map(coords, _)
    )

    cxns = @pipe(connections(jxns) |> sort(_; by=c -> dist(c[1], c[2])))

    circuits = @pipe(jxns |> map(j -> Set([j]), _))

    for conn in cxns[1:N]
        println("Connecting ", conn)

        c₁ = findfirst(circ -> conn[1] in circ, circuits)
        c₂ = findfirst(circ -> conn[2] in circ, circuits)

        circuits[c₁] = union(circuits[c₁], circuits[c₂])
        if c₁ != c₂
            deleteat!(circuits, c₂)
        end
    end

    sort!(circuits; lt=Base.:>, by=c -> length(c))

    println("Product of sizes of largest three circuits: ", @pipe(circuits |> map(length, _) |> reduce(*, _[1:3])))
end

function part2(filename)
    circuits = @pipe(
        filename
        |> readlines(_)
        |> map(coords, _)
        |> map(l -> Set([l]), _)
    )

    j₁, j₂ = nothing, nothing

    while length(circuits) > 1
        i₁, i₂, j₁, j₂ = minⱼ(circuits)
        println(length(circuits), " circuits remaining. Connecting: ", j₁, " => ", j₂)

        circuits[i₁] = union(circuits[i₁], circuits[i₂])
        deleteat!(circuits, i₂)
    end

    println("Product of last two X coordinates connected: ", j₁[1] * j₂[1])
end

filename = length(ARGS) >= 1 ? ARGS[1] : "input.txt"
println("Part I:")
part1(filename, 1000)
println("")

println("Part II:")
part2(filename)