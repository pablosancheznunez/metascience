`%||%` <- function(a, b) if (is.null(a) || length(a) == 0L) b else a

extdata_json <- function(file) {
  path <- system.file("extdata", file, package = "metascience")
  if (!nzchar(path)) stop("Missing data file: ", file, call. = FALSE)
  jsonlite::read_json(path, simplifyVector = FALSE)
}

utc_now <- function() format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

# NULL and empty values become NA so that list records bind into data frames.
scalar <- function(x, na = NA_character_) {
  if (is.null(x) || length(x) == 0L) na else x
}

check_string <- function(x, arg) {
  if (!is.character(x)) stop("`", arg, "` must be a character vector.", call. = FALSE)
  invisible(x)
}
