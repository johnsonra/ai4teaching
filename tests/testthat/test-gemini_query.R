# test `gemini_query` function

Sys.setenv(GEMINI_API_KEY = system("op read op://Private/Gemini/api_key", intern = TRUE))

test_that("query works",
{
  res <- gemini_query("What is 2 + 2?", 'gemini-1.5-pro')

  expect_true("gemini_response" %in% class(res))
  expect_true("gemini_history" %in% class(res$history))
})
