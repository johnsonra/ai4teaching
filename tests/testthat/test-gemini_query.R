# test `gemini_query` function

# command to pull Gemini API key from 1Password (see https://developer.1password.com/docs/cli/get-started/)

# this script will fail if `op` isn't installed or if the correct entry is missing from 1Password

# Windows: if op is installed and works on the powershell but isn't working here, set the OP environmental variable:
# run `(Get-Command op).Source` in the power shell (i.e. in a terminal window)
# copy the path returned (ending with "\" and excluding "op.exe")
# open .Renviron with `usethis::edit_r_environ()` and add a new line with the something like the following (making sure you put "\\" for each backslash):
# OP=C:\\path\\to\\op\\ 
# (if OP isn't defined, `Sys.getenv("OP")` will return "", so it should work either way)
cmnd <- "op read op://Private/Gemini/api_key"

if(Sys.info()[['sysname']] == "Windows")
{
  key <- system(paste0(Sys.getenv("OP"), cmnd), intern = TRUE)
  key <- system(paste0('powershell -Command "', cmnd, '"'), intern = TRUE)
    #shell(cmnd, shell = "powershell", intern = TRUE)
}else{
  key <- system(cmnd, intern = TRUE)
}

Sys.setenv(GEMINI_API_KEY = key)

test_that("query works",
{
  res <- gemini_query("What is 2 + 2?", 'gemini-1.5-pro')

  expect_true("gemini_response" %in% class(res))
  expect_true("gemini_history" %in% class(res$history))
})
