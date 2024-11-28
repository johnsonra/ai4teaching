# check_answer.R

#' check_answer
#' Check the answer of the user
#'
#' @param question character, The question
#' @param answer character, The answer of the user
#' @param solution character, The solution of the question
#' @param preamble character, The preamble for the query
#'
#' @return character, The response from the chatbot
#' @export
check_answer <- function(question, answer, solution = NULL,
                         preamble = construct_preamble())
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

  genAI_query(query)
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
                    "If my answer is correct, please confirm.",
                    "If my answer is correct but could be better, please confirm and offer suggestions on how it could be better.",
                    "Otherwise give me feedback on my answer.",
                    "I want to know if I am on the right track.",
                    "Do not give me the answer to the question.",
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

