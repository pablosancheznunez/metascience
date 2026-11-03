# Development standards

These describe how the existing packages are already built (narrativecv, academiccareer, aitrail, scicomm, reproimage), so that new packages look and behave the same.

## Package structure
- Standard R package; when a web tool exists, the R package lives in `r/` of the same repository and shares its data files byte for byte (CI compares them).
- `R/<pkg>-package.R` with `"_PACKAGE"`; one file per concern (`connectors.R`, `engine.R`, `report.R`, `utils.R`).
- Versioned data (catalogues, crosswalks, vocabularies) in `inst/extdata/*.json`, each with its own version field.

## Naming
- Every exported function has a short package prefix: `ms_`, `orm_`, `nc_`, `ac_`, `ait_`, `sc_`, `ri_`. New: `fs_` (forsci), `rr_` (researchreproducibility).
- snake_case; British spelling in prose (`Language: en-GB`); functions that normalise API responses are `<prefix>_normalise_<source>()` in new code.

## Dependencies
- Base R plus `jsonlite`; `curl` only when the package calls APIs. Anything else needs a reason in the PR.
- No hard dependency on a package that is not on CRAN. Ecosystem packages are referenced through `Suggests` and `requireNamespace()` only after they are published.

## Results and errors
- Pure functions for computation: same input, same output. Network access only in `*_collect()` functions; a failing source is recorded, never fatal.
- Use the shared statuses (`ms_vocabulary("result_status")`). Never return 0 or `FALSE` for something that could not be verified.
- Integrity findings carry an `evidence_level`; AI-use statements carry an `ai_use_basis`.
- Errors: `stop(..., call. = FALSE)` with a message that says what to pass instead.

## Testing
- `testthat` edition 3, offline by default with recorded API responses in `inst/extdata/examples/` or `tests/testthat/fixtures/`.
- Every method has a regression test against a stored expected output. Expected outputs are regenerated only by a person.
- Live API contract tests run weekly in CI, never in `R CMD check`.

## Documentation
- roxygen2 with markdown; every export has an example that runs offline.
- README states the maturity level (implemented / implemented_not_validated / prototype / planned / blocked).
- `CITATION.cff` with Zenodo concept DOI; `NEWS.md` per release.

## Versioning and API stability
- Semantic versioning. Development versions end in `.9000`.
- Methodology versions are separate from package versions: a changed definition is a new methodology version, bound to new code; old versions stay computable.
- Breaking changes need a deprecation cycle of one minor release.

## Release
- `R CMD check --as-cran` with no errors or warnings on Linux (devel, release, oldrel-1), Windows and macOS.
- CRAN submission is always confirmed by the maintainer by email (cannot be automated). After acceptance, `research-tools-ops/cran-watch.yml` watches the package weekly.
- A package submitted to CRAN is frozen until CRAN decides.

## CI template
`templates/ci-r-package.yml` is the workflow every package copies; it is the same matrix the existing packages use.
