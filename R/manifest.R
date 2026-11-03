#' Provenance manifest for an analysis
#'
#' Records what is needed to understand and repeat an analysis: the software
#' environment, the versions of the ecosystem packages, the data sources
#' consulted (and whether they answered), the methodology versions applied,
#' checksums of input files and the known limitations. The manifest is plain
#' JSON (schema `metascience-manifest/1`), so any tool can read it.
#'
#' @param sources Data sources consulted: a data frame or a list of records
#'   with at least `source`, and optionally `ok`, `count`, `error` and
#'   `retrieved_at`. The `consulted` element returned by the collectors of
#'   openresearchmetrics and narrativecv can be passed as is.
#' @param methods Named character vector of methodology versions, for example
#'   `c("oa-publications-share" = "1.0.0")`.
#' @param inputs Paths of input files; each is recorded with its size and MD5
#'   checksum.
#' @param packages Further packages whose versions should be recorded, in
#'   addition to the ecosystem packages that are installed.
#' @param limitations Character vector of limitations to report with the
#'   results.
#' @param generated_at Timestamp (ISO 8601, UTC).
#' @return An object of class `ms_manifest` (a list).
#' @export
#' @examples
#' m <- ms_manifest(
#'   sources = list(list(source = "openalex", ok = TRUE, count = 25,
#'                       retrieved_at = "2026-11-02T00:00:00Z")),
#'   methods = c("oa-publications-share" = "1.0.0"),
#'   limitations = "OpenAlex coverage is weaker for books."
#' )
#' m
#' ms_write_manifest(m, tempfile(fileext = ".json"))
ms_manifest <- function(sources = list(), methods = character(), inputs = character(),
                        packages = character(), limitations = character(),
                        generated_at = utc_now()) {
  check_string(inputs, "inputs")
  check_string(packages, "packages")
  check_string(limitations, "limitations")
  if (length(methods) && (is.null(names(methods)) || any(!nzchar(names(methods))))) {
    stop("`methods` must be a named vector of methodology versions.", call. = FALSE)
  }
  missing <- inputs[!file.exists(inputs)]
  if (length(missing)) stop("Input file not found: ", paste(missing, collapse = ", "), call. = FALSE)

  status <- ms_status()
  status <- status[status$installed, , drop = FALSE]
  pkgs <- stats_versions(unique(c("metascience", status$r_package, packages)))

  structure(list(
    schema = "metascience-manifest/1",
    generated_at = generated_at,
    environment = list(r_version = R.version.string, platform = R.version$platform,
                       os = utils::sessionInfo()$running %||% NA_character_),
    packages = pkgs,
    sources = normalise_sources(sources),
    methods = lapply(as.list(methods), as.character),
    inputs = lapply(inputs, function(p) {
      list(path = p, bytes = unname(file.size(p)), md5 = unname(tools::md5sum(p)))
    }),
    limitations = as.list(limitations)
  ), class = "ms_manifest")
}

stats_versions <- function(pkgs) {
  out <- lapply(pkgs, function(p) {
    v <- tryCatch(as.character(utils::packageVersion(p)), error = function(e) NA_character_)
    list(package = p, version = v)
  })
  Filter(function(x) !is.na(x$version), out)
}

normalise_sources <- function(sources) {
  if (is.data.frame(sources)) {
    sources <- lapply(seq_len(nrow(sources)), function(i) as.list(sources[i, , drop = FALSE]))
  }
  if (!is.list(sources)) stop("`sources` must be a list of records or a data frame.", call. = FALSE)
  lapply(sources, function(s) {
    if (is.null(s$source)) stop("Every source needs a `source` name.", call. = FALSE)
    list(source = as.character(s$source), ok = scalar(s$ok, NA),
         count = scalar(s$count, NA), error = scalar(s$error),
         retrieved_at = scalar(s$retrieved_at))
  })
}

#' @rdname ms_manifest
#' @param manifest An object from `ms_manifest()`.
#' @param path File to write.
#' @return For `ms_write_manifest()`, `path`, invisibly.
#' @export
ms_write_manifest <- function(manifest, path) {
  if (!inherits(manifest, "ms_manifest")) stop("`manifest` must come from ms_manifest().", call. = FALSE)
  jsonlite::write_json(unclass(manifest), path, auto_unbox = TRUE, pretty = TRUE,
                       null = "null", na = "null")
  invisible(path)
}

#' @export
print.ms_manifest <- function(x, ...) {
  cat("<metascience manifest> generated ", x$generated_at, "\n", sep = "")
  cat("  ", x$environment$r_version, " on ", x$environment$platform, "\n", sep = "")
  cat("  packages: ", paste(vapply(x$packages, function(p) paste(p$package, p$version), ""),
                            collapse = ", "), "\n", sep = "")
  if (length(x$sources)) {
    cat("  sources:  ", paste(vapply(x$sources, function(s) {
      paste0(s$source, if (isFALSE(s$ok)) " (failed)" else "")
    }, ""), collapse = ", "), "\n", sep = "")
  }
  if (length(x$methods)) {
    cat("  methods:  ", paste(names(x$methods), unlist(x$methods), sep = "@", collapse = ", "), "\n", sep = "")
  }
  if (length(x$inputs)) cat("  inputs:   ", length(x$inputs), " file(s) with MD5\n", sep = "")
  if (length(x$limitations)) cat("  limitations: ", length(x$limitations), "\n", sep = "")
  invisible(x)
}
