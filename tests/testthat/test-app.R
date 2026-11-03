skip_if_not_installed("shiny")

# Ecosystem packages are optional; their names are held in variables so that
# they never become declared dependencies of metascience.
needs <- function(pkg) if (!requireNamespace(pkg, quietly = TRUE)) skip(paste(pkg, "not installed"))

test_that("the app builds with whatever packages are installed", {
  app <- ms_app()
  expect_s3_class(app, "shiny.appobj")
  html <- as.character(app_ui())
  expect_match(html, "Catalogue")
  for (m in app_modules()) expect_match(html, m$title, fixed = TRUE)
})

test_that("missing packages get install instructions instead of a section", {
  html <- as.character(missing_ui("FoSci"))
  expect_match(html, "not installed")
  expect_match(html, "pablosancheznunez/FoSci", fixed = TRUE)
  expect_match(as.character(missing_ui("openresearchmetrics")), "subdir", fixed = TRUE)
})

test_that("the catalogue module renders the catalogue", {
  shiny::testServer(catalogue_server, {
    expect_match(output$catalogue, "FoSci")
    expect_match(output$status, "metascience")
  })
})

test_that("the openresearchmetrics module computes the example offline", {
  pkg <- "openresearchmetrics"
  needs(pkg)
  shiny::testServer(orm_server, {
    session$setInputs(orcid = "0000-0002-1825-0097", example = TRUE, run = 1)
    expect_match(output$table, "oa-publications-share")
    expect_match(output$sources, "openalex")
  })
})

test_that("the FoSci module computes signals on the benchmark", {
  pkg <- "FoSci"
  needs(pkg)
  shiny::testServer(fosci_server, {
    session$setInputs(source = "sim", seed = 1, run = 1)
    expect_match(output$signals, "citation_stacking")
    expect_match(output$pm, "pattern")
    expect_match(output$validation, "precision")
    expect_match(output$alternatives, "narrow specialty")
  })
})

test_that("the AI module detects disclosures and codes policies", {
  pkg <- "aiinresearch"
  needs(pkg)
  shiny::testServer(ai_server, {
    session$setInputs(text = "Declaration of AI use. We used ChatGPT to improve readability.", detect = 1)
    expect_match(output$disclosures, "ChatGPT")
    session$setInputs(policy = "AI tools cannot be listed as authors.", code = 1)
    expect_match(output$comparison, "ai_not_author")
  })
})

test_that("the scicomm module reports readability", {
  pkg <- "scicomm"
  needs(pkg)
  shiny::testServer(scicomm_server, {
    session$setInputs(text = "Heatwaves are becoming more frequent. Cities are warmer.", lang = "en", run = 1)
    expect_match(output$readability, "reading_ease")
  })
})

test_that("the reproducibility module audits an uploaded zip and refuses unsafe ones", {
  pkg <- "researchreproducibility"
  needs(pkg)
  src <- file.path(tempfile("zipsrc"), "study")
  dir.create(src, recursive = TRUE)
  writeLines("# Study", file.path(src, "README.md"))
  writeLines("x <- 1", file.path(src, "analysis.R"))
  zip <- tempfile(fileext = ".zip")
  old <- setwd(dirname(src))
  on.exit(setwd(old), add = TRUE)
  utils::zip(zip, "study", flags = "-rq")
  setwd(old)
  skip_if_not(file.exists(zip), "No zip program available")
  shiny::testServer(rr_server, {
    session$setInputs(zip = list(datapath = zip, name = "study.zip"), audit = 1)
    expect_match(output$checks, "README")
    expect_match(output$type, "research-project")
    session$setInputs(article = "The analysis code is available at https://github.com/lab/study.", detect = 1)
    expect_match(output$indicators, "code_shared")
  })
})
