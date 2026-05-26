test_that("participant data are mapped with combined and wave CDFs", {
  data <- data.frame(
    id = c("A", "B"),
    age = c(25, 62),
    sex = c("Female", "Male"),
    measure = c("mims", "ssl_steps"),
    value = c(15000, 7500)
  )

  combined <- map_nhanes_pa_quantiles(data, id = "id")
  by_wave <- map_nhanes_pa_quantiles(data, id = "id", wave = "2013-2014")

  expect_true(all(!is.na(combined$nhanes_quantile)))
  expect_true(all(!is.na(by_wave$nhanes_quantile)))
  expect_false(identical(combined$nhanes_quantile, by_wave$nhanes_quantile))
})

test_that("participant data are mapped with combined and wave CDFs", {
  data <- dplyr::tribble(
    ~sex, ~age, ~measure,    ~value,
    "Female",   27,  "sslsteps",      5915,
    "Female",   27,     "ac", 1944555.8
  )


  combined <- map_nhanes_pa_quantiles(data)
  by_wave <- map_nhanes_pa_quantiles(data, wave = "2013-2014")

  expect_true(all(!is.na(combined$nhanes_quantile)))
  expect_true(all(!is.na(by_wave$nhanes_quantile)))
  expect_false(identical(combined$nhanes_quantile, by_wave$nhanes_quantile))
})

test_that("overall age and sex strata are supported when present", {
  data <- data.frame(
    id = 1:2,
    age = c(25, 62),
    sex = c("Female", "Male"),
    measure = c("PAXMTSM", "scsslsteps"),
    value = c(15000, 7500)
  )

  sex_overall <- map_nhanes_pa_quantiles(data, sex = NULL)
  age_overall <- map_nhanes_pa_quantiles(data, age = NULL, wave = 7)

  expect_true(all(!is.na(sex_overall$nhanes_quantile)))
  expect_true(all(!is.na(age_overall$nhanes_quantile)))
})

test_that("age category input bypasses age bucketing", {
  data <- data.frame(
    age_group = c("[20,30)", "Overall"),
    sex = c("Overall", "Female"),
    measure = c("mims", "mims"),
    value = c(15000, 15000)
  )

  result <- map_nhanes_pa_quantiles(
    data,
    age_category = "age_group",
    sex = "sex"
  )

  expect_true(all(!is.na(result$nhanes_quantile)))
})

test_that("invalid inputs fail clearly", {
  data <- data.frame(
    age = 25,
    sex = "Female",
    measure = "mims",
    value = 15000
  )

  expect_error(map_nhanes_pa_quantiles("not data"), "data frame")
  expect_error(map_nhanes_pa_quantiles(data, id = "id"), "Missing required")
  expect_error(map_nhanes_pa_quantiles(data, age = "years"), "Missing required")
  expect_error(
    map_nhanes_pa_quantiles(data, age_category = "age_group"),
    "Missing required"
  )
  expect_error(map_nhanes_pa_quantiles(data, sex = "gender"), "Missing required")
  expect_true(is.na(map_nhanes_pa_quantiles(data, wave = "cycle")$nhanes_quantile))
  # expect_error(
  #   map_nhanes_pa_quantiles(data, age = NULL, sex = NULL),
  #   "overall for both age and sex/gender"
  # )
})

test_that("ages greater than 85 warn but map to oldest category", {
  data <- data.frame(
    id = "P1",
    age = 90,
    sex = "Female",
    measure = "AC",
    value = 1000000
  )

  expect_warning(
    result <- map_nhanes_pa_quantiles(data, id = "id"),
    "participant P1 has age 90 > 85"
  )
  expect_false(is.na(result$nhanes_quantile))

  expect_warning(
    categories <- nhanes_pa_age_category(c(8, 25, 84, 90)),
    "row 4 has age 90 > 85"
  )
  expect_equal(categories, c("[0,10)", "[20,30)", "[80,85)", "[80,85)"))
})

test_that("scalar quantile helper supports all lookup modes", {
  expect_false(is.na(nhanes_pa_quantile(15000, age = 25, sex = "Female", measure = "mims")))
  expect_false(is.na(nhanes_pa_quantile(15000, age = 25, sex = NULL, measure = "mims")))
  expect_false(is.na(nhanes_pa_quantile(15000, age = NULL, sex = "Female", measure = "mims")))
  expect_false(is.na(nhanes_pa_quantile(
    15000,
    age = NULL,
    sex = "Female",
    measure = "mims",
    wave = "2011-2012"
  )))
  expect_false(is.na(nhanes_pa_quantile(
    15000,
    age_category = "Overall",
    sex = "Female",
    measure = "mims",
    wave = "2013-2014"
  )))
  expect_equal(
    nhanes_pa_quantile(15000, age = NULL, sex = NULL, measure = "mims"),
    0.562398771709386
  )
})

test_that("internal CDF evaluation handles missing matches and missing values", {
  f <- mapnhanespa:::.nhanes_pa_cdf_table(
    FALSE,
    data.frame(
      measure = "PAXMTSM",
      cat_age = "[20,30)",
      gender = "Female",
      stringsAsFactors = FALSE
    )
  )$cdf[[1]]

  expect_equal(mapnhanespa:::.evaluate_cdf(NULL, 15000), NA_real_)
  expect_equal(mapnhanespa:::.evaluate_cdf(f, NA_real_), NA_real_)
  expect_false(is.na(mapnhanespa:::.evaluate_cdf(f, 15000)))
})

test_that("CDF table helper returns combined and wave-specific keys", {
  combined <- mapnhanespa:::.nhanes_pa_cdf_table(FALSE)
  by_wave <- mapnhanespa:::.nhanes_pa_cdf_table(TRUE)

  expect_setequal(
    unique(combined$measure),
    c("AC", "PAXMTSM", "scsslsteps", "scrfsteps", "oaksteps", "vssteps", "vsrevsteps")
  )
  expect_setequal(
    unique(by_wave$measure),
    c("AC", "PAXMTSM", "scsslsteps", "scrfsteps", "oaksteps", "vssteps", "vsrevsteps")
  )
  expect_setequal(unique(by_wave$data_release_cycle), c(7, 8))
})

test_that("precompute warms the cache for all supported CDFs", {
  mapnhanespa:::.nhanes_pa_cache$clear_cdf()

  result <- precompute_nhanes_pa_cdfs()
  measures <- unique(mapnhanespa:::.standardize_measure(nhanes_measure_data$measure))
  ages <- unique(c(sort(unique(as.character(nhanes_measure_data$cat_age))), "Overall"))
  genders <- unique(c(sort(unique(mapnhanespa:::.standardize_gender(nhanes_measure_data$gender))), "Overall"))
  waves <- sort(unique(nhanes_measure_data$data_release_cycle))

  expect_equal(
    nrow(result$combined),
    length(measures) * length(ages) * length(genders)
  )
  expect_equal(
    nrow(result$by_wave),
    length(measures) * length(waves) * length(ages) * length(genders)
  )
  expect_equal(
    mapnhanespa:::.nhanes_pa_cache$size(),
    nrow(result$combined) + nrow(result$by_wave)
  )

  cached_size <- mapnhanespa:::.nhanes_pa_cache$size()
  result_again <- precompute_nhanes_pa_cdfs()

  expect_equal(mapnhanespa:::.nhanes_pa_cache$size(), cached_size)
  expect_equal(nrow(result_again$combined), nrow(result$combined))
  expect_equal(nrow(result_again$by_wave), nrow(result$by_wave))
})

test_that("standardization helpers normalize common aliases", {
  values = c(
    "AC", "activity counts", "counts", "total_AC",
    "mims", "PAXMTSM", "total_PAXMTSM",
    "ssl_steps", "scsslsteps", "steps", "ssl step count", "ssl step counts",
    "total_ssl_steps", "total_scsslsteps",
    "steps_stepcount_ssl", "steps_stepcount_rf",
    "oaksteps", "steps_stepcount_forest",
    "steps_vs_original", "steps_vs_revised", "vssteps", "vsrevsteps",
    "steps_sdt",
    "unknown"
  )
  expect_equal(
    mapnhanespa:::.standardize_measure(values),
    c(
      "AC", "AC", "AC", "AC",
      "PAXMTSM", "PAXMTSM", "PAXMTSM",
      "scsslsteps", "scsslsteps", NA, "scsslsteps", "scsslsteps",
      "scsslsteps", "scsslsteps", "scsslsteps",
       "scrfsteps", "oaksteps", "oaksteps",
       "vssteps", "vsrevsteps", "vssteps", "vsrevsteps", "sdtsteps",
      NA
    )
  )

  expect_equal(
    mapnhanespa:::.standardize_gender(c(
      "female", "F", "woman", "women", "2",
      "male", "M", "man", "men", "1",
      "overall", "all", "both", "total", "unknown"
    )),
    c(
      rep("Female", 5),
      rep("Male", 5),
      rep("Overall", 4),
      NA
    )
  )

  expect_equal(
    mapnhanespa:::.standardize_wave(c(
      "7", "8", "2011-2012", "2011 to 2012", "cycle 7", "wave 7",
      "2013-2014", "2013 to 2014", "cycle 8", "wave 8", "bad"
    )),
    c(7L, 8L, 7L, 7L, 7L, 7L, 8L, 8L, 8L, 8L, NA_integer_)
  )
})

test_that("value_or_column returns columns or recycled scalar values", {
  data <- data.frame(wave = c(7, 8))

  expect_equal(mapnhanespa:::.value_or_column(data, "wave", 2), c(7, 8))
  expect_equal(mapnhanespa:::.value_or_column(data, "2011-2012", 2), rep("2011-2012", 2))
})
