test_that("DOIs are normalised and invalid ones become NA", {
  expect_identical(
    ms_doi(c("https://doi.org/10.5281/ZENODO.23881633", "doi:10.1000/xyz",
             "http://dx.doi.org/10.1000%2Fabc", "  10.1000/x  ", "10.10/x", "nope", NA)),
    c("10.5281/zenodo.23881633", "10.1000/xyz", "10.1000/abc", "10.1000/x", NA, NA, NA)
  )
  expect_identical(ms_doi("10.1000/xyz", url = TRUE), "https://doi.org/10.1000/xyz")
  expect_error(ms_doi(1), "character")
})

test_that("ORCID iDs are checked with the MOD 11-2 check digit", {
  expect_identical(
    ms_orcid(c("https://orcid.org/0000-0002-1825-0097", "0000000218250097",
               "0000-0002-1694-233x", "0000-0002-1825-0098", "1234")),
    c("0000-0002-1825-0097", "0000-0002-1825-0097", "0000-0002-1694-233X", NA, NA)
  )
  expect_identical(ms_orcid("0000-0001-7845-9506", url = TRUE),
                   "https://orcid.org/0000-0001-7845-9506")
})

test_that("ROR IDs are checked with the MOD 97-10 check digits", {
  expect_identical(
    ms_ror(c("https://ror.org/03ths8210", "05DXPS055", "03ths8211", "13ths8210", "03ths82")),
    c("03ths8210", "05dxps055", NA, NA, NA)
  )
  expect_identical(ms_ror("02mhbdp94", url = TRUE), "https://ror.org/02mhbdp94")
})

test_that("ms_identify recognises each type", {
  id <- ms_identify(c("10.5281/zenodo.23881631", "0000-0002-1825-0097",
                      "https://ror.org/03ths8210", "not an identifier"))
  expect_identical(id$type, c("doi", "orcid", "ror", NA))
  expect_identical(id$id[1:3], c("10.5281/zenodo.23881631", "0000-0002-1825-0097", "03ths8210"))
})
