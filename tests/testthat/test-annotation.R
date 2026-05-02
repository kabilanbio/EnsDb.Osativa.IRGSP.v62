library(testthat)
library(EnsDb.Osativa.IRGSP.62)

test_that("EnsDb object loads correctly", {
  edb <- EnsDb.Osativa.IRGSP.62
  expect_s4_class(edb, "EnsDb")
  expect_true(length(genes(edb)) > 30000)
})