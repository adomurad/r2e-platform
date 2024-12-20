module [get]

import Effect

## Get the value of an environment variable.
##
## Will return empty `Str` when the variable is not set.
##
## ```
##  empty = Env.get! "FAKE_ENV_FOR_SURE_EMPTY"
##  empty |> Assert.shouldBe! ""
##
##  env = Env.get! "SECRET_ENV_KEY"
##  env |> Assert.shouldBe! "secret_value"
## ```
get : Str -> Task Str []
get = \name ->
    Effect.getEnv name |> Task.mapErr \_ -> crash "getEnv should never crash"
