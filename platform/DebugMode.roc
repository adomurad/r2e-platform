module [runIfDebugMode, flashElements, wait, showDebugMessageInBrowser, runIfVerbose]

import Effect
import Common.ExecuteJs as ExecuteJs
import Common.Locator exposing [Locator]
import Internal

isDebugMode : Task Bool []
isDebugMode =
    Effect.isDebugMode {}
    |> Task.map \num ->
        when num is
            1 -> Bool.true
            _ -> Bool.false
    |> Task.mapErr \_ -> crash "isDebugMode should never crash"

isVerbose : Task Bool []
isVerbose =
    Effect.isVerbose {}
    |> Task.map \num ->
        when num is
            1 -> Bool.true
            _ -> Bool.false
    |> Task.mapErr \_ -> crash "isVerbose should never crash"

debugModeWaitTime = 1500

wait = Effect.wait debugModeWaitTime |> Task.mapErr \_ -> crash "sleep should not fail"

runIfVerbose : ({} -> Task ok err) -> Task {} []
runIfVerbose = \task ->
    hasVerboseFlag = isVerbose!
    hasDebugFlag = isDebugMode!

    if hasVerboseFlag || hasDebugFlag then
        _ = task {} |> Task.result!
        Task.ok {}
    else
        Task.ok {}

runIfDebugMode : ({} -> Task ok err) -> Task {} []
runIfDebugMode = \task ->
    isDebug = isDebugMode!

    if isDebug then
        _ = task {} |> Task.result!
        Task.ok {}
    else
        Task.ok {}

flashElements : Str, Locator, [All, Single] -> Task {} [JsReturnTypeError Str, WebDriverError Str]
flashElements = \sessionId, locator, quantity ->
    # TODO better tests
    blinkScript =
        """
        if (!document.getElementById('r2e-blink')) {
          const style = document.createElement('style');
          style.id = 'r2e-blink';
          style.textContent = `
          @keyframes flashBoxShadow {
            0%, 100% { box-shadow: none; }
            30%, 70% { box-shadow: 0 0 10px 5px #FF00FF; }
          }
          .flash-box-shadow {
            animation: flashBoxShadow 1.5s ease-in-out;
          }
        `;

          // Inject the style into the DOM
          document.head.appendChild(style);

          window.r2eFlash = function flashElementBoxShadow(element) {
            element.classList.add('flash-box-shadow');

            setTimeout(() => {
              element.classList.remove('flash-box-shadow');
            }, 1500);
          };
        }
        """

    elementScript = locatorToScriptExecution locator quantity
    executeElementScript = ";(()=>{$(elementScript)})();"

    js = Str.concat blinkScript executeElementScript

    browser = Internal.packBrowserData { sessionId }

    _res : Str
    _res = browser |> ExecuteJs.executeJs! js

    Task.ok {}

locatorToScriptExecution : Locator, [Single, All] -> Str
locatorToScriptExecution = \locator, quantity ->
    when quantity is
        Single ->
            when locator is
                Css str ->
                    """
                    let el = document.querySelector("$(str)");
                    window.r2eFlash(el);
                    """

                TestId str ->
                    """
                    let el = document.querySelector('[data-testid="$(str)"]');
                    window.r2eFlash(el);
                    """

                XPath str ->
                    """
                    let xpath = "$(str)";
                    let result = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
                    let el = result.singleNodeValue;
                    window.r2eFlash(el);
                    """

                LinkText str ->
                    """
                    let links = document.querySelectorAll('a');
                    let elements = Array.from(links).filter(link => link.textContent.trim() === "$(str)");
                    let el = elements[0]
                    window.r2eFlash(el);
                    """

                PartialLinkText str ->
                    """
                    let links = document.querySelectorAll('a');
                    let elements = Array.from(links).filter(link => link.textContent.includes("$(str)"));
                    let el = elements[0]
                    window.r2eFlash(el);
                    """

        All ->
            when locator is
                Css str ->
                    """
                    let elements = document.querySelectorAll("$(str)");
                    for (let el of elements) {
                        window.r2eFlash(el);
                    }
                    """

                TestId str ->
                    """
                    let elements = document.querySelectorAll('[data-testid="$(str)"]');
                    for (let el of elements) {
                        window.r2eFlash(el);
                    }
                    """

                XPath str ->
                    """
                    let xpath = "$(str)";
                    let result = document.evaluate(xpath, document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);

                    for (let i = 0; i < result.snapshotLength; i++) {
                      let el = result.snapshotItem(i);
                      window.r2eFlash(el);
                    }
                    """

                LinkText str ->
                    """
                    let links = document.querySelectorAll('a');
                    let elements = Array.from(links).filter(link => link.textContent.trim() === "$(str)");
                    for (let el of elements) {
                        window.r2eFlash(el);
                    }
                    """

                PartialLinkText str ->
                    """
                    let links = document.querySelectorAll('a');
                    let elements = Array.from(links).filter(link => link.textContent.includes("$(str)"));
                    for (let el of elements) {
                        window.r2eFlash(el);
                    }
                    """

showDebugMessageInBrowser : Str, Str -> Task {} [WebDriverError Str, JsReturnTypeError Str]
showDebugMessageInBrowser = \sessionId, message ->
    browser = Internal.packBrowserData { sessionId }

    js =
        """
        function showInfoBox(message) {
            infoBox = document.createElement('div');
                
            // Apply styles directly in JavaScript
            infoBox.style.position = 'fixed';
            infoBox.style.bottom = '20px';
            infoBox.style.right = '20px';
            infoBox.style.backgroundColor = '#FF00FF';
            infoBox.style.color = 'white';
            infoBox.style.padding = '10px 20px';
            infoBox.style.borderRadius = '5px';
            infoBox.style.boxShadow = '0 4px 8px rgba(0, 0, 0, 0.1)';
            infoBox.style.fontSize = '32px';
            infoBox.style.opacity = '0';  // Initially hidden
            infoBox.style.transition = 'opacity 0.5s ease-in-out';
            infoBox.style.pointerEvents = 'none';  // Prevent interaction

            // Append the info-box to the body
            document.body.appendChild(infoBox);

            setTimeout(() => {
                infoBox.textContent = message;
                infoBox.style.opacity = '1';
            }, 20);

            // Remove the message after 1 second (fade out)
            setTimeout(() => {
                infoBox.style.opacity = '0';  // Fade out

                setTimeout(() => {
                    if (infoBox) {
                        infoBox.remove();
                    }
                }, 500);  // Delay removal to allow fade-out transition
            }, 1000); 
        }

        let message = arguments[0];
        showInfoBox(message);  
        """
    args = [String message]

    _res : Str
    _res = browser |> ExecuteJs.executeJsWithArgs! js args

    Task.ok {}
