#!/usr/bin/env julia

using Pipe: @pipe

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
    @pipe(input |> split(_, ") {")[2][1:end-1] |> split(_, ',') |> map(n -> parse(Int, n), _)),
)

function minswitches(input)
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

function main(filename)
    configs = map(parseinput, readlines(filename))
end

filename = length(ARGS) >= 1 ? ARGS[1] : "input.txt"
main(filename)