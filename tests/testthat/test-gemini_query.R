# test `gemini_query` function

test_that("query works",
{
  # the system will need to be set up correctly for this to work
  key <- try(getAPIKey("GEMINI_API_KEY", "Private", "Gemini", "api_key"),
             silent = TRUE)

  # skip the remaining tests if the API key is not found
  if(inherits(key, "try-error"))
  {
    skip("API key not found")
  }

  res <- gemini_query("What is 2 + 2?", 'gemini-1.5-pro', api_key = key)

  expect_true("gemini_response" %in% class(res))
  expect_true("gemini_history" %in% class(res$history))
})
