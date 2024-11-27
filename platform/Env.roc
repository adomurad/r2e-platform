module [get!]

import Effect

## Get the value of an environment variable.
##
## Will return empty `Str` when the variable is not set.
##
## ```
##  empty = Env.get! "FAKE_ENV_FOR_SURE_EMPTY" |> try
##  empty |> Assert.shouldBe "" |> try
##
##  env = Env.get! "SECRET_ENV_KEY" |> try
##  env |> Assert.shouldBe "secret_value" |> try
## ```
get! : Str => Str
get! = \name ->
    Effect.getEnv! name

