#' metascience: catalogue and shared infrastructure for open metascience tools
#'
#' The package is the hub of a set of independent tools that study research.
#' It does not re-implement them: it tells you what exists ([ms_catalogue()]),
#' what is installed ([ms_status()]), and gives every tool the same small
#' foundation:
#'
#' * persistent identifiers: [ms_doi()], [ms_orcid()], [ms_ror()],
#'   [ms_identify()];
#' * one vocabulary for result statuses and evidence levels:
#'   [ms_vocabulary()], [ms_harmonise_status()];
#' * provenance: [ms_manifest()] and [ms_write_manifest()].
#'
#' Two rules run through the whole ecosystem. A result that cannot be verified
#' from the sources consulted is reported as unverifiable, never as zero or
#' "no". And a statistical signal is never presented as proof: anomalies,
#' inferred AI use and similar findings carry their evidence level.
#'
#' @keywords internal
"_PACKAGE"
