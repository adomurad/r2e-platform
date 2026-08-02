module [run_if_debug_mode!, flash_elements!, flash_current_frame!, wait!, show_debug_message_in_browser!, run_if_verbose!]

import Effect
import Common.ExecuteJs as ExecuteJs
import Common.Locator exposing [Locator]
import Internal

is_debug_mode! : {} => Bool
is_debug_mode! = |{}|
    when Effect.is_debug_mode!({}) is
        1 -> Bool.true
        _ -> Bool.false

is_verbose! : {} => Bool
is_verbose! = |{}|
    when Effect.is_verbose!({}) is
        1 -> Bool.true
        _ -> Bool.false

debug_mode_wait_time = 1500

wait! = |{}| Effect.wait!(debug_mode_wait_time)

run_if_verbose! : ({} => _) => {}
run_if_verbose! = |task!|
    has_verbose_flag = is_verbose!({})
    has_debug_flag = is_debug_mode!({})

    if has_verbose_flag or has_debug_flag then
        _ = task!({})
        {}
    else
        {}

run_if_debug_mode! : ({} => _) => {}
run_if_debug_mode! = |task!|
    is_debug = is_debug_mode!({})

    if is_debug then
        _ = task!({})
        {}
    else
        {}

flash_elements! : Str, Locator, [All, Single] => Result {} [JsReturnTypeError Str, WebDriverError Str]
flash_elements! = |session_id, locator, quantity|
    # TODO better tests
    blink_script =
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

    element_script = locator_to_script_execution(locator, quantity)
    execute_element_script = ";(()=>{${element_script}})();"

    js = Str.concat(blink_script, execute_element_script)

    browser = Internal.pack_browser_data({ session_id })

    _res : Str
    _res = browser |> ExecuteJs.execute_js!(js)?

    Ok({})

flash_current_frame! : Str => Result {} [JsReturnTypeError Str, WebDriverError Str]
flash_current_frame! = |session_id|
    # TODO better tests
    blink_script =
        """
        if (!document.getElementById('r2e-blink-frame')) {
          const style = document.createElement('style');
          style.id = 'r2e-blink-frame';
          style.textContent = `
          @keyframes flashBoxShadowFrame {
            0%, 100% { box-shadow: none; }
            30%, 70% { box-shadow: inset 0 0 10px 5px #FF00FF; }
          }
          .flash-box-shadow-frame {
            animation: flashBoxShadowFrame 1.5s ease-in-out;
          }
        `;

          // Inject the style into the DOM
          document.head.appendChild(style);

          window.r2eFlashFrame = function flashCurrentFrame() {
            const frameDiv = document.createElement("div");
            frameDiv.style.position = "fixed";
            frameDiv.style.width = "100%";
            frameDiv.style.height = "100%";
            frameDiv.style.zIndex = "9999";
            document.body.prepend(frameDiv);
            frameDiv.classList.add('flash-box-shadow-frame');

            setTimeout(() => {
              frameDiv.remove();
            }, 1500);
          };
        }
        r2eFlashFrame();
        """

    browser = Internal.pack_browser_data({ session_id })

    _res : Str
    _res = browser |> ExecuteJs.execute_js!(blink_script)?

    Ok({})

locator_to_script_execution : Locator, [Single, All] -> Str
locator_to_script_execution = |locator, quantity|
    when quantity is
        Single ->
            when locator is
                Css(str) ->
                    """
                    let el = document.querySelector("${str}");
                    window.r2eFlash(el);
                    """

                TestId(str) ->
                    """
                    let el = document.querySelector('[data-testid="${str}"]');
                    window.r2eFlash(el);
                    """

                XPath(str) ->
                    """
                    let xpath = "${str}";
                    let result = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
                    let el = result.singleNodeValue;
                    window.r2eFlash(el);
                    """

                LinkText(str) ->
                    """
                    let links = document.querySelectorAll('a');
                    let elements = Array.from(links).filter(link => link.textContent.trim() === "${str}");
                    let el = elements[0]
                    window.r2eFlash(el);
                    """

                PartialLinkText(str) ->
                    """
                    let links = document.querySelectorAll('a');
                    let elements = Array.from(links).filter(link => link.textContent.includes("${str}"));
                    let el = elements[0]
                    window.r2eFlash(el);
                    """

        All ->
            when locator is
                Css(str) ->
                    """
                    let elements = document.querySelectorAll("${str}");
                    for (let el of elements) {
                        window.r2eFlash(el);
                    }
                    """

                TestId(str) ->
                    """
                    let elements = document.querySelectorAll('[data-testid="${str}"]');
                    for (let el of elements) {
                        window.r2eFlash(el);
                    }
                    """

                XPath(str) ->
                    """
                    let xpath = "${str}";
                    let result = document.evaluate(xpath, document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);

                    for (let i = 0; i < result.snapshotLength; i++) {
                      let el = result.snapshotItem(i);
                      window.r2eFlash(el);
                    }
                    """

                LinkText(str) ->
                    """
                    let links = document.querySelectorAll('a');
                    let elements = Array.from(links).filter(link => link.textContent.trim() === "${str}");
                    for (let el of elements) {
                        window.r2eFlash(el);
                    }
                    """

                PartialLinkText(str) ->
                    """
                    let links = document.querySelectorAll('a');
                    let elements = Array.from(links).filter(link => link.textContent.includes("${str}"));
                    for (let el of elements) {
                        window.r2eFlash(el);
                    }
                    """

show_debug_message_in_browser! : Str, Str => Result {} [WebDriverError Str, JsReturnTypeError Str]
show_debug_message_in_browser! = |session_id, message|
    browser = Internal.pack_browser_data({ session_id })

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
            infoBox.style.fontFamily = 'system-ui, sans-serif';
            infoBox.style.fontWeight = 'normal';
            infoBox.style.lineHeight = '1.5';

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
    args = [String(message)]

    _res : Str
    _res = browser |> ExecuteJs.execute_js_with_args!(js, args)?

    Ok({})
