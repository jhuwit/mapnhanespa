reference_data <- data.frame(
  age = c(25, 62, 84, 8, 45, 35, 70, 15, 55),
  sex = c("Female", "Male", "Female", "Male", "Female", "Male", "Female",
          "Male", "Female"),
  measure = c("AC", "log10AC", "PAXMTSM", "log10PAXMTSM", "scsslsteps",
              "scrfsteps", "oaksteps", "vssteps", "vsrevsteps"),
  value = c(2500000, 2900, 14000, 1000, 8000, 11000, 9000, 9500, 9000)
)

test_that("default criterion reproduces quantiles from mapnhanespa 0.3.0", {
  # Reference values computed with mapnhanespa 0.3.0, before wear-time
  # criteria were added.
  expected <- list(
    combined = c(0.31749131582884288, 0.53797283623522252, 0.91880708280619838,
                 0.046631707929492665, 0.41860230461366899, 0.3170529148533589,
                 0.69197606690436775, 0.42433588532720806, 0.59873147060859355),
    wave8 = c(0.29064718701756803, 0.56695418212020821, 0.91167115056305437,
              0.053653037535186056, 0.40189760157584464, 0.34717197167998276,
              0.70804181384529008, 0.48917638452804052, 0.66765497968023191),
    sex_overall = c(0.35425539688280705, 0.49152710165258284,
                    0.94075574839370324, 0.041117165191491965,
                    0.35525842809764857, 0.39015581098537705,
                    0.67654929628054561, 0.4381187476893082,
                    0.54517835896677458),
    overall = c(0.39176356227140552, 0.34676085321473737, 0.46170355681640052,
                0.40617854765794509, 0.39372143001956533, 0.43630473084313398,
                0.23375811371746635, 0.47630946928650042, 0.44037381514219687)
  )

  expect_equal(map_nhanes_pa_quantiles(reference_data)$nhanes_quantile,
               expected$combined)
  expect_equal(map_nhanes_pa_quantiles(reference_data, wave = "2013-2014")$nhanes_quantile,
               expected$wave8)
  expect_equal(map_nhanes_pa_quantiles(reference_data, sex = NULL)$nhanes_quantile,
               expected$sex_overall)
  expect_equal(map_nhanes_pa_quantiles(reference_data, age = NULL, sex = NULL,
                                       wave = 7)$nhanes_quantile,
               expected$overall)

  # Explicit defaults are identical to omitting the arguments
  expect_identical(
    map_nhanes_pa_quantiles(reference_data, min_wear_minutes = 1368,
                            min_valid_days = 3),
    map_nhanes_pa_quantiles(reference_data)
  )
  expect_identical(
    nhanes_pa_quantile(15000, age = 25, sex = "Female", measure = "mims",
                       min_wear_minutes = 1368, min_valid_days = 3),
    nhanes_pa_quantile(15000, age = 25, sex = "Female", measure = "mims")
  )
  expect_null(mapnhanespa:::.resolve_wear_criterion(1368, 3))
})

test_that("wear criteria table matches the packaged data", {
  criteria <- nhanes_pa_wear_criteria()

  expect_equal(nrow(criteria), 15L)
  expect_setequal(criteria$min_wear_minutes, c(600, 960, 1296, 1368, 1440))
  expect_setequal(criteria$min_valid_days, c(1, 3, 4))
  expect_equal(criteria$criterion[criteria$default], "wear1368_days3")
  expect_false(anyNA(criteria$note))
  expect_setequal(criteria$criterion,
                  unique(nhanes_measure_data_wear_criteria$criterion))
  expect_true(all(unique(nhanes_measure_data$measure) %in%
                    names(nhanes_measure_data_wear_criteria)))
  expect_false(anyDuplicated(
    nhanes_measure_data_wear_criteria[, c("SEQN", "criterion")]
  ) > 0)
})

test_that("every wear criterion maps to valid quantiles", {
  data <- reference_data[c(1, 3, 5), ]
  criteria <- nhanes_pa_wear_criteria()

  for (i in seq_len(nrow(criteria))) {
    result <- map_nhanes_pa_quantiles(
      data,
      min_wear_minutes = criteria$min_wear_minutes[i],
      min_valid_days = criteria$min_valid_days[i]
    )
    q <- result$nhanes_quantile
    expect_true(all(!is.na(q) & q >= 0 & q <= 1), label = criteria$criterion[i])
  }

  expect_true(is.function(nhanes_pa_measure_cdf("mims", age = 25, sex = "Male",
                                                wave = 8, min_wear_minutes = 600,
                                                min_valid_days = 1)))
  expect_false(is.na(nhanes_pa_quantile(15000, age = 25, sex = "Female",
                                        measure = "mims",
                                        min_wear_minutes = 1440,
                                        min_valid_days = 4)))
})

test_that("criteria change quantiles and use criterion-specific weights", {
  lenient <- map_nhanes_pa_quantiles(reference_data, min_wear_minutes = 600,
                                     min_valid_days = 1)$nhanes_quantile
  strict <- map_nhanes_pa_quantiles(reference_data, min_wear_minutes = 1440,
                                    min_valid_days = 4)$nhanes_quantile
  default <- map_nhanes_pa_quantiles(reference_data)$nhanes_quantile
  expect_false(isTRUE(all.equal(lenient, default)))
  expect_false(isTRUE(all.equal(strict, default)))

  # The criterion subset is used on its own, with its own weights
  sub <- mapnhanespa:::.nhanes_pa_criterion_data("wear600_days4")
  expect_equal(unique(sub$criterion), "wear600_days4")
  sub <- sub[sub$cat_age == "[20,30)" & sub$gender == "Female", ]
  sub$value <- sub$PAXMTSM
  f <- mapnhanespa:::run_cdf(sub)
  expect_equal(
    nhanes_pa_quantile(14000, age = 25, sex = "Female", measure = "mims",
                       min_wear_minutes = 600, min_valid_days = 4),
    f(14000)
  )
})

test_that("wear1368_days3 is near-identical to the default data", {
  crit <- mapnhanespa:::.nhanes_pa_criterion_data("wear1368_days3")
  expect_equal(nrow(crit), length(unique(nhanes_measure_data$SEQN)))
  expect_setequal(crit$SEQN, unique(nhanes_measure_data$SEQN))

  # Only two participants differ (missing PAXFLGSM flags on PhysioNet)
  orig <- nhanes_measure_data[nhanes_measure_data$measure == "PAXMTSM", ]
  orig <- orig[match(crit$SEQN, orig$SEQN), ]
  differ <- crit$SEQN[abs(crit$PAXMTSM - orig$value) > 1e-8 |
                        crit$num_valid_days != orig$num_valid_days]
  expect_setequal(differ, c("69762", "80584"))

  keys <- mapnhanespa:::.nhanes_pa_cdf_keys(by_wave = FALSE)
  keys <- keys[keys$cat_age %in% c("[20,30)", "[60,70)", "Overall"), ]
  diffs <- unlist(lapply(seq_len(nrow(keys)), function(i) {
    k <- keys[i, ]
    vals <- nhanes_measure_data$value[nhanes_measure_data$measure == k$measure]
    pts <- stats::quantile(vals, c(0.1, 0.25, 0.5, 0.75, 0.9))
    a <- mapnhanespa:::.nhanes_pa_cdf_one(k$measure, k$cat_age, k$gender)
    b <- mapnhanespa:::.nhanes_pa_cdf_one(k$measure, k$cat_age, k$gender,
                                          criterion = "wear1368_days3")
    a(pts) - b(pts)
  }))
  expect_lt(max(abs(diffs)), 0.002)
})

test_that("invalid wear criteria fail with the allowed values", {
  data <- reference_data[1, ]

  expect_error(map_nhanes_pa_quantiles(data, min_wear_minutes = 1000),
               "600, 960, 1296, 1368, 1440")
  expect_error(map_nhanes_pa_quantiles(data, min_valid_days = 2),
               "`min_valid_days` must be one of 1, 3, 4")
  expect_error(map_nhanes_pa_quantiles(data, min_wear_minutes = c(600, 960)),
               "min_wear_minutes")
  expect_error(map_nhanes_pa_quantiles(data, min_wear_minutes = NA),
               "min_wear_minutes")
  expect_error(map_nhanes_pa_quantiles(data, min_valid_days = "3"),
               "min_valid_days")
  expect_error(nhanes_pa_quantile(15000, measure = "mims", min_valid_days = 7),
               "nhanes_pa_wear_criteria")
  expect_error(nhanes_pa_measure_cdf("mims", min_wear_minutes = 1),
               "min_wear_minutes")
  expect_error(precompute_nhanes_pa_cdfs(min_wear_minutes = 1),
               "min_wear_minutes")
})

test_that("the CDF cache keeps wear criteria separate", {
  cache <- mapnhanespa:::.nhanes_pa_cache
  cache$clear_cdf()

  default_q <- nhanes_pa_quantile(14000, age = 25, sex = "Female",
                                  measure = "mims")
  expect_equal(cache$size(), 1L)
  strict_q <- nhanes_pa_quantile(14000, age = 25, sex = "Female",
                                 measure = "mims", min_wear_minutes = 1440,
                                 min_valid_days = 4)
  expect_equal(cache$size(), 2L)
  same_1368 <- mapnhanespa:::.nhanes_pa_cdf_one("PAXMTSM", "[20,30)", "Female",
                                                criterion = "wear1368_days3")
  expect_equal(cache$size(), 3L)
  expect_false(isTRUE(all.equal(default_q, strict_q)))

  # Re-querying after other criteria are cached returns each criterion's CDF
  expect_identical(nhanes_pa_quantile(14000, age = 25, sex = "Female",
                                      measure = "mims"), default_q)
  expect_identical(nhanes_pa_quantile(14000, age = 25, sex = "Female",
                                      measure = "mims", min_wear_minutes = 1440,
                                      min_valid_days = 4), strict_q)
  expect_equal(cache$size(), 3L)

  # Every criterion has the same key grid as the default, and tables for
  # different criteria are cached side by side
  for (by_wave in c(FALSE, TRUE)) {
    expect_identical(
      mapnhanespa:::.nhanes_pa_cdf_keys(by_wave, criterion = "wear600_days1"),
      mapnhanespa:::.nhanes_pa_cdf_keys(by_wave)
    )
  }
  cache$clear_cdf()
  keys <- data.frame(measure = c("mims", "AC"), data_release_cycle = 7,
                     cat_age = "[30,40)", gender = "Male")
  default_tab <- mapnhanespa:::.nhanes_pa_cdf_table(TRUE, keys)
  crit_tab <- mapnhanespa:::.nhanes_pa_cdf_table(TRUE, keys,
                                                 criterion = "wear600_days1")
  expect_equal(cache$size(), 4L)
  expect_false(isTRUE(all.equal(default_tab$cdf[[1]](14000),
                                crit_tab$cdf[[1]](14000))))
})
