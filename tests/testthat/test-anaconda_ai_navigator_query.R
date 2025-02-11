# test anaconda_ai_navigator_query function

test_that("Anaconda AI queries work",
{
  # the system will need to be set up correctly for this to work
  key <- try(OPsecrets::get_secret("AI_NAV_KEY",
                                   "Private", "Anaconda", "ai_nav_key"),
             silent = TRUE)

  # skip the remaining tests if the API key is not found
  if(inherits(key, "try-error"))
  {
    skip("API key not found")
  }

  # check health
  health_check <- request('http://localhost:8080/health') |>
    req_headers('Authorization' = paste("Bearer", key)) |>
    req_perform()

  if(health_check$status_code != 200)
  {
    skip("Anaconda AI Navigator is not running")
  }

  # run basic sanity test
  res <- anaconda_ai_navigator_query('What is 2 + 2?', api_key = key)

  expect_s3_class(res,         "query_response")
  expect_s3_class(res$history, "query_history")
})
