# print.R

#' print.gemini_response
#' Print method for the response from `gemini_query`
#'
#' @param x object, The response from the chatbot
#' @param ... additional arguments
#'
#' @return NULL
#' @export
print.gemini_response <- function(x, ...)
{
  cat(x$response, ...)
  invisible(NULL)
}
