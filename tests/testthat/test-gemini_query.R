# test `gemini_query` function

# this will need to be updated to test this on a system other than the author's
Sys.setenv(GEMINI_API_KEY = op("Private", "Gemini", "api_key"))

test_that("query works",
{
  res <- gemini_query("What is 2 + 2?", 'gemini-1.5-pro')

  expect_true("gemini_response" %in% class(res))
  expect_true("gemini_history" %in% class(res$history))
})
