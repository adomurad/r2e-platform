module [get!]

import Effect

## Get the value of an environment variable.
##
## Will return empty `Str` when the variable is not set.
##
## ```
##  empty = Env.get!("FAKE_ENV_FOR_SURE_EMPTY")?
##  empty |> Assert.should_be("")?
##
##  env = Env.get!("SECRET_ENV_KEY")?
##  env |> Assert.should_be("secret_value")?
## ```
get! : Str => Str
get! = |name|
    Effect.get_env!(name)

