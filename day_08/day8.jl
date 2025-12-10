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

"""
Finds smallest connection between any two junctions.
Returns indicies of two circuits to connect,
as well as the relevant junctions within those circuits to connect
"""
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

"Creates vector containing coordinate pairs for all elements on triangular matrix composition of given vectors"
function connections(js)
    c = []
    for (i₁, j₁) in enumerate(js[1:end])
        for j₂ in js[i₁+1:end]
            push!(c, Pair(j₁, j₂))
        end
    end

    c
end

"Finds Product of sizes of three largest circuits after connecting the N shortest connections"
function part1(filename, N; debugmode)
    jxns = @pipe(
        filename
        |> readlines(_)
        |> map(coords, _)
    )

    cxns = @pipe(connections(jxns) |> sort(_; by=c -> dist(c[1], c[2])))

    circuits = @pipe(jxns |> map(j -> Set([j]), _))

    for conn in cxns[1:N]
        if debugmode
            println("Connecting ", conn)
        end

        c₁ = findfirst(circ -> conn[1] in circ, circuits)
        c₂ = findfirst(circ -> conn[2] in circ, circuits)

        circuits[c₁] = union(circuits[c₁], circuits[c₂])
        if c₁ != c₂
            deleteat!(circuits, c₂)
        end
    end

    sort!(circuits; lt=Base.:>, by=c -> length(c))
    soln = @pipe(circuits |> map(length, _) |> reduce(*, _[1:3]))

    if debugmode
        println("Product of sizes of largest three circuits: ", soln)
    end
    soln
end

"Finds the product of the X coordinates of the last two junction boxes to connect to form one circuit"
function part2(filename; debugmode)
    circuits = @pipe(
        filename
        |> readlines(_)
        |> map(coords, _)
        |> map(l -> Set([l]), _)
    )

    j₁, j₂ = nothing, nothing

    while length(circuits) > 1
        i₁, i₂, j₁, j₂ = minⱼ(circuits)
        if debugmode
            println(length(circuits), " circuits remaining. Connecting: ", j₁, " => ", j₂)
        end

        circuits[i₁] = union(circuits[i₁], circuits[i₂])
        deleteat!(circuits, i₂)
    end

    soln = j₁[1] * j₂[1]

    if debugmode
        println("Product of last two X coordinates connected: ", j₁[1] * j₂[1])
    end

    soln
end

debugmode = any(arg -> arg == "-d" || arg == "--debug", ARGS)
posargs = filter(arg -> arg != "-d" && arg != "--debug", ARGS)

filename = length(posargs) >= 1 ? posargs[1] : "input.txt"
N = length(posargs) >= 2 ? parse(Int, posargs[2]) : 1000

println("Part I:")
part1(filename, N; debugmode) |> println
println("")

println("Part II:")
part2(filename; debugmode) |> println