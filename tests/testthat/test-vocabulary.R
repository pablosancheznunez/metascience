test_that("vocabularies have unique, defined terms", {
  for (v in ms_vocabularies()) {
    voc <- ms_vocabulary(v)
    expect_false(anyDuplicated(voc$id) > 0)
    expect_true(all(nzchar(voc$definition) & nzchar(voc$may_be_read_as)))
  }
  expect_error(ms_vocabulary("nope"), "Unknown vocabulary")
})

test_that("every mapping targets a common status", {
  m <- ms_status_mappings()
  expect_true(all(m$common_status %in% ms_vocabulary("result_status")$id))
})

test_that("unverifiable results are never harmonised as negative", {
  m <- ms_status_mappings()
  failing <- m$status %in% c("unverifiable", "source_unavailable")
  expect_true(all(m$common_status[failing] == "unverifiable"))
  expect_identical(
    ms_harmonise_status(c("found", "partial", "not_found_in_sources", "source_unavailable",
                          "no_automated_source", NA), "narrativecv"),
    c("reported", "reported", "absent_in_sources", "unverifiable", "not_automatable", NA)
  )
  expect_identical(ms_harmonise_status(c("computed", "unverifiable"), "openresearchmetrics"),
                   c("reported", "unverifiable"))
})

test_that("unknown statuses and tools are errors", {
  expect_error(ms_harmonise_status("zero", "openresearchmetrics"), "Unknown openresearchmetrics status")
  expect_error(ms_harmonise_status("found", "sometool"), "must be one of")
})

test_that("evidence levels keep signals apart from findings", {
  lv <- ms_vocabulary("evidence_level")
  expect_identical(lv$id, c("signal", "pattern", "documentary", "established"))
  expect_match(lv$may_be_read_as[lv$id == "signal"], "not evidence of misconduct")
  ai <- ms_vocabulary("ai_use_basis")
  expect_match(ai$may_be_read_as[ai$id == "inferred"], "not proof")
})
