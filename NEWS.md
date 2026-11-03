# metascience 0.0.0.9000

* `ms_app()`: Shiny interfaces with a module per ecosystem tool.
* Design system in `inst/design/` (tokens with light and dark themes, logo)
  and a portal built from the catalogue (`site/build.R`).

* First version: ecosystem catalogue (`ms_catalogue()`, `ms_status()`),
  persistent identifiers (`ms_doi()`, `ms_orcid()`, `ms_ror()`,
  `ms_identify()`), shared vocabularies and status harmonisation
  (`ms_vocabulary()`, `ms_harmonise_status()`) and provenance manifests
  (`ms_manifest()`).
