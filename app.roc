# example application
app [testCases] { pf: platform "platform/main.roc" }

import pf.Console
import pf.Test

testCases = [
    test1,
    test2,
]

test1 = Test.test "test1" \browser ->
    Console.printLine! "Hello!"
    res = Console.readLine!
    Console.printLine! "is this working?: $(res)"

    Console.wait! 2000

    Task.loop! 0 \total ->
        Console.printLine! "total: $(total |> Num.toStr)"
        if
            total > 10
        then
            Task.ok (Done {})
        else
            Task.ok (Step (total + 1))

    Console.printLine "wow"

test2 = Test.test "test2" \browser ->
    Console.printLine! "test 2"
