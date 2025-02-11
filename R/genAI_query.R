#' genAI_query
#' Query a genAI chatbot
#'
#' @param query character, The query for the chatbot
#' @param model character, The model to use (see details)
#' @param history list, A list of previous interactions in the conversation
#' @param ... Additional arguments passed to the function handling the query (i.e. `google_genAI`)
#'
#' @details This function queries a specific model with the provided query. The package only supports Gemini at this time, but support for OpenAI will soon be added.
#'
#' @return character, The response from the chatbot
#' @export
genAI_query <- function(query, model = 'gemini-1.5-flash', history = NULL, ...)
{
  if(grepl("gemini", model))
    return(gemini_query(query, model, ...))

  stop("Unrecognized model")

  return(NULL)
}


#' gemini_query
#' Query Gemini
#'
#' @param prompt character, the query for the chatbot
#' @param model character, the model to use (see https://ai.google.dev/gemini-api/docs/models/gemini for options)
#' @param history list, a list of previous interactions in the conversation
#' @param temperature numeric, a value between 0 and 2 that controls the randomness of the model (default = 0.5)
#' @param maxOutputTokens integer, the maximum number of tokens to output (default = 1024)
#' @param api_key character, an API key for Gemini (default = NULL)
#' @param ... Other parameters controlling model behavior (see details)
#'
#' @details This function queries a specific Gemini model with the provided query. To obtain a Gemini API key see https://aistudio.google.com/app/apikey.
#'
#' @seealso https://ai.google.dev/gemini-api/docs, https://github.com/johnsonra/OPsecrets
#' @references This is a modified version of functions provided in the `gemini.R` package (see https://github.com/jhk0530/gemini.R). The main difference is that this function gives the user more control over which model is used, allowing for use of newer models without the need for modifying the code.
#'
#' @return character, The response from the chatbot
#' @export
#' @importFrom cli cli_alert_danger cli_status cli_status_clear
#' @importFrom httr2 request req_url_query req_headers req_body_json req_perform resp_body_json
#' @importFrom OPsecrets get_secret
gemini_query <- function(prompt, model = "gemini-1.5-flash", history = NULL, temperature = 0.5,
                         maxOutputTokens = 1024, api_key = NULL, ...)
{
  if(is.null(api_key))
    api_key <- get_secret("GEMINI_API_KEY")

  if(is.null(history))
  {
    history <- list()
    class(history) <- c('query_history', 'list')
  }


  # check for valid inputs
  if(prompt == "" | !is.character(prompt))
  {
    cli_alert_danger("a valid prompt must be provided")
    return(NULL)
  }

  if(api_key == "" | is.null(api_key)) {
    cli_alert_danger("Please either set {.envvar GEMINI_API_KEY} with {.fn Sys.setenv} or provide an appropriate API key.")
    return(NULL)
  }

  if (temperature < 0 | temperature > 2) {
    cli_alert_danger("Error: temperature must be between 0 and 2")
    return(NULL)
  }

  if (!(model %in% c("gemini-1.5-flash", "gemini-1.5-pro"))) {
    cli_alert_danger("Warning: only the following models have been tested: 'gemini-1.5-flash', 'gemini-1.5-pro'")
  }


  # build request
  model_query <- paste0(model, "-latest:generateContent")
  url <- "https://generativelanguage.googleapis.com/v1beta/models/" # see https://ai.google.dev/gemini-api/docs/quickstart?lang=rest for updates

  prompt_w_history <- history |>
    addHistory(role = "user", item = prompt)

  sb <- cli_status("Gemini is answering...")
  req <- paste0(url, model_query) |>
    request() |>
    req_url_query(key = api_key) |>
    req_headers("Content-Type" = "application/json") |>
    req_body_json(list(
      contents = prompt_w_history,
      generationConfig = list(
        temperature = temperature,
        maxOutputTokens = maxOutputTokens
      )
    ))


  # submit request
  resp <- req_perform(req)
  cli_status_clear(id = sb)

  response <- resp_body_json(resp)$candidates[[1]]$content$parts[[1]]$text


  # update history before returning results
  history_updt <- prompt_w_history |>
    addHistory(role = "model", item = response)

  retval <- list(response = response,
                 history = history_updt,
                 base_url = url,
                 model = model)
  class(retval) <- c('query_response', 'list')

  return(retval)
}
