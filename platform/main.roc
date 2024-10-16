platform ""
    requires {} { testCases : List _ }
    # requires {} { main : Task {} [Exit I32 Str]_ }
    exposes [Console, Test, Browser]
    packages {}
    imports [Console, Test]
    provides [mainForHost]

mainForHost : Task {} I32
mainForHost =
    testCases
    |> Test.runTests
    |> Task.attempt \res ->
        when res is
            Ok {} -> Task.ok {}
            # Err (Exit code str) ->
            #     if Str.isEmpty str then
            #         Task.err code
            #     else
            #         Console.printLine str
            #         |> Task.onErr \_ -> Task.err code
            #         |> Task.await \{} -> Task.err code
            Err err ->
                Console.printLine "Program exited early with error: $(Inspect.toStr err)"
                |> Task.onErr \_ -> Task.err 1
                |> Task.await \_ -> Task.err 1

# Task.forEach testCases \testCase ->
#     { name, testBody } = Test.extractTestData testCase
#
#     # InternalSession
#
#     task = testBody browser
#
#     Task.attempt task \res ->
#         when res is
#             Ok {} -> Task.ok {}
#             Err (Exit code str) ->
#                 if Str.isEmpty str then
#                     Task.err code
#                 else
#                     Console.printLine str
#                     |> Task.onErr \_ -> Task.err code
#                     |> Task.await \{} -> Task.err code
#
#             Err err ->
#                 Console.printLine "Program exited early with error: $(Inspect.toStr err)"
#                 |> Task.onErr \_ -> Task.err 1
#                 |> Task.await \_ -> Task.err 1
