test_that("a manifest records environment, sources, methods and inputs", {
  input <- withr_local_file()
  m <- ms_manifest(
    sources = list(list(source = "openalex", ok = TRUE, count = 25, error = NULL,
                        retrieved_at = "2026-11-02T00:00:00Z"),
                   list(source = "openaire", ok = FALSE, count = 0, error = "timeout")),
    methods = c("oa-publications-share" = "1.0.0"),
    inputs = input, limitations = "Coverage differs by field.",
    generated_at = "2026-11-03T00:00:00Z"
  )
  expect_s3_class(m, "ms_manifest")
  expect_identical(m$schema, "metascience-manifest/1")
  expect_true("metascience" %in% vapply(m$packages, `[[`, "", "package"))
  expect_identical(m$sources[[2]]$ok, FALSE)
  expect_true(is.na(m$sources[[2]]$retrieved_at))
  expect_identical(m$inputs[[1]]$md5, unname(tools::md5sum(input)))
  expect_output(print(m), "openaire (failed)", fixed = TRUE)

  path <- tempfile(fileext = ".json")
  ms_write_manifest(m, path)
  back <- jsonlite::read_json(path)
  expect_identical(back$schema, "metascience-manifest/1")
  expect_identical(back$methods$`oa-publications-share`, "1.0.0")
  expect_null(back$sources[[1]]$error)
})

test_that("a data frame of sources is accepted", {
  m <- ms_manifest(sources = data.frame(source = c("crossref", "ror"), ok = c(TRUE, TRUE)))
  expect_identical(vapply(m$sources, `[[`, "", "source"), c("crossref", "ror"))
})

test_that("invalid arguments are rejected", {
  expect_error(ms_manifest(methods = c("1.0.0")), "named")
  expect_error(ms_manifest(inputs = "no/such/file.csv"), "not found")
  expect_error(ms_manifest(sources = list(list(ok = TRUE))), "source")
  expect_error(ms_write_manifest(list(), tempfile()), "ms_manifest")
})
