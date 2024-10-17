# example application
app [testCases] { pf: platform "platform/main.roc" }

import pf.Console
import pf.Test
import pf.Browser
import pf.Element
import pf.Assert

testCases = [
    test1,
    test2,
    test3,
]

test1 = Test.test "test1" \browser ->
    Console.printLine! "Hello!"
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    input = browser |> Browser.findElement! (Css "#developer-name")
    input |> Element.click!
    Console.printLine! "after navigation"
    Console.wait! 1000
    # Console.printLine! "after waiting 5s"

    Console.printLine "wow"

test2 = Test.test "test2" \browser ->
    Console.printLine! "test 2"
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    _ = browser |> Browser.findElement! (Css "#fake-id")
    Console.printLine "eeee, should not print !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
# crash "should not happend"

test3 = Test.test "test4" \browser ->
    Console.printLine! "test 3"
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    # _ = browser |> Browser.findElement! (Css "#fake-id")
    # Console.printLine "eeee, should not print !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    Assert.failWith "test failed :)"
