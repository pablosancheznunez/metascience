# Phase 0 audit

Date: 2026-11-03. Method: every repository of `github.com/pablosancheznunez` (17) and its local clone in `C:\Users\psanc\Desktop\R` were inspected (DESCRIPTION, NAMESPACE, source, tests, CI, CITATION.cff). CRAN status was read from CRAN's public incoming queue on the same day.

## 1. The hard constraint: what is frozen

All ten R packages prepared in `cran-submissions/` are in CRAN's `incoming/newbies` queue, none is published yet. **They are not modified** while CRAN reviews them; Metascience integrates them by reference (catalogue, vocabulary mappings, links), never by editing them.

| Package | Repository | CRAN | Frozen | In Metascience |
| --- | --- | --- | --- | --- |
| narrativecv 0.1.0 | narrative-cv-crosswalk (`r/`) | submitted | yes | yes |
| academiccareer 0.1.0 | academiccareer | submitted | yes | yes |
| aitrail 0.1.0 | aitrail | submitted | yes | yes |
| scicomm 0.1.0 | scicomm | submitted | yes | yes |
| reproimage 0.1.0 | reproimage (`r/`) | submitted | yes | yes |
| photoarchive 0.2.0 | photoarchive | submitted | yes | no |
| abfunnel 0.1.0 | abfunnel | submitted | yes | no |
| neuroconsumer, uxlearn, visualbrief | – | submitted | yes | no (excluded by you) |

Changes a frozen package will need later (only after CRAN accepts it, as a new version) are listed in section 5 so that nothing is lost.

## 2. What exists, verified against the code

### OpenResearchMetrics — *not* an R package
The specification describes `openresearchmetrics` as an R package. **It was a JavaScript web tool only** (`src/engine.js`, `src/connectors.js`, `data/indicators.json`), with no R code.

- Nine indicators in five families (availability, accessibility, reuse, declared reproducibility, methodological transparency), each a versioned card with definition, numerator, denominator, sources and limitations. No composite score.
- Engine binds every card to the procedure of its exact `methodology_version`; a card without a procedure is refused.
- Tests: catalogue, engine, connectors, a recorded regression report (ORCID test record) and live API contract tests; JSON Schema validation.
- Quality: high. Pure functions, explicit `unverifiable` status, CODEOWNERS on high-risk paths, DOI 10.5281/zenodo.23881633.
- Missing: an R interface (now added, see Phase 1), institutional and comparative analysis, uncertainty reporting, field normalisation.

### narrativecv (in narrative-cv-crosswalk)
- R package + web tool. Maps R4RI and Spanish CVA sections to evidence in ORCID, OpenAlex, DataCite and OpenAIRE through a versioned crosswalk (`mappings.json`). Five section statuses, including `not_found_in_sources` (never "absent") and `no_automated_source`.
- 16 exports, 542 lines, tests against shared expected reports with the JS tool. Imports only curl and jsonlite.
- Quality: high. Missing: ROR affiliations, DataCite/ORCID for funding outputs, more frameworks (CoARA, DORA-aligned institutional templates).

### academiccareer
- Descriptive career profiles (timeline, contributions, transitions, context) from ORCID, OpenAlex and DataCite, plus user-supplied evidence. No ranking or score. 16 exports, 1,096 lines.
- **Overlap** with narrativecv: both normalise ORCID, OpenAlex and DataCite with their own normalisers (`nc_normalize_*` vs `ac_normalise_*`) and both validate ORCID iDs. Kept separate (different questions), but the shared parts move to `metascience` for new code.

### aitrail — fills "AI in Research" (B1) for project-level use
- AI-use log by project phase (12-phase vocabulary, English/Spanish), human verification, oversight audit rules, reference checks against Crossref/DataCite, disclosure statements. 13 exports.
- Covers *declared* and *verified* use. Missing for B1: analysis of journal/institutional AI policies and of disclosures across publications (*inferred* use must be labelled as such).
- **Decision:** no new `aiinresearch` package now. aitrail is the AI-in-research component; the policy/disclosure corpus analysis is a planned module.

### scicomm — fills "Scientific Communication Evaluation" (B2)
- Fidelity of each audience version against the finding, readability, accessibility, clarity, uncertainty language, English and Spanish lexicons. 13 exports.
- **Decision:** no new `scicom` package. scicomm is the component; future work (institutional communication, dissemination tracking) extends it after CRAN acceptance.

### reproimage — feeds forensic scientometrics and reproducibility
- Exact, pixel and perceptual duplicate detection in eight orientations, RO-Crate provenance, R and Python. Reference image set with expected results.
- **Decision:** image-integrity signals for paper mills are *not* re-implemented in `FoSci`; FoSci will call reproimage.

### repro2impact — research project, seed of the reproducibility package
- `targets` pipeline with versioned transparency detectors (`detector_version 1.1.0`: data, code, materials, preregistration, availability statements), protocol, preregistration, codebook, analyses with E-values and DiD.
- Not a package. Its detectors are the most reusable part and the seed of `researchreproducibility`.

### research-tools-ops — Phase 5 already partly exists
- Reusable workflows: weekly CRAN check watch (opens issues, creates releases, Zenodo DOIs) and monthly auto-release for non-CRAN tools. Every project has its own CI with weekly runs against new dependencies; CODEOWNERS gates high-risk paths.
- **Decision:** extend this repository for AI-assisted maintenance instead of building a parallel system.

### Out of scope (kept fully independent)
neuroconsumer, uxlearn, visualbrief (your instruction); abfunnel (marketing experiments), photoarchive (photographic heritage), ixd-lab (interaction design teaching), synthviscom (visual communication dataset) — none studies research itself. synthviscom's design (synthetic data with known effects, data descriptor, checksums) is the model for the benchmarks.

## 3. Map of the requested architecture onto what exists

| Requested component | Exists as | Action |
| --- | --- | --- |
| A1 OpenResearchMetrics | JS web tool | **Done in Phase 1:** R package in `openresearchmetrics/r` (prototype). Extend later. |
| A2 NarrativeCV | narrativecv + academiccareer | Integrate by reference (frozen). |
| A3 FoSci | – | Phase 2, new package. |
| A4 Paper mills | – | Phase 2, module of FoSci; image signals from reproimage. |
| B1 AI in research | aitrail | Integrate (frozen); corpus-level disclosure and policy analysis in the new `aiinresearch` (Phase 3, see ADR-0005). |
| B2 Scientific communication | scicomm | Integrate (frozen). No `scicom` package. |
| B3 Research assessment | Spread over ORM, narrativecv, academiccareer | Shared vocabulary in `metascience`; no new package. |
| C1 Reproducibility | repro2impact detectors, reproimage | Phase 2, `researchreproducibility` from repro2impact. |
| C2 Benchmarks | Recorded responses and reference images inside packages | Keep inside packages until shared cases exist. |
| 4.x Shared infrastructure | Duplicated helpers across packages | **Done in Phase 1:** `metascience` (identifiers, status vocabulary, evidence levels, manifest). |
| 7 AI maintenance | research-tools-ops | Phase 5, extend. |

## 4. Overlaps found

1. ORCID validation is implemented four times (ORM JS, narrativecv, academiccareer, ORM R). New code uses `metascience::ms_orcid()`.
2. OpenAlex/DataCite normalisers exist in narrativecv, academiccareer and ORM with different item shapes (`record` field in narrativecv, OA fields in ORM). Unifying them would break frozen APIs; instead the common *status* vocabulary makes their outputs combinable.
3. Status words differ (`computed`/`unverifiable`; `found`/`not_found_in_sources`/...; `yes`/`no`/`unverifiable`). `ms_harmonise_status()` maps them without losing the "unverifiable is never zero" rule.

## 5. Deferred changes to frozen packages (after CRAN acceptance)

- narrativecv, academiccareer: optionally use `metascience` identifiers; add ROR affiliations.
- aitrail: record `ai_use_basis` (declared/inferred/verified) explicitly in logs and reports.
- scicomm, aitrail, academiccareer: add Zenodo DOIs to CITATION.cff (none yet).
- All: a `metascience` badge and link in README.
