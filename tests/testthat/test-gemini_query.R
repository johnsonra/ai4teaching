# test `gemini_query` function

key <- try(OPsecrets::get_secret("GEMINI_API_KEY",
                                 "Private", "Gemini", "api_key"),
           silent = TRUE)

test_that("query works",
{
  if(inherits(key, "try-error") | length(key) == 0)
    skip("No API key found.")
  
  res <- gemini_query("What is 2 + 2?", 'gemini-2.5-flash', api_key = key)

  expect_true("query_response" %in% class(res))
  expect_true("query_history" %in% class(res$history))
})

test_that("gemini-2.5-flash-lite works",
{
  if(inherits(key, "try-error") | length(key) == 0)
    skip("No API key found.")

  res <- gemini_query("What is 2 + 2?", 'gemini-2.5-flash-lite', api_key = key)

  expect_s3_class(res,         "query_response")
  expect_s3_class(res$history, "query_history")
})

test_that("gemini-3-flash-preview works",
{
  if(inherits(key, "try-error") | length(key) == 0)
    skip("No API key found.")

  res <- gemini_query("What is 2 + 2?", 'gemini-3-flash-preview', api_key = key)

  expect_s3_class(res,         "query_response")
  expect_s3_class(res$history, "query_history")
})
