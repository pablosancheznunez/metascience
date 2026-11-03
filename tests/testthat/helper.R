withr_local_file <- function(env = parent.frame()) {
  path <- tempfile(fileext = ".csv")
  writeLines(c("a,b", "1,2"), path)
  do.call(on.exit, list(substitute(unlink(path)), add = TRUE), envir = env)
  path
}
