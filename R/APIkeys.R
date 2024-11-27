#' getAPIkey
#' Retrieve an API key either using `op` or from the environment
#'
#' @param key_name character name of the key to retrieve
#' @param ... additional arguments passed to `op`
#'
#' @details This function retrieves an API key with the name specified by `key_name`.
#' If `key_name` is not an environmental variable, the function will attempt to retrieve the key from from 1Password using `op`.
#'
#' To temporarily set the API key as an environmental variable (i.e. for the duration of R the session) use `Sys.setenv(key_name = "key")`, where "key" is the API key, and `key_name` is the name of the api key (e.g. "GEMINI_API_KEY").
#' To permanently set the API key as an environmental variable, add `key_name=key` (no quotes) to your `.Renviron` file - it is recommended you use `usethis::edit_r_envrion()` to open the .Renviron file if you are setting this globally.
#'
#' @seealso `op`
#'
#' @return character, the API key
#' @export
getAPIkey <- function(key_name, ...)
{
  if(Sys.getenv(key_name) != "")
    return(Sys.getenv(key_name))

  op(...)
}


#' op
#' Retrieve an item from 1Password using the `op` command line tool
#'
#' @param ... character, path to the item in 1Password
#'
#' @details This function retrieves an item from 1Password using the `op` command line tool.
#' The path to the item in 1Password should be provided as a series of arguments.
#' For example, to retrieve the API key, "api_key" from the "Gemini" item located in the "Private" vault, use `op("Private", "Gemini", "api_key")`.
#'
#' This function works well on Unix-like systems (e.g. Linux, macOS), but may require additional configuration on Windows.
#' If this function is having trouble finding `op`, first verify that the cli command for `op` is installed (see https://developer.1password.com/docs/cli/get-started/).
#' If it is still having trouble, the `OP` environment variable can be set to the path to the `op` executable.
#' To find the install path on Windows, run `(Get-Command op).Source` in the power shell and copy the path returned (ending with "\" and excluding "op.exe").
#'
#' To permanently add `OP` to the environment variables, open .Renviron with `usethis::edit_r_environ()` and add a new line with the something like the following (making sure you put "\\" for each backslash on Windows):
#' "OP=C:\\path\\to\\op\\" (Windows) or "OP=/path/to/op/" (Unix-like systems).
#' If `OP` isn't defined, `Sys.getenv("OP")` will return "", and the system call will look in the default PATH for `op`.
#'
#' @return character, the item from 1Password
#'
#' @export
op <- function(...)
{
  retval <- try(
    {
      paste0(Sys.getenv("OP"),
             "op read op://", paste(unlist(list(...)), collapse = "/")) |>
        system(intern = TRUE)
    })

  if(inherits(retval, "try-error"))
    stop("Error retrieving item from 1Password. Please verify that `op` is installed and the correct item path is provided. See ?op for more troubleshooting options.")

  return(retval)
}