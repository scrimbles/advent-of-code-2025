#!/usr/bin/env julia

using Pipe: @pipe
using RowEchelon: rref
using LinearSolve

"""
takes a string of the form [(.|#)+] and returns a binary number, padded with ones out to 16bits
note that the inverse of the target configuration is stored,
this means that we are storing the desired button composition, rather than the target state
"""
function parsebits(str)
    bits = 0xFFFF
    for i in 1:(length(str))
        if str[i] == '#'
            bits &= ~(0x8000 >> (i - 1))
        end
    end

    bits
end

parseswitch(str) = @pipe(str |> split(_[2:end-1], ',') |> map(n -> parse(Int, n), _) |> map(n -> 0x8000 >> (n), _) |> reduce(|, _))
parseswitches(str) = map(parseswitch, split(str))
parseinput(input) = (
    split(input[2:end], "]")[1] |> parsebits,
    @pipe(input |> split(_, "] ")[2] |> split(_, " {")[1] |> parseswitches),
    @pipe(input |> split(_, ") {")[2][1:end-1] |> split(_, ',') |> map(n -> parse(Float64, n), _)),
)

function minₛ(input)
    machine, switches, _ = input
    L = length(switches)

    pressed = L # we assume we'll have to press every switch

    # we will press somewhere between 1 and L switches,
    # with each configuration corresponding to a binary number between L and L ones
    # where a '1' in the nth place means that the nth switch is pressed
    for switchconf in 1:((1<<L)-1)
        numbits = count_ones(switchconf)
        if numbits >= pressed
            continue
        end

        candidate = 0x0000
        for switch in 1:L
            # if switchconf switches `switch`, switch it on
            if switchconf & (1 << (switch - 1)) != 0
                candidate = candidate ⊻ switches[switch]
            end
        end

        # if we've turned all the lights on
        if candidate ⊻ machine == 0xFFFF
            pressed = numbits
        end
    end

    pressed
end

tweak(n) = n - 0.9999999999 > floor(n) ? floor(n) + 1 : floor(n)
tweak(n::Vector) = map(tweak, n)
switchcol(s, Lⱼ) = @pipe(digits(s, base=2, pad=16)[end-(Lⱼ-1):end] .+ floatmin(Float64) |> reverse)
function minⱼ(input)
    _, switches, b = input
    Lⱼ = length(b)
    A = reduce(hcat, map(s -> switchcol(s, Lⱼ), switches))
    prob = LinearProblem(A, b)
    sol = solve(prob, KrylovJL_GMRES())
    # sol = A \ b |> sum
    # sol = round(sol) == sol ? sol : round(sol) - 1
    A, b
end

main(filename, f) = @pipe(
    filename
    |> readlines
    |> map(parseinput, _)
    |> map(f, _)
    |> sum
)

function part2(filename)
    configs = map(parseinput, readlines(filename))

end

filename = length(ARGS) >= 1 ? ARGS[1] : "input.txt"
println(main(filename, minₛ))
# println(main(filename, minⱼ))