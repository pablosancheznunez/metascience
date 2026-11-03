# metascience

Catalogue and shared infrastructure for a set of open, independent tools that study research: how it is produced and assessed, whether it is done and communicated responsibly, and whether it can be checked and reproduced.

Status: **prototype** (not yet released).

## The ecosystem

| Domain | Tool | What it does | Maturity | CRAN |
| --- | --- | --- | --- | --- |
| Science of science | [OpenResearchMetrics](https://github.com/pablosancheznunez/openresearchmetrics) | Open science indicators, each on its own, no composite score; web tool and R package | web: implemented · R: prototype | – |
| | [narrativecv](https://github.com/pablosancheznunez/narrative-cv-crosswalk) | Narrative CV sections (R4RI, CVA) mapped to evidence in open infrastructures | implemented | submitted |
| | [academiccareer](https://github.com/pablosancheznunez/academiccareer) | Descriptive career profiles: timelines, contributions, transitions | implemented | submitted |
| Integrity and governance | [aitrail](https://github.com/pablosancheznunez/aitrail) | Document, verify and disclose AI use in research | implemented | submitted |
| | [aiinresearch](https://github.com/pablosancheznunez/aiinresearch) | Declared AI use in articles and AI policies; never infers AI authorship | prototype | – |
| | [scicomm](https://github.com/pablosancheznunez/scicomm) | Fidelity and audience fit in science communication | implemented | submitted |
| | [FoSci](https://github.com/pablosancheznunez/FoSci) | Forensic scientometrics and paper mills: signals, never accusations | prototype | – |
| Reproducibility and quality | [reproimage](https://github.com/pablosancheznunez/reproimage) | Integrity and provenance checks for scientific images | implemented | submitted |
| | [REPRO2IMPACT](https://github.com/pablosancheznunez/repro2impact) | Reproducibility indicators and impact: research project | prototype | – |
| | [researchreproducibility](https://github.com/pablosancheznunez/researchreproducibility) | Reproducibility audits of projects and articles | prototype | – |
| Infrastructure | [research-tools-ops](https://github.com/pablosancheznunez/research-tools-ops) | Shared CI, CRAN watch and releases | implemented | – |
| | metascience | This package | prototype | – |

The same table, always current, from R:

```r
# install.packages("remotes")
remotes::install_github("pablosancheznunez/metascience")

library(metascience)
ms_catalogue()          # every tool, its domain, maturity and CRAN status
ms_status()             # which ecosystem packages are installed
```

## Portal and interfaces

- **Portal**: `site/build.R` builds a static page from the catalogue; the Pages workflow publishes it on every change.
- **Interfaces**: one Shiny app with a section per tool, using whichever tools are installed:

```r
install.packages("shiny")
metascience::ms_app()
```

Sections: open science indicators (openresearchmetrics), forensic scientometrics and paper mill screening (FoSci), AI disclosures and AI policies (aiinresearch), readability (scicomm), project audits and article transparency (researchreproducibility). Uploaded files stay in the R session's temporary folder.

## Shared foundation

```r
ms_orcid("https://orcid.org/0000-0002-1825-0097")   # validated, normalised
ms_doi("https://doi.org/10.5281/ZENODO.23881633")
ms_ror("https://ror.org/03ths8210")
ms_identify(c("10.5281/zenodo.23881631", "0000-0002-1825-0097"))

ms_vocabulary("evidence_level")      # signal < pattern < documentary < established
ms_harmonise_status(c("found", "source_unavailable"), tool = "narrativecv")
#> "reported" "unverifiable"         # never read as "no"

m <- ms_manifest(sources = report$sources_consulted,
                 methods = c("oa-publications-share" = "1.0.0"))
ms_write_manifest(m, "manifest.json")
```

## Documents

- [Phase 0 audit](docs/AUDIT.md): what exists, what is reused, what is frozen.
- [Architecture and roadmap](docs/ARCHITECTURE.md), with the status of every deliverable.
- [Development standards](docs/STANDARDS.md) and the [CI template](templates/ci-r-package.yml).
- [Scientific governance](docs/GOVERNANCE.md): descriptive indicators, evidence levels, what automation may and may not change.
- [Architectural decisions](docs/DECISIONS.md).

## License

MIT. See [`CITATION.cff`](CITATION.cff) to cite.
