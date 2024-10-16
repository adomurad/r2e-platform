# example application
app [testCases] { pf: platform "platform/main.roc" }

import pf.Console
import pf.Test
import pf.Browser

testCases = [
    test1,
    test2,
]

test1 = Test.test "test1" \browser ->
    Console.printLine! "Hello!"
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    Console.printLine! "after navigation"
    Console.wait! 5000
    Console.printLine! "after waiting 5s"

    Console.printLine "wow"

test2 = Test.test "test2" \browser ->
    Console.printLine! "test 2"
