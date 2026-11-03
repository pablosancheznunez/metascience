#' Validate and normalise persistent identifiers
#'
#' Each function accepts identifiers as typed by people or returned by APIs
#' (bare, with a prefix such as `doi:`, or as a resolver URL) and returns the
#' canonical bare form, or `NA` when the input is not a valid identifier. They
#' are vectorised and never call the network: a valid identifier is
#' well-formed, which does not prove that it is registered.
#'
#' * `ms_doi()`: lower-cased `10.xxxx/suffix`. DOIs are case-insensitive.
#' * `ms_orcid()`: `0000-0000-0000-000X`, with the ISO 7064 MOD 11-2 check
#'   digit verified.
#' * `ms_ror()`: the nine-character ROR ID, with its ISO 7064 MOD 97-10 check
#'   digits verified.
#'
#' @param x A character vector.
#' @param url If `TRUE`, return the resolver URL instead of the bare form.
#' @return A character vector the length of `x`.
#' @export
#' @examples
#' ms_doi(c("https://doi.org/10.5281/ZENODO.23881633", "doi:10.1000/xyz", "nope"))
#' ms_orcid(c("https://orcid.org/0000-0002-1825-0097", "0000-0002-1825-0098"))
#' ms_ror("https://ror.org/03ths8210")
#' ms_ror("03ths8210", url = TRUE)
ms_doi <- function(x, url = FALSE) {
  check_string(x, "x")
  s <- tolower(trimws(x))
  s <- sub("^(https?://)?(dx\\.)?doi\\.org/", "", s)
  s <- sub("^doi:\\s*", "", s)
  # Resolver URLs often percent-encode the suffix.
  s <- vapply(s, function(v) tryCatch(utils::URLdecode(v), error = function(e) v), "",
              USE.NAMES = FALSE)
  ok <- !is.na(s) & grepl("^10\\.[0-9]{4,9}/\\S+$", s)
  s[!ok] <- NA_character_
  if (url) s[ok] <- paste0("https://doi.org/", s[ok])
  s
}

#' @rdname ms_doi
#' @export
ms_orcid <- function(x, url = FALSE) {
  check_string(x, "x")
  s <- toupper(trimws(x))
  s <- sub("^(HTTPS?://)?(WWW\\.)?ORCID\\.ORG/", "", s)
  s <- gsub("^([0-9]{4})([0-9]{4})([0-9]{4})([0-9]{3}[0-9X])$", "\\1-\\2-\\3-\\4", s)
  ok <- !is.na(s) & grepl("^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]$", s)
  ok[ok] <- vapply(s[ok], orcid_checksum_ok, TRUE)
  s[!ok] <- NA_character_
  if (url) s[ok] <- paste0("https://orcid.org/", s[ok])
  s
}

orcid_checksum_ok <- function(id) {
  digits <- strsplit(gsub("-", "", id, fixed = TRUE), "")[[1]]
  total <- 0
  for (d in digits[1:15]) total <- (total + as.integer(d)) * 2
  check <- (12 - total %% 11) %% 11
  identical(digits[16], if (check == 10) "X" else as.character(check))
}

#' @rdname ms_doi
#' @export
ms_ror <- function(x, url = FALSE) {
  check_string(x, "x")
  s <- tolower(trimws(x))
  s <- sub("^(https?://)?(www\\.)?ror\\.org/", "", s)
  ok <- !is.na(s) & grepl("^0[0-9a-hjkmnp-tv-z]{6}[0-9]{2}$", s)
  ok[ok] <- vapply(s[ok], ror_checksum_ok, TRUE)
  s[!ok] <- NA_character_
  if (url) s[ok] <- paste0("https://ror.org/", s[ok])
  s
}

# Crockford base32 of the first seven characters; the last two are
# 98 - (n * 100 mod 97).
ror_checksum_ok <- function(id) {
  alphabet <- strsplit("0123456789abcdefghjkmnpqrstvwxyz", "")[[1]]
  n <- 0
  for (ch in strsplit(substr(id, 1, 7), "")[[1]]) n <- n * 32 + match(ch, alphabet) - 1
  identical(sprintf("%02d", 98 - (n * 100) %% 97), substr(id, 8, 9))
}

#' Recognise the type of persistent identifiers
#'
#' @param x A character vector of identifiers in any common form.
#' @return A data frame with columns `input`, `type` (`"doi"`, `"orcid"`,
#'   `"ror"` or `NA`) and `id` (the normalised identifier).
#' @export
#' @examples
#' ms_identify(c("10.5281/zenodo.23881631", "0000-0002-1825-0097",
#'               "https://ror.org/03ths8210", "not an identifier"))
ms_identify <- function(x) {
  check_string(x, "x")
  ids <- list(doi = ms_doi(x), orcid = ms_orcid(x), ror = ms_ror(x))
  type <- rep(NA_character_, length(x))
  id <- rep(NA_character_, length(x))
  for (t in names(ids)) {
    hit <- is.na(type) & !is.na(ids[[t]])
    type[hit] <- t
    id[hit] <- ids[[t]][hit]
  }
  data.frame(input = x, type = type, id = id, stringsAsFactors = FALSE)
}
