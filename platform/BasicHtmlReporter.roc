## This module contains a reporter that can be used to save test results as files.
##
## This `Reporter` generates a single HTML file to represent the results.
##
## This is the default `Reporter`.
module [reporter]

import Reporting exposing [html_encode]
import Error

## Reporter.
##
## ```
## reporters = [BasicHtmlReporter.reporter]
## ```
reporter = Reporting.create_reporter(
    "basicHtmlReporter",
    |results, meta|
        duration = ((Num.to_frac(meta.duration)) / 1000) |> sec_to_min_and_sec
        # filter out failed attempts
        final_results = results |> List.keep_if(is_final_result)
        success_count = final_results |> List.count_if(|{ result }| result |> Result.is_ok)
        error_count = final_results |> List.count_if(|{ result }| result |> Result.is_err)

        report_content = results |> List.map(result_to_html) |> List.walk("", Str.concat)
        html_str = get_html(duration, success_count, error_count, report_content)

        [{ file_path: "index.html", content: html_str }],
)

result_to_html = |{ name, result, duration, screenshot, logs, type }|
    safe_name =
        when type is
            FinalResult -> name |> html_encode
            Attempt -> "${name} (attempt)" |> html_encode
    is_ok = result |> Result.is_ok
    class =
        when type is
            FinalResult ->
                if is_ok then "ok" else "error"

            Attempt ->
                "warning"
    test_details = get_test_details(result, screenshot, logs)
    test_duration = (Num.to_frac(duration)) / 1000 |> frac_to_str

    """
    <li class="${class}">
        <div class="test-header">
            <span>${safe_name}</span>
            <span class="test-duration">-> ${test_duration}s</span>
        </div>
        ${test_details}
    </li>
    """

get_test_details = |result, screenshot, logs|
    when result is
        Ok({}) if logs |> List.is_empty ->
            """
            <div class="test-details">
                <div class="block">
                    <div class="output">
                        -
                    </div>
                </div>
            </div>
            """

        Ok({}) ->
            """
            <div class="test-details">
                <div class="block">
                    <div class="output">
                        ${print_logs(logs)}
                    </div>
                </div>
            </div>
            """

        Err(err) ->
            safe_msg = err |> handle_error |> html_encode
            optional_screenshot =
                when screenshot is
                    NoScreenshot -> ""
                    Screenshot(base64) ->
                        """
                        <img class="screenshot" src="data:image/png;base64, ${base64}" />
                        """
            """
            <div class="test-details">
                <div class="block">
                    <div class="output">
                        ${print_logs(logs)}
                        <div class="error-message">
                            ${safe_msg}
                        </div>
                    </div>
                </div>
                ${optional_screenshot}
            </div>
            """

print_logs = |logs|
    if logs |> List.is_empty then
        ""
    else
        items =
            logs
            |> List.map(
                |log|
                    """
                    <li>${log |> html_encode}</li>
                    """,
            )
            |> Str.join_with("")

        """
        <ul class="log-list">${items}</ul>
        """

is_final_result = |{ type }| type == FinalResult

handle_error = |error_tag|
    when Error.web_driver_error_to_str(error_tag) is
        StringError(msg) -> msg
        err -> err |> Inspect.to_str

frac_to_str : Frac * -> Str
frac_to_str = |frac|
    Num.to_str(((Num.to_frac(Num.round((frac * 10)))) / 10))

sec_to_min_and_sec = |time|
    full_minutes = (time / 60) |> Num.floor
    seconds = (time - Num.to_frac((full_minutes * 60))) |> Num.ceiling
    (full_minutes, seconds)

get_html = |duration, success_count, error_count, results_content|
    (min, sec) = duration
    minutes_str = min |> Num.to_str
    seconds_str = sec |> Num.to_str
    success_count_str = success_count |> Num.to_str
    error_count_str = error_count |> Num.to_str
    """
    <!DOCTYPE html>
    <html lang="en">

    <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>R2E Test Report</title>

    </head>
    <style>
    :root {
        --header-bg: #202746;
        --block-bg: #202746;
        --body-bg: #151517;
        --text-color: #ccc;
        /* --ok-color: #8ecc88; */
        --primary-color: #9c7cea;
        --ok-color: #12c9be;
        --warning-color: #f39bac;
        --error-color: #fd6e08;
        --gray: #b6b6b6;

        --max-content-width: 60rem;
        --content-width: min(100% - 3rem, var(--max-content-width));
    }

    body {
        padding: 0;
        margin: 0;

        font-family: ui-rounded, 'Hiragino Maru Gothic ProN', Quicksand, Comfortaa, Manjari, 'Arial Rounded MT', 'Arial Rounded MT Bold', Calibri, source-sans-pro, sans-serif;
        font-weight: normal;
        color: var(--text-color);
        background-color: var(--body-bg);

    }

    header {
        display: flex;
        justify-content: center;
        background-color: var(--header-bg);
    }

    .metadata {
        display: flex;
        justify-content: center;
        padding-block: 2em;
        gap: 1.2em;
    }

    .metric {
        display: flex;
        justify-content: center;
        gap: 0.3em;
    }

    .metric span {
        align-self: center;
    }

    svg {
        width: 2em;
    }

    svg.clock path {
        stroke: var(--primary-color);
    }

    svg.clock-small {
        width: 1.4em;
    }

    svg.clock-small path {
        stroke: var(--primary-color);
    }

    svg.ok {
        width: 1.7em;
    }

    svg.ok path {
        fill: var(--ok-color);
    }

    svg.error path {
        fill: var(--error-color);
    }

    .title {
        padding: 1em;
    }

    .container {
        width: var(--content-width);
        margin-left: auto;
        margin-right: auto;
    }

    ul.test-list {
        list-style-type: square;
    }

    ul.log-list {
        list-style-type: square;
        padding-left: 18px;
    }

    li.ok {
        color: var(--ok-color);
    }

    li.error {
        color: var(--error-color);
    }

    li.warning {
        color: var(--warning-color);
    }

    .output {
        display: flex;
        flex-direction: column;
        gap: 1em;
        color: var(--text-color);
        font-family: system-ui, sans-serif;
        font-weight: normal;
    }

    .error-message {
        color: var(--error-color);
    }

    .test-header {
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 2em;
    }

    .test-duration {
        color: var(--gray);
        font-family: system-ui, sans-serif;
        font-weight: normal;
        font-size: 0.8em;
    }

    .test-details {
        max-height: 0;
        overflow: hidden;
        transition: max-height 0.3s ease;
    }

    .block {
        background-color: var(--block-bg);
        padding: 1em;
        margin: 1em 0;
    }

    .screenshot {
        width: 100%;
        margin-top: 1em;
    }
    </style>


    <body>
    <header>
        <div class="title">R2E Test Results</div>
    </header>
    <main>
        <div class="container">
        <div class="metadata">
            <div class="metric">
            <svg class="clock" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path
                d="M5.06152 12C5.55362 8.05369 8.92001 5 12.9996 5C17.4179 5 20.9996 8.58172 20.9996 13C20.9996 17.4183 17.4179 21 12.9996 21H8M13 13V9M11 3H15M3 15H8M5 18H10"
                stroke="#000000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
            </svg>
            <span>${minutes_str} min ${seconds_str} s</span>
            </div>
            <div class="metric">
            <svg class="ok" xmlns="http://www.w3.org/2000/svg" x="0px" y="0px" viewBox="0 0 122.88 122.88">
                <path
                d="M34.388,67.984c-0.286-0.308-0.542-0.638-0.762-0.981c-0.221-0.345-0.414-0.714-0.573-1.097 c-0.531-1.265-0.675-2.631-0.451-3.934c0.224-1.294,0.812-2.531,1.744-3.548l0.34-0.35c2.293-2.185,5.771-2.592,8.499-0.951 c0.39,0.233,0.762,0.51,1.109,0.827l0.034,0.031c1.931,1.852,5.198,4.881,7.343,6.79l1.841,1.651l22.532-23.635 c0.317-0.327,0.666-0.62,1.035-0.876c0.378-0.261,0.775-0.482,1.185-0.661c0.414-0.181,0.852-0.323,1.3-0.421 c0.447-0.099,0.903-0.155,1.356-0.165h0.026c0.451-0.005,0.893,0.027,1.341,0.103c0.437,0.074,0.876,0.193,1.333,0.369 c0.421,0.161,0.825,0.363,1.207,0.604c0.365,0.231,0.721,0.506,1.056,0.822l0.162,0.147c0.316,0.313,0.601,0.653,0.85,1.014 c0.256,0.369,0.475,0.766,0.652,1.178c0.183,0.414,0.325,0.852,0.424,1.299c0.1,0.439,0.154,0.895,0.165,1.36v0.23 c-0.004,0.399-0.042,0.804-0.114,1.204c-0.079,0.435-0.198,0.863-0.356,1.271c-0.16,0.418-0.365,0.825-0.607,1.21 c-0.238,0.377-0.518,0.739-0.832,1.07l-27.219,28.56c-0.32,0.342-0.663,0.642-1.022,0.898c-0.369,0.264-0.767,0.491-1.183,0.681 c-0.417,0.188-0.851,0.337-1.288,0.44c-0.435,0.104-0.889,0.166-1.35,0.187l-0.125,0.003c-0.423,0.009-0.84-0.016-1.241-0.078 l-0.102-0.02c-0.415-0.07-0.819-0.174-1.205-0.31c-0.421-0.15-0.833-0.343-1.226-0.575l-0.063-0.04 c-0.371-0.224-0.717-0.477-1.032-0.754l-0.063-0.06c-1.58-1.466-3.297-2.958-5.033-4.466c-3.007-2.613-7.178-6.382-9.678-9.02 L34.388,67.984L34.388,67.984z M61.44,0c16.96,0,32.328,6.883,43.453,17.987c11.104,11.125,17.986,26.493,17.986,43.453 c0,16.961-6.883,32.329-17.986,43.454C93.769,115.998,78.4,122.88,61.44,122.88c-16.961,0-32.329-6.882-43.454-17.986 C6.882,93.769,0,78.4,0,61.439C0,44.48,6.882,29.112,17.986,17.987C29.112,6.883,44.479,0,61.44,0L61.44,0z M96.899,25.981 C87.826,16.907,75.29,11.296,61.44,11.296c-13.851,0-26.387,5.611-35.46,14.685c-9.073,9.073-14.684,21.609-14.684,35.458 c0,13.851,5.611,26.387,14.684,35.46s21.609,14.685,35.46,14.685c13.85,0,26.386-5.611,35.459-14.685s14.684-21.609,14.684-35.46 C111.583,47.59,105.973,35.054,96.899,25.981L96.899,25.981z" />
            </svg>
            <span>${success_count_str}</span>
            </div>
            <div class="metric">
            <svg class="error" xmlns="http://www.w3.org/2000/svg" x="0px" y="0px" viewBox="0 0 24 24">
                <path
                d="M 12 2 C 6.4889971 2 2 6.4889971 2 12 C 2 17.511003 6.4889971 22 12 22 C 17.511003 22 22 17.511003 22 12 C 22 6.4889971 17.511003 2 12 2 z M 12 4 C 16.430123 4 20 7.5698774 20 12 C 20 16.430123 16.430123 20 12 20 C 7.5698774 20 4 16.430123 4 12 C 4 7.5698774 7.5698774 4 12 4 z M 8.7070312 7.2929688 L 7.2929688 8.7070312 L 10.585938 12 L 7.2929688 15.292969 L 8.7070312 16.707031 L 12 13.414062 L 15.292969 16.707031 L 16.707031 15.292969 L 13.414062 12 L 16.707031 8.7070312 L 15.292969 7.2929688 L 12 10.585938 L 8.7070312 7.2929688 z">
                </path>
            </svg>
            <span>${error_count_str}</span>
            </div>
        </div>
        <ul class="test-list">
           ${results_content}
        </ul>
        </div>
    </main>
    </body>
    <script>
    document.querySelectorAll('.test-header').forEach(listItem => {
        listItem.addEventListener('click', () => {
            const accordionContent = listItem.nextElementSibling;

            listItem.classList.toggle('active');

            if (listItem.classList.contains('active')) {
                accordionContent.style.maxHeight = accordionContent.scrollHeight + 'px';
            } else {
                accordionContent.style.maxHeight = 0;
            }
        });
    });

    </script>

    </html>
    """
