# Architecture and roadmap

## Principles

1. **Packages are the engines.** Every analysis lives in an R package usable on its own. Web interfaces call packages; they never contain methods.
2. **Hub, not monolith.** `metascience` holds the catalogue and the small shared foundation. It never re-exports or wraps the tools, so a tool can be released, frozen or retired without touching the others.
3. **One method, one place.** A method is implemented once. When the web tool and the R package both need it (OpenResearchMetrics, narrativecv), one is the reference and the other is tested against the same recorded inputs and expected outputs.
4. **Simplest infrastructure that works.** Static sites on GitHub Pages, JSON/CSV files, GitHub Actions. No database, server or authentication until a requirement needs them (see ADR-0003).

## Layers

```
            metascience portal (static site: catalogue, docs, methods)
                     │ links / embeds
   ┌─────────────────┼──────────────────────────────┐
   web tools (static JS, run in the browser)   Shiny apps (Phase 4, per tool)
   ORM · narrative CV crosswalk                     │
                     │ same catalogues, same expected outputs
   ┌─────────────────┴──────────────────────────────┐
   R packages:  openresearchmetrics · narrativecv · academiccareer · aitrail
                scicomm · reproimage · FoSci · researchreproducibility · aiinresearch
                     │ depend on (new code only)
                metascience: catalogue · identifiers · vocabularies · manifest
                     │
   open sources: OpenAlex · Crossref · DataCite · ORCID · ROR · OpenAIRE · PubMed · Unpaywall
   ───────────────────────────────────────────────────────────────────
   research-tools-ops: CI templates · CRAN watch · releases · AI-assisted maintenance (Phase 5)
                                                               * planned
```

## Repository structure (decided)

| Repository | Status | Why |
| --- | --- | --- |
| `metascience` | new (local, not yet on GitHub) | Catalogue, shared foundation, ecosystem docs and, later, the portal source. |
| `openresearchmetrics` | existing; `r/` added | Same pattern as narrativecv and reproimage: web tool and R package side by side. |
| `narrative-cv-crosswalk`, `academiccareer`, `aitrail`, `scicomm`, `reproimage` | existing, frozen | Unchanged. |
| `FoSci` | new (local) | Distinct methods, distinct ethical safeguards: its own package. Paper mills as a module inside. |
| `researchreproducibility` | new (local) | Extracted from repro2impact's detectors. |
| `research-tools-ops` | existing | Extended in Phase 5. |

**Not created**, to avoid empty repositories (rule 13): `metascience-web` (the portal starts in `metascience/site` and moves out only if it grows a build of its own), `metascience-docs` (docs live here), `metascience-data` and `metascience-benchmarks` (cases live in each package's tests until at least two packages share one), `aiinresearch` and `scicom` (aitrail and scicomm fill them). A GitHub organisation is not needed while one person maintains everything; moving repositories later keeps redirects.

## Roadmap with status

| Phase | Deliverable | Status |
| --- | --- | --- |
| 0 | Audit and integration plan (`docs/AUDIT.md`) | Implemented |
| 1 | `metascience` package: catalogue, identifiers, vocabularies, manifest | Implemented, tested, R CMD check clean (1 expected NOTE) |
| 1 | OpenResearchMetrics R package | Prototype: identical report to the web tool on the regression case; on branch `r-package`, not pushed |
| 1 | Standards, governance, ADRs | Implemented (documents) |
| 1 | CI for metascience | Implemented, not yet run on GitHub (repository not created) |
| 1 | Portal foundation | Superseded by Phase 4 portal |
| 2 | FoSci with paper mills module | Prototype: 66 tests, R CMD check clean (1 expected NOTE); validated on simulated benchmark only |
| 2 | researchreproducibility | Prototype: 66 tests, R CMD check clean (1 expected NOTE); detectors identical to repro2impact 1.1.0 |
| 3 | aiinresearch: AI disclosures in articles and AI policies | Prototype: 53 tests, R CMD check clean (expected NOTEs); synthetic validation only |
| 3 | Research assessment integration (shared vocabulary) | Started: `ms_harmonise_status()` |
| 4 | Portal built from the catalogue (`site/build.R`, GitHub Pages workflow) | Implemented; publishing needs GitHub Pages enabled on the repository |
| 4 | `ms_app()`: one Shiny app, modules for openresearchmetrics, FoSci, aiinresearch, scicomm, researchreproducibility | Prototype: module servers tested with shiny::testServer; runs locally, not deployed online |
| 4 | Design system (`inst/design/`: tokens, light/dark, logo) | Implemented |
| 5 | Ecosystem health report (weekly, all repositories) in research-tools-ops | Implemented; tested offline and against live data |
| 5 | Failure triage with optional Claude diagnosis, risk from CODEOWNERS, issues only | Implemented, not yet exercised by a real failure; AI part needs the `ANTHROPIC_API_KEY` secret |
| 5 | Draft pull requests for routine fixes | Planned: proposals stay in issues until the triage has a track record |
| 6 | Software papers (JOSS/rOpenSci review), benchmarks, reports | Planned |
| – | Changes to frozen packages | Blocked by CRAN review |
