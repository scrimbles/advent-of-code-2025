#!/usr/bin/env julia

using Pipe: @pipe

function pad(grid::Matrix{Int64})
    m, n = size(grid)
    grid₁ = zeros(eltype(grid), m + 2, n + 2)
    grid₁[2:m+1, 2:n+1] = grid
    grid₁
end

function reachable(i::CartesianIndex{2}, M::Matrix{Int})::Int
    if M[i] == 0 # we cannot retrieve a roll of paper that is not there
        return 0
    end
    n = sum(pad(M)[(i[1]):(i[1]+2), (i[2]):(i[2]+2)]) - M[i]
    n < 4 ? 1 : 0
end
l2n₁(s::String)::String = replace(replace(s, Pair('.', '0')), Pair('@', 1))
l2n(s::String)::Vector{Int} = [parse(Int, elem) for elem in l2n₁(s)]


filename = length(ARGS) >= 1 ? ARGS[1] : "input.txt"
grid = @pipe(
    readlines(filename)
    |> map(l2n, _)
    |> reduce(hcat, _)
)

Σ = @pipe(
    grid
    |> eachindex(IndexCartesian(), _)
    |> map(i -> reachable(i, grid), _)
    |> sum
)

println(Σ)
