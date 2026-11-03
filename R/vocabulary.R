#' Shared vocabularies of the ecosystem
#'
#' Controlled terms that every tool uses in the same sense:
#'
#' * `result_status`: what the sources allowed to be said about a result
#'   (`reported`, `absent_in_sources`, `unverifiable`, `not_automatable`);
#' * `evidence_level`: how strong the evidence behind an integrity-related
#'   finding is (`signal`, `pattern`, `documentary`, `established`);
#' * `ai_use_basis`: how a statement about AI use is known (`declared`,
#'   `inferred`, `verified`).
#'
#' Each term comes with its definition and with how it may be read, so that
#' reports can state the limits of a result next to the result itself.
#'
#' @param name The vocabulary; one of `ms_vocabularies()`.
#' @return For `ms_vocabulary()`, a data frame with columns `id`,
#'   `definition` and `may_be_read_as`. For `ms_vocabularies()`, the names
#'   of the vocabularies.
#' @export
#' @examples
#' ms_vocabularies()
#' ms_vocabulary("evidence_level")
ms_vocabulary <- function(name) {
  v <- vocabulary_entry(name)
  data.frame(id = vapply(v$terms, `[[`, "", "id"),
             definition = vapply(v$terms, `[[`, "", "definition"),
             may_be_read_as = vapply(v$terms, `[[`, "", "may_be_read_as"),
             stringsAsFactors = FALSE)
}

#' @rdname ms_vocabulary
#' @export
ms_vocabularies <- function() names(extdata_json("vocabularies.json")$vocabularies)

vocabulary_entry <- function(name) {
  if (!is.character(name) || length(name) != 1L) stop("`name` must be a single string.", call. = FALSE)
  v <- extdata_json("vocabularies.json")$vocabularies[[name]]
  if (is.null(v)) {
    stop("Unknown vocabulary '", name, "'. Available: ",
         paste(ms_vocabularies(), collapse = ", "), ".", call. = FALSE)
  }
  v
}

#' Harmonise result statuses across tools
#'
#' Each tool reports results in its own terms (for example `computed` in
#' openresearchmetrics or `not_found_in_sources` in narrativecv). This function
#' translates them to the common `result_status` vocabulary so that results
#' from several tools can be combined in one table without reading an
#' unverifiable result as a negative one.
#'
#' @param status A character vector of statuses as reported by `tool`.
#' @param tool The tool that produced them; one of the names of
#'   `ms_status_mappings()`.
#' @return A character vector of common statuses. An unknown status is an
#'   error, never silently mapped.
#' @export
#' @examples
#' ms_harmonise_status(c("found", "not_found_in_sources", "source_unavailable"),
#'                     tool = "narrativecv")
#' ms_status_mappings()
ms_harmonise_status <- function(status, tool) {
  check_string(status, "status")
  maps <- vocabulary_entry("result_status")$mappings
  if (!is.character(tool) || length(tool) != 1L || is.null(maps[[tool]])) {
    stop("`tool` must be one of: ", paste(names(maps), collapse = ", "), ".", call. = FALSE)
  }
  map <- unlist(maps[[tool]])
  unknown <- setdiff(unique(status[!is.na(status)]), names(map))
  if (length(unknown)) {
    stop("Unknown ", tool, " status: ", paste(unknown, collapse = ", "), ".", call. = FALSE)
  }
  out <- unname(map[status])
  out[is.na(status)] <- NA_character_
  out
}

#' @rdname ms_harmonise_status
#' @return For `ms_status_mappings()`, a data frame with columns `tool`,
#'   `status` and `common_status`.
#' @export
ms_status_mappings <- function() {
  maps <- vocabulary_entry("result_status")$mappings
  rows <- lapply(names(maps), function(t) {
    m <- unlist(maps[[t]])
    data.frame(tool = t, status = names(m), common_status = unname(m), stringsAsFactors = FALSE)
  })
  do.call(rbind, rows)
}
