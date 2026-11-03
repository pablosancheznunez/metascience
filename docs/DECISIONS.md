# Architectural decisions

## ADR-0001 — Frozen packages are integrated by reference (2026-11-03)
**Context.** Ten R packages are in CRAN's incoming queue; the maintainer forbids modifying any package sent to CRAN.
**Decision.** `metascience` lists them in its catalogue, maps their result statuses and documents deferred changes, but neither edits nor depends on them. `metascience` has no `Suggests` on packages not yet on CRAN, so its own check never depends on CRAN's decisions.
**Consequence.** Duplicated helpers (ORCID validation, normalisers) remain in frozen packages until their next release.

## ADR-0002 — Hub package instead of a meta-package (2026-11-03)
**Alternatives.** (a) tidyverse-style meta-package that attaches all tools; (b) monorepo; (c) small hub with catalogue and shared foundation.
**Decision.** (c). A meta-package would force every tool's dependencies on every user and couple their releases; a monorepo would break the existing repositories, DOIs and CRAN links.

## ADR-0003 — No server, database or authentication yet (2026-11-03)
**Context.** The specification lists Plumber, PostgreSQL, Docker and shared authentication.
**Decision.** Not introduced. The web tools run entirely in the browser against open APIs, which needs no server, stores no personal data and costs nothing. Shiny apps (Phase 4) are added per tool, deployable with Docker when a host is chosen. A database is introduced only when a tool must store user data or large shared datasets; Parquet files on Zenodo come first.

## ADR-0004 — OpenResearchMetrics R package mirrors the web engine (2026-11-03)
**Decision.** The JavaScript engine stays the reference. The R package bundles byte-identical copies of the catalogue, recorded responses and expected report; its test requires an identical report; CI fails on drift.
**Consequence.** A methodology change needs both implementations updated in one PR, reviewed by the maintainer.

## ADR-0005 — No new package for science communication; aiinresearch for corpus-level AI analysis (2026-11-03, revised the same day)
**Decision.** scicomm implements science communication evaluation; no `scicom` package. For AI in research, aitrail covers project-level logging, verification and disclosure writing. The analysis of disclosures across publications and of AI policies turned out to be a different method on a different unit (corpora of articles and policies, not one team's log), and aitrail is frozen while CRAN reviews it, so it lives in a new package, `aiinresearch`, prefix `air_`.
**Consequence.** The two packages share the `ai_use_basis` vocabulary; aiinresearch measures only declared use and never infers AI authorship.

## ADR-0006 — Paper mills as a module of FoSci; images from reproimage (2026-11-03)
**Decision.** As specified, paper mills start inside `FoSci`. Image duplication signals are computed by reproimage, not re-implemented.

## ADR-0008 — Portal generated from the catalogue; one Shiny app with a module per tool (2026-11-03)
**Context.** Phase 4 asks for a public portal and analytical interfaces that feel like one platform while each tool evolves independently.
**Decision.** The portal is a static page built by `site/build.R` from `inst/extdata/catalogue.json` and published to GitHub Pages on every change to main, so the website cannot disagree with `ms_catalogue()`. The interfaces are one Shiny app, `ms_app()`, with one module (UI + server pair) per tool in `R/app.R`. Modules call their package by name only when it is installed, so no tool becomes a dependency of metascience and a missing tool shows install instructions instead of breaking the app. Shiny is a suggested package. The existing browser tools (OpenResearchMetrics, Narrative CV Crosswalk) stay where they are and are linked, not rebuilt.
**Alternatives.** A Shiny app per repository (more deployments to maintain, no shared navigation); a JavaScript front end with a Plumber API (a server to run and secure, which ADR-0003 avoids until needed).
**Consequence.** Deploying the app online needs a Shiny host (shinyapps.io, Posit Connect or a container); until one is chosen the app runs locally with `ms_app()`.

## ADR-0007 — Maintenance automation extends research-tools-ops (2026-11-03)
**Decision.** The existing reusable workflows are the base for Phase 5. AI-assisted steps (failure analysis, draft PRs) are added there, constrained by the approval table in `GOVERNANCE.md` and by CODEOWNERS.
