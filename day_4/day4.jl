#!/usr/bin/env julia

using Pipe: @pipe

function pad(grid::Matrix{Int64})
    m, n = size(grid)
    grid₁ = zeros(eltype(grid), m + 2, n + 2)
    grid₁[2:m+1, 2:n+1] = grid
    grid₁
end

δ(i) = [i[1]:(i[1]+2), i[2]:(i[2]+2)]
R(i, M) = M[i] == 1 && (sum(pad(M)[δ(i)...]) - 1) < 4 |> Int

T(M) = map(i -> R(i, M), eachindex(IndexCartesian(), M))
l2n(s::String)::Vector{Int} = [parse(Int, elem) for elem in replace(replace(s, Pair('.', '0')), Pair('@', 1))]

part1(filename) = @pipe(readlines(filename) |> map(l2n, _) |> stack |> T |> sum)
function part2(filename)
    M = @pipe(
        readlines(filename)
        |> map(l2n, _)
        |> stack
    )

    Σ = 0
    while !iszero(M)
        Mₜ = T(M)
        Σᵢ = sum(Mₜ)
        if Σᵢ == 0
            println("No more accessible rolls of paper.")
            break
        end
        println("Removing ", Σᵢ, " rolls of paper.")
        Σ += Σᵢ
        M = map(i -> M[i] ⊻ Mₜ[i], eachindex(IndexCartesian(), M))
    end

    Σ
end

filename = length(ARGS) >= 1 ? ARGS[1] : "input.txt"


println("Part I: ")
println(part1(filename), " accessible rolls of paper.")
println("")
println("Part II:")
println(part2(filename))
