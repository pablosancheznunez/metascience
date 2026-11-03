#' Interactive interfaces for the ecosystem
#'
#' Launches one Shiny application with a section per tool: research
#' indicators (openresearchmetrics), forensic scientometrics (forsci), AI
#' use in research (aiinresearch), reproducibility (researchreproducibility)
#' and science communication (scicomm), plus the catalogue. Each section uses
#' its package if it is installed and otherwise says how to install it, so
#' the packages stay independent of the interface.
#'
#' Nothing is sent anywhere except the open APIs the tools themselves query
#' (for example OpenAlex for an ORCID iD). Uploaded files stay in a temporary
#' directory of the R session.
#'
#' @param ... Passed to [shiny::shinyApp()] (for example `options =
#'   list(port = 8080)`).
#' @return A Shiny app object; printing it launches the app.
#' @export
#' @examples
#' if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
#'   ms_app()
#' }
ms_app <- function(...) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("ms_app() needs the shiny package: install.packages(\"shiny\").", call. = FALSE)
  }
  shiny::shinyApp(app_ui(), app_server, ...)
}

app_modules <- function() {
  list(
    list(id = "orm", title = "Open science indicators", menu = "Science of science", pkg = "openresearchmetrics",
         ui = orm_ui, server = orm_server),
    list(id = "forsci", title = "Forensic scientometrics", menu = "Research integrity", pkg = "forsci",
         ui = forsci_ui, server = forsci_server),
    list(id = "ai", title = "AI in research", menu = "Research integrity", pkg = "aiinresearch",
         ui = ai_ui, server = ai_server),
    list(id = "scicomm", title = "Science communication", menu = "Research integrity", pkg = "scicomm",
         ui = scicomm_ui, server = scicomm_server),
    list(id = "rr", title = "Reproducibility audit", menu = "Reproducibility", pkg = "researchreproducibility",
         ui = rr_ui, server = rr_server)
  )
}

has_pkg <- function(pkg) requireNamespace(pkg, quietly = TRUE)

# Called by name so that the interface never makes the packages hard
# dependencies of metascience.
fn <- function(pkg, name) getExportedValue(pkg, name)

app_ui <- function() {
  css <- paste(readLines(system.file("design", "metascience.css", package = "metascience"), warn = FALSE),
               collapse = "\n")
  mods <- app_modules()
  menus <- unique(vapply(mods, `[[`, "", "menu"))
  tabs <- lapply(menus, function(m) {
    items <- Filter(function(x) x$menu == m, mods)
    panels <- lapply(items, function(x) shiny::tabPanel(x$title, value = x$id, module_ui(x)))
    do.call(shiny::navbarMenu, c(list(m), panels))
  })
  page <- do.call(shiny::navbarPage, c(
    list(title = "Metascience", id = "nav", windowTitle = "Metascience",
         header = shiny::tags$head(shiny::tags$style(shiny::HTML(css)), shiny::tags$style(shiny::HTML(app_css)))),
    list(shiny::tabPanel("Catalogue", value = "catalogue", catalogue_ui("catalogue"))),
    tabs
  ))
  page
}

app_css <- "
.navbar { background: var(--ms-surface); border-bottom: 1px solid var(--ms-line); }
.container-fluid { max-width: 1180px; }
.ms-panel { background: var(--ms-surface); border: 1px solid var(--ms-line); border-radius: var(--ms-radius); padding: 1rem; margin-bottom: 1rem; }
.ms-panel h3 { margin-top: 0; }
.ms-panel table { font-size: .88rem; }
"

module_ui <- function(m) {
  if (!has_pkg(m$pkg)) return(missing_ui(m$pkg))
  m$ui(m$id)
}

missing_ui <- function(pkg) {
  cat_ <- ms_catalogue()
  repo <- cat_$repository[match(pkg, cat_$r_package)]
  slug <- sub("^https://github.com/", "", repo %||% "")
  shiny::div(class = "ms-note",
             shiny::p(shiny::strong(pkg), " is not installed, so this section is not available."),
             shiny::tags$pre(sprintf("remotes::install_github(\"%s\"%s)", slug,
                                     if (pkg == "openresearchmetrics") ", subdir = \"r\"" else "")))
}

app_server <- function(input, output, session) {
  catalogue_server("catalogue")
  for (m in app_modules()) if (has_pkg(m$pkg)) m$server(m$id)
}

panel <- function(title, ...) shiny::div(class = "ms-panel", shiny::h3(title), ...)

# Catalogue ---------------------------------------------------------------

catalogue_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::p(class = "ms-lede", "Independent tools that study research. Each states how mature it is; ",
             "a prototype works for documented cases but is not a finished product."),
    panel("Tools", shiny::div(class = "ms-scroll", shiny::tableOutput(ns("catalogue")))),
    panel("Installed in this R session", shiny::tableOutput(ns("status")))
  )
}

catalogue_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    output$catalogue <- shiny::renderTable(ms_catalogue()[, c("name", "domain", "maturity", "cran", "role")])
    output$status <- shiny::renderTable(ms_status()[, c("r_package", "maturity", "installed", "version")])
  })
}

# OpenResearchMetrics -----------------------------------------------------

orm_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::textInput(ns("orcid"), "ORCID iD", "0000-0002-1825-0097"),
      shiny::checkboxInput(ns("example"), "Use the recorded example (offline)", TRUE),
      shiny::actionButton(ns("run"), "Compute indicators", class = "btn-primary"),
      shiny::hr(),
      shiny::downloadButton(ns("json"), "Report (JSON)"),
      shiny::p(shiny::tags$small("Each indicator stands alone; there is no composite score. ",
                                 "Unverifiable means the sources could not establish it, never zero."))
    ),
    shiny::mainPanel(panel("Indicators", shiny::textOutput(ns("sources")), shiny::tableOutput(ns("table"))))
  )
}

orm_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    report <- shiny::eventReactive(input$run, {
      if (isTRUE(input$example)) {
        ex <- fn("openresearchmetrics", "orm_example_evidence")()
        fn("openresearchmetrics", "orm_compute")(ex$evidence, ex$consulted, orcid = "0000-0002-1825-0097")
      } else {
        id <- ms_orcid(input$orcid)
        shiny::validate(shiny::need(!is.na(id), "Enter a valid ORCID iD."))
        fn("openresearchmetrics", "orm_assess")(id)
      }
    })
    output$sources <- shiny::renderText({
      r <- report()
      paste("Sources:", paste(vapply(r$sources_consulted, function(s) {
        paste0(s$source, if (isTRUE(s$ok)) "" else " (failed)")
      }, ""), collapse = ", "))
    })
    output$table <- shiny::renderTable(as.data.frame(report()), na = "")
    output$json <- shiny::downloadHandler("openresearchmetrics-report.json", function(file) {
      fn("openresearchmetrics", "orm_write_json")(report(), file)
    })
  })
}

# forsci --------------------------------------------------------------------

forsci_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::radioButtons(ns("source"), "Corpus", c("Simulated benchmark" = "sim", "Upload CSV tables" = "upload")),
      shiny::conditionalPanel(sprintf("input['%s'] == 'sim'", ns("source")),
                              shiny::numericInput(ns("seed"), "Seed", 1, min = 1, step = 1)),
      shiny::conditionalPanel(sprintf("input['%s'] == 'upload'", ns("source")),
                              shiny::fileInput(ns("works"), "works.csv", accept = ".csv"),
                              shiny::fileInput(ns("authorships"), "authorships.csv (optional)", accept = ".csv"),
                              shiny::fileInput(ns("references"), "references.csv (optional)", accept = ".csv")),
      shiny::actionButton(ns("run"), "Compute signals", class = "btn-primary"),
      shiny::hr(),
      shiny::downloadButton(ns("report"), "Report (HTML)"),
      shiny::p(shiny::tags$small("Signals are not evidence of misconduct. Individuals are not ranked; ",
                                 "person-level signals are not computed here."))
    ),
    shiny::mainPanel(
      panel("Flagged signals", shiny::div(class = "ms-scroll", shiny::tableOutput(ns("signals")))),
      panel("Alternative explanations", shiny::tableOutput(ns("alternatives"))),
      panel("Paper mill screen", shiny::div(class = "ms-scroll", shiny::tableOutput(ns("pm")))),
      shiny::uiOutput(ns("validation_panel"))
    )
  )
}

forsci_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    corpus <- shiny::eventReactive(input$run, {
      if (input$source == "sim") return(fn("forsci", "fs_simulate")(seed = input$seed))
      shiny::validate(shiny::need(input$works, "Upload works.csv."))
      read <- function(f) if (is.null(f)) NULL else utils::read.csv(f$datapath, stringsAsFactors = FALSE)
      tryCatch(fn("forsci", "fs_corpus")(read(input$works), read(input$authorships), read(input$references),
                                         provenance = list(source = "upload", file = input$works$name)),
               error = function(e) shiny::validate(conditionMessage(e)))
    })
    signals <- shiny::reactive(fn("forsci", "fs_signals")(corpus()))
    output$signals <- shiny::renderTable({
      s <- signals()
      as.data.frame(s)[s$flagged %in% TRUE, c("signal", "unit_type", "unit_id", "detail", "evidence_level")]
    })
    output$alternatives <- shiny::renderTable({
      s <- as.data.frame(signals())
      s <- s[!duplicated(s$signal), c("signal", "alternatives")]
      s$alternatives <- gsub(" | ", "; ", s$alternatives, fixed = TRUE)
      s
    })
    output$pm <- shiny::renderTable(fn("forsci", "fs_pm_screen")(corpus())[, c("work_id", "template_group", "tortured_phrases",
                                                                              "retracted", "n_signals", "evidence_level")])
    output$validation_panel <- shiny::renderUI({
      if (is.null(attr(corpus(), "truth"))) return(NULL)
      panel("Validation against the planted cases", shiny::tableOutput(session$ns("validation")))
    })
    output$validation <- shiny::renderTable(fn("forsci", "fs_validate")(signals(), attr(corpus(), "truth")))
    output$report <- shiny::downloadHandler("forsci-signals.html", function(file) {
      fn("forsci", "fs_report")(signals(), file, corpus = corpus())
    })
  })
}

# aiinresearch -------------------------------------------------------------

ai_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tabsetPanel(
    shiny::tabPanel("Disclosures in articles", shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::textAreaInput(ns("text"), "Article text", rows = 8,
                             placeholder = "Paste the full text, or upload a CSV with columns id and text."),
        shiny::fileInput(ns("csv"), "Or a CSV (id, text)", accept = ".csv"),
        shiny::actionButton(ns("detect"), "Detect disclosures", class = "btn-primary"),
        shiny::p(shiny::tags$small("Declared use only. The tool never infers AI authorship; ",
                                   "no disclosure found is not hidden use."))
      ),
      shiny::mainPanel(panel("Results", shiny::div(class = "ms-scroll", shiny::tableOutput(ns("disclosures")))),
                       panel("Summary", shiny::tableOutput(ns("summary"))))
    )),
    shiny::tabPanel("AI policies", shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::fileInput(ns("policies"), "CSV of policies (id, text)", accept = ".csv"),
        shiny::textAreaInput(ns("policy"), "Or paste one policy", rows = 8),
        shiny::actionButton(ns("code"), "Code policies", class = "btn-primary"),
        shiny::p(shiny::tags$small("not_stated means the text does not address it, not that it is allowed or forbidden."))
      ),
      shiny::mainPanel(panel("Comparison", shiny::div(class = "ms-scroll", shiny::tableOutput(ns("comparison")))))
    ))
  )
}

ai_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    texts <- function(file, text) {
      if (!is.null(file)) {
        d <- utils::read.csv(file$datapath, stringsAsFactors = FALSE)
        shiny::validate(shiny::need(all(c("id", "text") %in% names(d)), "The CSV needs columns id and text."))
        return(d)
      }
      shiny::validate(shiny::need(nzchar(trimws(text)), "Paste a text or upload a CSV."))
      data.frame(id = "pasted", text = text, stringsAsFactors = FALSE)
    }
    detections <- shiny::eventReactive(input$detect, {
      d <- texts(input$csv, input$text)
      fn("aiinresearch", "air_detect_disclosure")(d$text, id = d$id)
    })
    output$disclosures <- shiny::renderTable(detections()[, c("id", "disclosure_statement", "use_declared",
                                                              "non_use_declared", "oversight_stated", "tools",
                                                              "purposes", "evidence")], na = "")
    output$summary <- shiny::renderTable(fn("aiinresearch", "air_summarise")(detections()), na = "")
    output$comparison <- shiny::renderTable({
      shiny::req(input$code)
      d <- shiny::isolate(texts(input$policies, input$policy))
      fn("aiinresearch", "air_compare_policies")(fn("aiinresearch", "air_code_policy")(d$text, id = d$id))
    })
  })
}

# scicomm ------------------------------------------------------------------

scicomm_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::textAreaInput(ns("text"), "Text for a lay audience", rows = 8),
      shiny::radioButtons(ns("lang"), "Language", c(English = "en", Spanish = "es"), inline = TRUE),
      shiny::actionButton(ns("run"), "Readability", class = "btn-primary"),
      shiny::p(shiny::tags$small("Readability is one part of communication quality. Fidelity to the evidence ",
                                 "and audience fit need the full workflow of scicomm (sc_assess())."))
    ),
    shiny::mainPanel(panel("Readability", shiny::tableOutput(ns("readability"))))
  )
}

scicomm_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    output$readability <- shiny::renderTable({
      shiny::req(input$run)
      text <- shiny::isolate(input$text)
      shiny::validate(shiny::need(nzchar(trimws(text)), "Paste a text."))
      r <- fn("scicomm", "sc_readability")(text, shiny::isolate(input$lang))
      data.frame(measure = names(r), value = vapply(r, function(v) as.character(v), ""), stringsAsFactors = FALSE)
    })
  })
}

# researchreproducibility --------------------------------------------------

rr_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tabsetPanel(
    shiny::tabPanel("Audit a project", shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::fileInput(ns("zip"), "Project as a .zip file", accept = ".zip"),
        shiny::actionButton(ns("audit"), "Audit", class = "btn-primary"),
        shiny::hr(),
        shiny::downloadButton(ns("report"), "Report (HTML)"),
        shiny::p(shiny::tags$small("The audit only reads files; it never runs the project's code. ",
                                   "It checks conditions for reproducibility, not a reproduction."))
      ),
      shiny::mainPanel(panel("Checklist", shiny::textOutput(ns("type")),
                             shiny::div(class = "ms-scroll", shiny::tableOutput(ns("checks")))))
    )),
    shiny::tabPanel("Transparency in an article", shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::textAreaInput(ns("article"), "Article full text", rows = 8),
        shiny::actionButton(ns("detect"), "Detect", class = "btn-primary")
      ),
      shiny::mainPanel(panel("Indicators", shiny::tableOutput(ns("indicators"))))
    ))
  )
}

rr_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    audit <- shiny::eventReactive(input$audit, {
      shiny::validate(shiny::need(input$zip, "Upload a .zip of the project."))
      entries <- tryCatch(utils::unzip(input$zip$datapath, list = TRUE)$Name, error = function(e) NULL)
      shiny::validate(shiny::need(length(entries) > 0, "Not a readable .zip file."))
      # Refuse entries that would be written outside the temporary folder.
      shiny::validate(shiny::need(!any(grepl("(^|[/\\\\])\\.\\.([/\\\\]|$)|^([/\\\\]|[A-Za-z]:)", entries)),
                                  "The .zip contains unsafe paths."))
      dir <- tempfile("project")
      dir.create(dir)
      utils::unzip(input$zip$datapath, exdir = dir)
      # A zip of one folder unpacks into that folder; audit its content.
      inner <- list.files(dir, full.names = TRUE, all.files = TRUE, no.. = TRUE)
      root <- if (length(inner) == 1L && dir.exists(inner)) inner else dir
      fn("researchreproducibility", "rr_audit")(root)
    })
    output$type <- shiny::renderText(paste("Project type:", audit()$project_type))
    output$checks <- shiny::renderTable(audit()$checks[, c("category", "item", "critical", "status", "evidence")], na = "")
    output$report <- shiny::downloadHandler("reproducibility-audit.html", function(file) {
      fn("researchreproducibility", "rr_report")(audit(), file)
    })
    output$indicators <- shiny::renderTable({
      shiny::req(input$detect)
      text <- shiny::isolate(input$article)
      shiny::validate(shiny::need(nzchar(trimws(text)), "Paste a text."))
      d <- fn("researchreproducibility", "rr_detect")(text)
      ind <- c("data_statement", "data_shared", "code_shared", "preregistered", "materials_shared")
      data.frame(indicator = ind, value = unlist(d[1, ind]), evidence = unlist(d[1, paste0(ind, "_evidence")]),
                 stringsAsFactors = FALSE)
    }, na = "")
  })
}
