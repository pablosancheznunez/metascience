# Scientific and methodological governance

## Rules for every tool
1. **Descriptive, not evaluative.** Indicators describe practices and outputs. No tool produces a composite score, a ranking of people or a judgement of research quality.
2. **Unverifiable is not zero.** A result that the sources cannot establish is `unverifiable`; something not found is `absent_in_sources`, never "does not exist".
3. **Versioned methods.** Each definition has a methodology version bound to the code that implements it, and a regression test with a stored expected output.
4. **Provenance with every result.** Reports state the sources consulted (and whether they answered), the methodology versions, software versions and limitations (`ms_manifest()`).
5. **Coverage is part of the result.** Differences across disciplines, languages, regions and database coverage are documented in each indicator card's limitations and in reports.

## Forensic scientometrics and paper mills
- **An anomaly is not misconduct.** Every finding carries an evidence level: `signal`, `pattern`, `documentary` or `established` (`ms_vocabulary("evidence_level")`). A lower level is never worded as a higher one.
- Reports list alternative explanations next to every signal (field norms, collaboration size, database errors, name disambiguation, language).
- No automated blacklists and no rankings of individual researchers. Unit of analysis by default: publications, journals and clusters; individuals appear only as part of a documented case.
- `established` is reserved for findings by an independent competent body (retraction notice with stated cause, institutional or judicial decision), cited, not restated.
- Thresholds are validated against benchmark cases with known outcomes before release, and their false-positive rates are reported.

## AI in research
- Statements about AI use carry their basis: `declared`, `inferred` or `verified` (`ms_vocabulary("ai_use_basis")`).
- Automated AI-text detection is never presented as proof of authorship.

## Who decides what
| Change | Can be automated | Needs maintainer approval |
| --- | --- | --- |
| Routine checks, dependency monitoring, test runs, reports | yes | – |
| Documentation fixes, link repairs, non-breaking maintenance | proposed as draft PR | merge |
| Indicator definitions, catalogues, crosswalks, thresholds, expected outputs | never | always (CODEOWNERS) |
| Breaking API changes, releases, CRAN submissions | never | always |
| Security-sensitive changes | never | always |

No AI agent changes a scientific method silently or publishes a conclusion; high-risk paths are protected with CODEOWNERS in every repository.
