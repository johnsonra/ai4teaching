#' addHistory
#' Add history for chating context
#'
#' @param history The history of chat
#' @param role The role of chat: "user" or "model"
#' @param item The item of chat: "prompt" or "output"
#'
#' @description Add history for chatting context
#'
#' @return The history of chat
addHistory <- function(history, role, item)
{
  history[[length(history) + 1]] <-
    list(
      role = role,
      parts = list(list(text = item))
    )

  return(history)
}
