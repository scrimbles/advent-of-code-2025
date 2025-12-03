#!/usr/bin/env julia

using Pipe: @pipe

function J₁(js, ds, rem)
    rem == 0 ? ds : begin
        d, r = findmax(identity, js[1:end-(rem-1)])
        J₁(js[r+1:end], vcat(ds, d), rem - 1)
    end
end

"Find the maximum Joltage for a bank of batteries js using digits d"
function Jₘ(js, d)
    ds = J₁(js, [], d)
    sum([10^(i - 1) * d for (i, d) in ds |> reverse |> enumerate])
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