when defined(nes):
    {.push stack_trace: off, profiler:off.}

    func rawoutput(s: string): void =
        discard

    func panic(s: string): void {.no_return.} =
        while true:
            discard

    {.pop.}
