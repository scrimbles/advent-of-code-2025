#!/usr/bin/env julia

using Pipe: @pipe

"Find the maximum Joltage for a bank of batteries js using digits d"
function Jₘ(js::Vector{Int}, dₙ::Int)::Int
    Σ = 0
    radix = 1 # begin at beginning of array

    for dᵢ in 1:dₙ
        dᵣ = dₙ - dᵢ
        d, radix = findmax(identity, js[radix:end-(dᵣ)])
        Σ += d * 10^(dᵣ)
    end

    Σ
end

bs2b(bs) = map(b -> parse(Int, b), split(bs, ""))

filename = length(ARGS) >= 1 ? ARGS[1] : "input.txt"
result = @pipe(
    filename
    |> readlines
    |> map(bs2b, _)
    |> map(b -> Jₘ(b, 12), _)
    |> sum
)

println(result)