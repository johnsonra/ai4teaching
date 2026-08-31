#' dbinit
#' Initialize database for tutorial responses
#' 
#' @param db_path Path to the SQLite database
#' @param table_name Name of the table to initialize
#' 
#' @return Invisible logical indicating successful creation
#' 
#' @export
#' @importFrom DBI dbConnect dbDisconnect dbExecute dbQuoteIdentifier
#' @importFrom RSQLite SQLite
dbinit <- function(db_path = Sys.getenv("SQLITE_DB_PATH", "submissions.sqlite"),
                   table_name = "tutorial_submissions")
{
    # 1. Connect / create database file
  con <- tryCatch({
    dbConnect(SQLite(), dbname = db_path)
  }, error = function(e) {
    stop("Database connection failed during initialization: ", e$message)
  })
  
  on.exit(dbDisconnect(con), add = TRUE)

  # 2. Enable WAL mode for concurrent Shiny session access
  dbExecute(con, "PRAGMA journal_mode=WAL;")
  dbExecute(con, "PRAGMA busy_timeout=5000;") # wait up to 5s if locked

  # 3. Create table
  create_table_query <- sprintf("
    CREATE TABLE IF NOT EXISTS %s (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      student_id TEXT NOT NULL,
      question_id TEXT NOT NULL,
      submission TEXT,
      is_correct INTEGER,
      ai_feedback TEXT,
      timestamp TEXT DEFAULT (DATETIME('now'))
    );
  ", dbQuoteIdentifier(con, table_name))

  # 4. Create indexes
  create_idx_student <- sprintf(
    "CREATE INDEX IF NOT EXISTS idx_student ON %s (student_id);",
    dbQuoteIdentifier(con, table_name)
  )
  create_idx_question <- sprintf(
    "CREATE INDEX IF NOT EXISTS idx_question ON %s (question_id);",
    dbQuoteIdentifier(con, table_name)
  )

  tryCatch({
    dbExecute(con, create_table_query)
    dbExecute(con, create_idx_student)
    dbExecute(con, create_idx_question)
    message(sprintf("SQLite table '%s' initialized in '%s'.", table_name, db_path))
    invisible(TRUE)
  }, error = function(e) {
    warning("Failed to initialize SQLite table: ", e$message)
    invisible(FALSE)
  })
}
