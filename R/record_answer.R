#' record_answer
#' Record answers when submitted in a learnr tutorial
#' 
#' @param record A data.frame containing `student_id`, `question_id`, `submission`, `is_correct`, `ai_feedback` and `timestamp`
#' @param db_path Path to the SQLite database
#' @param table_name Name of the table to add the data to
#' 
#' @details Assumes there is a correctly formatted database at `db_host`
#' @return Invisibly returns `TRUE` upon successful completion
#' 
#' @export
#' @importFrom DBI dbConnect dbDisconnect dbWriteTable
#' @importFrom dplyr mutate
#' @importFrom RMariaDB MariaDB
record_answer <- function(record,
                          db_path = Sys.getenv("SQLITE_DB_PATH", "submissions.sqlite"),
                          table_name = "tutorial_submissions")
{
  con <- tryCatch({
    dbConnect(RSQLite::SQLite(), dbname = db_path)
  }, error = function(e) {
    warning("SQLite connection failed: ", e$message)
    return(NULL)
  })

  if (is.null(con)) return(invisible(FALSE))
  on.exit(dbDisconnect(con), add = TRUE)

  # Process data for recording
  encrypted_record <- mutate(record,
                             submission = encrypt_text(submission),
                             is_correct = as.integer(is_correct), # this is stored as an integer in the db file
                             ai_feedback = encrypt_text(ai_feedback))

  # Set busy timeout so concurrent student writes queue instead of failing
  dbExecute(con, "PRAGMA busy_timeout=5000;")

  tryCatch({
    dbWriteTable(
      conn      = con,
      name      = table_name,
      value     = record,
      append    = TRUE,
      row.names = FALSE
    )
    invisible(TRUE)
  }, error = function(e) {
    warning("Failed to write submission record to SQLite: ", e$message)
    invisible(FALSE)
  })
}
