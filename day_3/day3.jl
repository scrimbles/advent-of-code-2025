#!/usr/bin/env julia

using Pipe: @pipe

function J₁(js, ds, rem)
    if rem == 0
        return ds
    end

    d₀, r = findmax(identity, js[1:end-(rem-1)])

    J₁(js[r+1:end], vcat(ds, d₀), rem - 1)
end

"Find the maximum Joltage for a bank of batteries js using digits d"
function Jₘ(js, d)
    ds = J₁(js, [], d)
    sum([10^(i - 1) * d for (i, d) in ds |> reverse |> enumerate])
end

bs2b(bs) = map(b -> parse(Int, b), split(bs, ""))

result = @pipe(
    map(bs2b, readlines(ARGS[1]))
    |> map(b -> Jₘ(b, 12), _)
    |> sum
)

println(result)