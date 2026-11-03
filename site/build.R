# Builds the Metascience portal (_site/) from the catalogue, so the website
# and ms_catalogue() can never disagree. Run from the repository root:
#   Rscript site/build.R
# Needs only jsonlite.

esc <- function(x) {
  x <- gsub("&", "&amp;", as.character(x), fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  gsub("\"", "&quot;", x, fixed = TRUE)
}

cat_ <- jsonlite::read_json("inst/extdata/catalogue.json")
repo <- "https://github.com/pablosancheznunez/metascience"
maturity_label <- c(implemented = "implemented", implemented_not_validated = "not yet validated",
                    prototype = "prototype", planned = "planned", blocked = "blocked")
cran_label <- c(submitted = "submitted to CRAN", published = "on CRAN")

card <- function(x) {
  links <- c(
    if (!is.null(x$url)) sprintf("<a href=\"%s\">Use it</a>", esc(x$url)),
    if (!is.null(x$repository)) sprintf("<a href=\"%s\">Code</a>", esc(x$repository)),
    if (!is.null(x$doi)) sprintf("<a href=\"https://doi.org/%s\">DOI</a>", esc(x$doi))
  )
  badges <- c(
    sprintf("<span class=\"ms-badge %s\">%s</span>", x$maturity, maturity_label[[x$maturity]]),
    if (!is.null(cran_label[x$cran]) && !is.na(cran_label[x$cran])) {
      sprintf("<span class=\"ms-badge cran\">%s</span>", cran_label[[x$cran]])
    }
  )
  paste0("<article class=\"ms-card\"><h3>", esc(x$name), "</h3><div>", paste(badges, collapse = " "),
         "</div><p>", esc(x$role), "</p>",
         if (length(links)) paste0("<div class=\"ms-links\">", paste(links, collapse = ""), "</div>"),
         "</article>")
}

domains <- vapply(cat_$domains, function(d) {
  comps <- Filter(function(x) x$domain == d$id, cat_$components)
  paste0("<section id=\"", d$id, "\"><h2>", esc(d$name), "</h2><p class=\"ms-lede\">", esc(d$question),
         "</p><div class=\"ms-grid\">", paste(vapply(comps, card, ""), collapse = ""), "</div></section>")
}, "")

principles <- c(
  "Each indicator stands alone, with its evidence and its limits. No composite scores and no rankings of people.",
  "A result that cannot be verified is <em>unverifiable</em>, never zero or &ldquo;no&rdquo;. Not found is not absent.",
  "An anomaly is not misconduct. Findings carry an evidence level: signal, pattern, documentary, established.",
  "Only declared AI use is measured. Automated AI-text detection is not evidence of authorship.",
  "Every method is versioned and bound to its code, with a stored expected result.",
  "Automation runs routine maintenance; changes to methods, indicators or evidence always need human review."
)

docs <- c(AUDIT = "What exists and how it is integrated", ARCHITECTURE = "Architecture and roadmap, with the status of every deliverable",
          STANDARDS = "Development standards", GOVERNANCE = "Scientific governance", DECISIONS = "Architectural decisions")
doc_links <- paste0("<li><a href=\"", repo, "/blob/main/docs/", names(docs), ".md\">", esc(docs), "</a></li>", collapse = "")

css <- paste(readLines("inst/design/metascience.css", warn = FALSE), collapse = "\n")
html <- paste0(
  "<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">",
  "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">",
  "<title>Metascience</title>",
  "<meta name=\"description\" content=\"Open, modular tools that study research: assessment, integrity, AI use, communication and reproducibility.\">",
  "<link rel=\"icon\" href=\"logo.svg\" type=\"image/svg+xml\"><style>", css, "</style></head><body>",
  "<header class=\"ms-header\"><div class=\"ms-wrap\"><img src=\"logo.svg\" alt=\"\" width=\"32\" height=\"32\">",
  "<a class=\"ms-brand\" href=\"./\">Metascience</a><nav>",
  paste0("<a href=\"#", vapply(cat_$domains, `[[`, "", "id"), "\">", esc(vapply(cat_$domains, `[[`, "", "name")), "</a>", collapse = ""),
  "<a href=\"#principles\">Principles</a><a href=\"#use\">Use</a></nav></div></header>",
  "<main class=\"ms-wrap\"><section><h1>Open tools that study research</h1>",
  "<p class=\"ms-lede\">A set of independent, interoperable tools for research assessment, research integrity, AI use in research, ",
  "science communication and reproducibility. Each tool works on its own; they share identifiers, vocabularies and provenance, ",
  "and every one states how mature it is.</p></section>",
  paste(domains, collapse = ""),
  "<section id=\"principles\"><h2>Principles</h2><ul class=\"ms-principles\">",
  paste0("<li>", principles, "</li>", collapse = ""), "</ul></section>",
  "<section id=\"use\"><h2>Use</h2><div class=\"ms-grid\">",
  "<article class=\"ms-card\"><h3>From R</h3><p>Every tool is an R package. The catalogue and shared foundation:</p>",
  "<pre><code>remotes::install_github(\"pablosancheznunez/metascience\")\nmetascience::ms_catalogue()</code></pre></article>",
  "<article class=\"ms-card\"><h3>Interactive interfaces</h3><p>One Shiny application with a section per tool. It uses whichever tools are installed.</p>",
  "<pre><code>metascience::ms_app()</code></pre></article>",
  "<article class=\"ms-card\"><h3>Documentation</h3><ul>", doc_links, "</ul></article></div></section>",
  "<p class=\"ms-note\">Maturity labels are part of each result: a <em>prototype</em> works for documented cases but is not a finished product, ",
  "and methods marked as not yet validated have not been checked against reference data.</p></main>",
  "<footer class=\"ms-footer\"><div class=\"ms-wrap\">Catalogue ", esc(cat_$catalogue_version), ", updated ", esc(cat_$updated),
  ". Code MIT. <a href=\"", repo, "\">Source</a>.</div></footer></body></html>"
)

dir.create("_site", showWarnings = FALSE)
writeLines(html, "_site/index.html", useBytes = TRUE)
file.copy("inst/design/logo.svg", "_site/logo.svg", overwrite = TRUE)
file.create("_site/.nojekyll")
message("Portal written to _site/index.html")
