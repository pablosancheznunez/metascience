#' Catalogue of the metascience ecosystem
#'
#' Lists the tools of the ecosystem with their research domain, maturity and
#' release status. Maturity uses five levels, so that a prototype is never
#' presented as a finished product: `implemented`, `implemented_not_validated`,
#' `prototype`, `planned` and `blocked`.
#'
#' A component with `frozen = TRUE` has been submitted to CRAN and is not
#' changed while CRAN reviews it; the ecosystem integrates it by reference.
#'
#' @param domain Optional domain id(s) to keep; see `ms_domains()`.
#' @param maturity Optional maturity level(s) to keep.
#' @return A data frame with one row per component.
#' @export
#' @examples
#' ms_catalogue()
#' ms_catalogue(domain = "science_of_science")
#' ms_catalogue(maturity = "planned")
ms_catalogue <- function(domain = NULL, maturity = NULL) {
  cat_ <- extdata_json("catalogue.json")
  rows <- lapply(cat_$components, function(x) {
    data.frame(
      id = x$id, name = x$name, domain = x$domain,
      kind = paste(unlist(x$kind), collapse = ", "),
      maturity = x$maturity, cran = x$cran, frozen = isTRUE(x$frozen),
      r_package = scalar(x$r_package), doi = scalar(x$doi),
      repository = scalar(x$repository), url = scalar(x$url),
      role = x$role, stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  if (!is.null(domain)) {
    unknown <- setdiff(domain, ms_domains()$id)
    if (length(unknown)) stop("Unknown domain: ", paste(unknown, collapse = ", "), call. = FALSE)
    out <- out[out$domain %in% domain, , drop = FALSE]
  }
  if (!is.null(maturity)) {
    unknown <- setdiff(maturity, names(cat_$maturity_levels))
    if (length(unknown)) stop("Unknown maturity level: ", paste(unknown, collapse = ", "), call. = FALSE)
    out <- out[out$maturity %in% maturity, , drop = FALSE]
  }
  rownames(out) <- NULL
  out
}

#' @rdname ms_catalogue
#' @export
ms_domains <- function() {
  d <- extdata_json("catalogue.json")$domains
  data.frame(id = vapply(d, `[[`, "", "id"), name = vapply(d, `[[`, "", "name"),
             question = vapply(d, `[[`, "", "question"), stringsAsFactors = FALSE)
}

#' @rdname ms_catalogue
#' @return For `ms_outside_scope()`, the projects deliberately kept outside the
#'   ecosystem and the reason.
#' @export
ms_outside_scope <- function() {
  o <- extdata_json("catalogue.json")$outside_scope
  data.frame(id = vapply(o, `[[`, "", "id"), reason = vapply(o, `[[`, "", "reason"),
             stringsAsFactors = FALSE)
}

#' Which ecosystem packages are installed
#'
#' Reports, for every component that is an R package, whether it is installed
#' and which version. Nothing is installed or loaded.
#'
#' @param lib.loc Library paths to search, as in [utils::packageVersion()].
#' @return A data frame with columns `id`, `r_package`, `maturity`,
#'   `installed` and `version`.
#' @export
#' @examples
#' ms_status()
ms_status <- function(lib.loc = NULL) {
  cat_ <- ms_catalogue()
  cat_ <- cat_[!is.na(cat_$r_package), c("id", "r_package", "maturity"), drop = FALSE]
  version <- vapply(seq_len(nrow(cat_)), function(i) {
    if (cat_$maturity[i] == "planned") return(NA_character_)
    tryCatch(as.character(utils::packageVersion(cat_$r_package[i], lib.loc = lib.loc)),
             error = function(e) NA_character_)
  }, "")
  cat_$installed <- !is.na(version)
  cat_$version <- version
  rownames(cat_) <- NULL
  cat_
}
