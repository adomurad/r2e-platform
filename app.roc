# example application
app [main] { pf: platform "platform/main.roc" }

import pf.Console

main =
    Console.printLine! "Hello!"
    res = Console.readLine!
    Console.printLine! "is this working?: $(res)"
