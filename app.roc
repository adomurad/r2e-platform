# example application
app [testCases] { r2e: platform "platform/main.roc" }

import r2e.Console
import r2e.Test exposing [test]
import r2e.Browser
import r2e.Element
import r2e.Assert

testCases = [
    test1,
    test2,
    test3,
]

test1 = test "test1" \browser ->
    Console.printLine! "Hello!"
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    input = browser |> Browser.findElement! (Css "#developer-name")
    input |> Element.click!
    Console.printLine! "after navigation"
    Console.wait! 1000
    # Console.printLine! "after waiting 5s"

    Console.printLine "wow"

test2 = test "test2" \browser ->
    Console.printLine! "test 2"
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    _ = browser |> Browser.findElement! (Css "#fake-id")
    Console.printLine "eeee, should not print !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
# crash "should not happend"

test3 = test "test4" \browser ->
    Console.printLine! "test 3"
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    # _ = browser |> Browser.findElement! (Css "#fake-id")
    # Console.printLine "eeee, should not print !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    Assert.failWith "test failed :)"
