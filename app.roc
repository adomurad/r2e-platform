# app [testCases, config] { r2e: platform "https://github.com/adomurad/r2e-platform/releases/download/0.8.0/o-YITMnvpJZg-zxL2xKiCxBFlJzlEoEwdRY5a39WFZ0.tar.br" }
# app [main!] { r2e: platform "./platform/main.roc" }
app [test_cases, config] { r2e: platform "./platform/main.roc" }

import r2e.Test exposing [test]
import r2e.Config
import r2e.Debug
import r2e.Browser
import r2e.Element
import r2e.Assert

config = Config.default_config

test_cases = [test1]

test1 = test(
    "use roc repl",
    |browser|
        # go to roc-lang.org
        browser |> Browser.navigate_to!("http://roc-lang.org")?
        # find repl input
        repl_input = browser |> Browser.find_element!(Css("#source-input"))?
        # wait for the repl to initialize
        Debug.wait!(200)
        # send keys to repl
        repl_input |> Element.input_text!("0.1+0.2{enter}")?
        # find repl output element
        output_el = browser |> Browser.find_element!(Css(".output"))?
        # get output text
        output_text = output_el |> Element.get_text!?
        # assert text - fail for demo purpose
        output_text |> Assert.should_be("0.3000000001 : Frac *"),
)
