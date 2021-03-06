unarchive_asgmts <- function(ids = NULL, # assignment ID, can be vector
                             server, # server prefix
                             user, # API user username
                             password) # password for API user
{
  # -------------------------------------------------------------
  # Load all necessary functions and require packages
  # -------------------------------------------------------------

  load_pkg <- function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, repos = 'https://cloud.r-project.org/', dep = TRUE)
    }
    require(x, character.only = TRUE)
  }

  load_pkg('dplyr')
  load_pkg('jsonlite')
  load_pkg('httr')

  # -------------------------------------------------------------
  # CHECK ALL INPUTS
  # -------------------------------------------------------------

  # check that server, login, password, and data type are non-missing
  for (x in c("server", "user", "password")) {
    if (!is.character(get(x))) {
      stop(x, "has to be a string.")
    }
    if (nchar(get(x)) == 0) {
      stop(paste("The following parameter is not specified in the program:", x))
    }
  }

  # check if assignment IDs were provided
  if (is.null(ids)){
    stop("Assignment IDs to unarchive need to be specified.")
  }

  # check if all assignment IDs are numeric
  if (sum(sapply(suppressWarnings({as.numeric(ids)}), is.na)) > 0){
    stop("Assignment IDs must be a number.")
  } else {
    # if all are numeric, convert to numeric vector
    ids <- as.numeric(ids)
  }

  # -------------------------------------------------------------
  # Send API request
  # -------------------------------------------------------------

  # build base URL for API
  server <- tolower(trimws(server))

  # check server exists
  server_url <- paste0("https://", server, ".mysurvey.solutions")

  # Check server exists
  tryCatch(httr::http_error(server_url),
           error=function(err) {
             err$message <- paste(server, "is not a valid server.")
             stop(err)
           })

  # build base URL for API
  api_url <- paste0(server_url, "/api/v1")

  # function archive one assignment
  unarchive_id <- function(x, url=api_url){
    # build api endpoint
    endpoint <- paste0(url, "/assignments/", x, '/unarchive')

    resp <- httr::PATCH(endpoint, authenticate(user, password))

    if (httr::status_code(resp)==200){
      message("Successfully unarchived assignment #", x)
    } else if (httr::status_code(resp)==401){
      stop("Invalid login or password.")
    } else {
      message("Error archiving assignment #", x)
    }
  }

  # unarchive all assignments in list
  # invisible to prevent sapply from printing to console
  invisible(sapply(ids, unarchive_id))
}
