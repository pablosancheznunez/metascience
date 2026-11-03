test_that("the catalogue lists every component with valid fields", {
  cat_ <- ms_catalogue()
  expect_s3_class(cat_, "data.frame")
  expect_true(all(c("openresearchmetrics", "narrativecv", "fosci") %in% cat_$id))
  expect_false(anyDuplicated(cat_$id) > 0)
  expect_true(all(cat_$domain %in% ms_domains()$id))
  expect_true(all(cat_$maturity %in% c("implemented", "implemented_not_validated",
                                        "prototype", "planned", "blocked")))
  expect_true(all(cat_$cran %in% c("submitted", "published", "not_submitted", "not_applicable")))
  dois <- cat_$doi[!is.na(cat_$doi)]
  expect_identical(ms_doi(dois), dois)
})

test_that("components submitted to CRAN are frozen", {
  cat_ <- ms_catalogue()
  expect_true(all(cat_$frozen[cat_$cran == "submitted"]))
})

test_that("out-of-scope projects never appear in the catalogue", {
  expect_length(intersect(ms_outside_scope()$id, ms_catalogue()$id), 0)
  expect_true(all(c("neuroconsumer", "uxlearn", "visualbrief") %in% ms_outside_scope()$id))
})

test_that("filters work and reject unknown values", {
  expect_true(all(ms_catalogue(domain = "science_of_science")$domain == "science_of_science"))
  expect_true(all(ms_catalogue(maturity = "planned")$maturity == "planned"))
  expect_error(ms_catalogue(domain = "astrology"), "Unknown domain")
  expect_error(ms_catalogue(maturity = "finished"), "Unknown maturity")
})

test_that("ms_status reports installed packages without loading them", {
  s <- ms_status()
  expect_true("metascience" %in% s$r_package)
  expect_true(s$installed[s$r_package == "metascience"])
  expect_false(any(s$installed[s$maturity == "planned"]))
  expect_type(s$version, "character")
})
