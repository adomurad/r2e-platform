# example application
app [main] { pf: platform "platform/main.roc" }

import pf.Stdout

main =
    Stdout.line! "Hello!"
    Stdout.line! "is this working?"
