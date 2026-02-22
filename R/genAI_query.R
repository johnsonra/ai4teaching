#' genAI_query
#' Query a genAI chatbot
#'
#' @param query character, The query for the chatbot
#' @param model character, The model to use (see details)
#' @param history list, A list of previous interactions in the conversation
#' @param ai_nav logical, If TRUE, the function will use Anaconda AI Navigator
#' @param ... Additional arguments passed to the function handling the query (i.e. `google_genAI`)
#'
#' @details This function queries a specific model with the provided query. The package only supports Gemini at this time, but support for OpenAI will soon be added.
#'
#' @return character, The response from the chatbot
#' @export
genAI_query <- function(query, model = 'gemini-2.5-flash', history = NULL, ai_nav = FALSE, ...)
{
  if(grepl("gemini", model))
    return(gemini_query(query, model, ...))

  if(ai_nav)
    return(anaconda_ai_navigator_query(query, model, ...))

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
gemini_query <- function(prompt, model = "gemini-2.5-flash", history = NULL, temperature = 0.5,
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

  if (!(model %in% c("gemini-2.5-flash", "gemini-2.5-flash-lite", 'gemini-3-flash-preview'))) {
    cli_alert_danger("Warning: only the following models have been tested: 'gemini-2.5-flash', 'gemini-2.5-flash-lite', 'gemini-3-flash-preview', ")
  }


  # build request
  model_query <- paste0(model, ":generateContent")
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


#' anaconda_ai_navigator_query
#' Query Anaconda AI Navigator
#'
#' @param prompt character, the query for the chatbot
#' @param model character, the model to use (see the `Models` pane in AI Navigator for appropriate options for your computer)
#' @param history list, a list of previous interactions in the conversation
#' @param api_key character, an API key for Anaconda AI Navigator (default = NULL)
#' @param base_url character, the base URL for the model (default = 'http://localhost')
#' @param port integer, the port on which the model is running (default = 8080)
#' @param temperature numeric, a value between 0 and 1 that controls the randomness of the model (default = 0.8)
#' @param top_k integer, the number of tokens to consider at each step (default = 40)
#' @param top_p numeric, the cumulative probability of tokens to consider at each step (default = 0.95)
#' @param n_predict integer, the number of tokens to predict (default = 200)
#' @param stop character, a list of tokens at which to stop (default = "</s>")
#' @param ... Other parameters controlling model behavior (see details)
#'
#' @details This function queries a specific Anaconda AI Navigator model with the provided query.
#' AI Navigator does not require an API key to run locally.
#' When `api_key` is NULL, the function will assume the model is running locally and does not require an API key.
#'
#' The output from these models can vary greatly depending on the model, prompt, and parameters.
#' Not all models utilize the `stop` parameter correctly, resulting in some rambling responses.
#'
#' @seealso https://docs.anaconda.com/ai-navigator/
#'
#' @return character, The response from the chatbot.
#' @export
#' @importFrom cli cli_alert_danger cli_status cli_status_clear
#' @importFrom httr2 request req_headers req_body_json req_perform resp_body_json
#' @importFrom stringr fixed str_split str_replace
anaconda_ai_navigator_query <- function(prompt, model = NULL, history = NULL, api_key = NULL,
                                        base_url = 'http://localhost', port = 8080, temperature = 0.8,
                                        top_k = 40, top_p = 0.95, n_predict = 200, stop = list("</s>"), ...)
{
  # check for valid inputs
  if(prompt == "" | !is.character(prompt))
  {
    cli_alert_danger("a valid prompt must be provided")
    return(NULL)
  }

  if(is.null(history))
  {
    history <- list()
    class(history) <- c('query_history', 'list')
  }

  url <- paste0(base_url, ":", port)


  # health check (only run manually when debugging)
  if(FALSE)
    health_check <- paste0(url, '/health') |>
      request() |>
      req_headers('Authorization' = paste("Bearer", api_key)) |>
      req_perform()


  # build request
  prompt_w_history <- history |>
    addHistory(role = "user", item = prompt)

  sb <- cli_status("Anaconda AI Navigator is answering...")
  req <- paste0(url, '/completion') |>
    request() |>
    req_headers('Content-Type' = 'application/json') |>
    req_body_json(list(
      prompt = prompt,
      temperature = temperature,
      top_k = top_k,
      top_p = top_p,
      n_predict = n_predict,
      stop = stop
    ))

  if(!is.null(api_key)) # only add the API key if one is provided
    req <- req_headers(req, 'Authorization' = paste("Bearer", api_key))


  # submit request
  resp <- req_perform(req)
  cli_status_clear(id = sb)


  # check for errors
  if(resp$status_code != 200)
    stop("Status code ", resp$status_code)


  # return response
  response <- resp_body_json(resp)$content

  model_info <- str_split(resp_body_json(resp)$generation_settings$model, "/")[[1]]
  model <- str_split(model_info[length(model_info)], '_')[[1]][1]
  quant <- model_info[length(model_info)] |>
    str_replace(fixed(model), '') |>
    str_replace('_', '') |>
    str_replace(fixed('.gguf'), '')

  history_updt <- prompt_w_history |>
    addHistory(role = "model", item = resp)

  response <- list(response = response,
                   history = history_updt,
                   base_url = url,
                   model = model,   # model name
                   quant = quant)   # quantization method

  class(response) <- c('query_response', 'list')

  return(response)
}
