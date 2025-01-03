# check_answer.R

#' check_answer
#' Check the answer of the user
#'
#' @param question character, The question
#' @param answer character, The answer of the user
#' @param solution character, The solution of the question
#' @param preamble character, The preamble for the query
#' @param ... variables passed on to `genAI_query` (e.g. `model` or `api_key`)
#'
#' @return An object from learnr::correct() or learnr::incorrect()
#'
#' @export
#' @importFrom learnr correct incorrect
#' @importFrom stringr str_extract str_replace
check_answer <- function(question, answer, solution = NULL,
                         preamble = construct_preamble(), ...)
{
  query <- paste(preamble,
        paste("Question:", question),
        paste("Answer:", answer),
        sep = '\n')

  if(!is.null(solution))
  {
    query <- paste(query,
                   paste("Solution:", solution),
                   sep = '\n')
  }

  retval <- genAI_query(query, ...)$response

  if(str_extract(retval, "^\\w+") == "Correct")
  {
    retval <- str_replace(retval, "^Correct\\.?", "") |>
      trimws() |>
      correct()
  }else{
    retval <- str_replace(retval, "^Incorrect\\.?", "") |>
      trimws() |>
      incorrect()
  }

  return(retval)
}


#' construct_preamble
#' Construct the preamble for the query
#'
#' @param course character, The course title
#' @param altPreamble character, An alternative preamble to the default
#'
#' @return character, The preamble for the query
#' @examples
#' construct_preamble()
#' construct_preamble('Data Science')
#' construct_preamble('Data Science', 'Is this correct? If not, just give me the answer.')
#' @export
construct_preamble <- function(course = NULL, altPreamble = NULL)
{
  if(is.null(altPreamble))
  {
    retval <- paste("I'm taking a quiz.",
                    "Let me know if my answer is correct.",
                    'If my answer is correct, please begin your response with "Correct".',
                    "If my answer is correct but could be better, please confirm and offer suggestions on how it could be better.",
                    "If my answer in incorrect, please give me feedback without giving me the answer.",
                    "Keep your feedback brief and to the point - lets say 1-2 sentences.")
  }else{
    retval <- altPreamble
  }

  if(!is.null(course))
  {
    retval <- paste0("I am in a course titled ", course, '. ', retval)
  }

  return(retval)
}

