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

## ADR-0005 — No new packages for AI in research and science communication (2026-11-03)
**Decision.** aitrail and scicomm already implement these components. Missing parts (policy and disclosure corpus analysis; institutional communication) become modules of those packages after CRAN acceptance, or of a new package only if their methods become clearly distinct.

## ADR-0006 — Paper mills as a module of forsci; images from reproimage (2026-11-03)
**Decision.** As specified, paper mills start inside `forsci`. Image duplication signals are computed by reproimage, not re-implemented.

## ADR-0007 — Maintenance automation extends research-tools-ops (2026-11-03)
**Decision.** The existing reusable workflows are the base for Phase 5. AI-assisted steps (failure analysis, draft PRs) are added there, constrained by the approval table in `GOVERNANCE.md` and by CODEOWNERS.
