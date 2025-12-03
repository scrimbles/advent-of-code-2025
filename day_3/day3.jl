#!/usr/bin/env julia

using Pipe: @pipe

"Find the maximum Joltage for a bank of batteries js"
function Jₘ(js)
    d₀ = max(js[1:end-1]...)
    r = findfirst(j -> j == d₀, js)
    d₁ = max(js[r+1:end]...)

    10d₀ + d₁
end

bs2b(bs) = map(b -> parse(Int, b), split(bs, ""))

result = @pipe(
    map(bs2b, readlines(ARGS[1]))
    |> map(Jₘ, _)
    |> sum
)

println(result)