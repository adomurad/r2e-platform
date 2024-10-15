# this module will be replaced when effect interpreters are implemented
hosted Effect
    exposes [
        stdoutLine,
        stdinLine,
        wait,
        # setup,
        startsession,
        deletesession,
    ]
    imports []

# effects that are provided by the host
stdoutLine : Str -> Task {} Str

stdinLine : {} -> Task Str Str

# setup : {} -> Task {} Str

wait : U64 -> Task {} Str

startsession : {} -> Task Str Str
deletesession : Str -> Task {} Str
