# example application
app [testCases] { r2e: platform "platform/main.roc" }

import r2e.Console
import r2e.Test exposing [test]
import r2e.Browser
import r2e.Element
import r2e.Assert

testCases = [
    test1,
]

test1 = test "test1" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    checkboxType = checkbox |> Element.getProperty! "size"
    when checkboxType is
        Ok type -> type |> Assert.shouldBe "wow"
        Err Empty -> Assert.failWith "should not ge empty"
