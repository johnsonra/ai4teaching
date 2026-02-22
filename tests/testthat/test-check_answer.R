# test `gemini_query` function

key <- try(OPsecrets::get_secret("GEMINI_API_KEY",
                                 "Private", "Gemini", "api_key"),
           silent = TRUE)

test_that("query works",
{  
  # skip the remaining tests if the API key is not found
  if(inherits(key, "try-error") | length(key) == 0)
  {
    skip("API key not found")
  }

  question <- "Given two variables, `x` and `y`, provide a line of R code that will check if `x` is greater than `y`"

  # an incorrect answer
  res <- check_answer(question, "x == y", model = 'gemini-2.5-flash-lite', api_key = key)

  expect_true("learnr_mark_as" %in% class(res))
  expect_false(res$correct)

  # a correct answer
  res <- check_answer(question, "x > y", model = 'gemini-2.5-flash', api_key = key)

  expect_true("learnr_mark_as" %in% class(res))
  expect_true(res$correct)
})
