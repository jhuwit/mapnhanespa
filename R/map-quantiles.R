#' Map physical activity values to NHANES population quantiles
#'
#' `map_nhanes_pa_quantiles()` adds a population-level quantile column to a
#' participant-level data frame. Quantiles are evaluated from NHANES
#' accelerometer cumulative distribution functions stratified by age category,
#' sex/gender, measure, and optionally survey wave.
#'
#' @param data A data frame with one row per participant-measure observation.
#' @param age,sex,measure,value Column names in `data` containing age in years,
#'   sex/gender, physical activity measure, and observed value. Set `age = NULL`
#'   to use the age-overall CDFs. Set `sex = NULL` to use the sex/gender-overall
#'   CDFs. The package data do not include CDFs that are overall for both age and
#'   sex/gender.
#' @param id Optional participant identifier column name. The column is checked
#'   when supplied, but otherwise left unchanged.
#' @param wave Optional NHANES wave column name or scalar value. Supported values
#'   are `7`, `8`, `"2011-2012"`, and `"2013-2014"`. If `NULL`, the combined
#'   wave CDFs are used.
#' @param age_category Optional column name containing NHANES age categories
#'   such as `"[20,30)"` or `"Overall"`. When supplied, it is used instead of
#'   `age`.
#' @param quantile_col Name of the output quantile column.
#'
#' @return `data` with an added quantile column.
#' @export
#'
#' @examples
#' example_data <- data.frame(
#'   id = 1:2,
#'   age = c(25, 62),
#'   sex = c("Female", "Male"),
#'   measure = c("mims", "ssl_steps"),
#'   value = c(15000, 7500)
#' )
#'
#' map_nhanes_pa_quantiles(example_data)
#'
#' map_nhanes_pa_quantiles(example_data, sex = NULL)
#'
#' map_nhanes_pa_quantiles(example_data, age = NULL, wave = "2011-2012")
#' map_nhanes_pa_quantiles(example_data, age = NULL, sex = NULL)
#'
map_nhanes_pa_quantiles <- function(data,
                                    id = NULL,
                                    age = "age",
                                    sex = "sex",
                                    measure = "measure",
                                    value = "value",
                                    wave = NULL,
                                    age_category = NULL,
                                    quantile_col = "nhanes_quantile") {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  required <- c(measure, value)
  if (!is.null(id)) {
    required <- c(required, id)
  }
  if (is.null(age_category) && !is.null(age)) {
    required <- c(required, age)
  } else if (!is.null(age_category)) {
    required <- c(required, age_category)
  }
  if (!is.null(sex)) {
    required <- c(required, sex)
  }
  if (!is.null(wave) && length(wave) == 1 && is.character(wave) && wave %in% names(data)) {
    required <- c(required, wave)
  }
  missing_cols <- setdiff(unique(required), names(data))
  if (length(missing_cols) > 0) {
    stop(
      "Missing required column(s): ",
      paste(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }

  out <- data
  if (is.null(age_category) && !is.null(age)) {
    .warn_ages_over_85(
      data[[age]],
      id = if (is.null(id)) NULL else data[[id]]
    )
  }
  key <- data.frame(
    .row_id = seq_len(nrow(data)),
    measure = .standardize_measure(data[[measure]]),
    value = data[[value]],
    cat_age = if (is.null(age_category)) {
      if (is.null(age)) {
        rep("Overall", nrow(data))
      } else {
        nhanes_pa_age_category(data[[age]], warn = FALSE)
      }
    } else {
      as.character(data[[age_category]])
    },
    gender = if (is.null(sex)) {
      rep("Overall", nrow(data))
    } else {
      .standardize_gender(data[[sex]])
    },
    stringsAsFactors = FALSE
  )

  if (is.null(wave)) {
    key$data_release_cycle <- NA_integer_
    cdf_table <- .nhanes_pa_cdf_table(by_wave = FALSE)
    by_cols <- c("measure", "cat_age", "gender")
  } else {
    key$data_release_cycle <- .standardize_wave(.value_or_column(data, wave, nrow(data)))
    cdf_table <- .nhanes_pa_cdf_table(by_wave = TRUE)
    by_cols <- c("measure", "data_release_cycle", "cat_age", "gender")
  }

  matched <- dplyr::left_join(
    key,
    cdf_table,
    by = by_cols
  )
  matched <- matched[order(matched$.row_id), , drop = FALSE]

  out[[quantile_col]] <- mapply(
    .evaluate_cdf,
    matched$cdf,
    matched$value,
    SIMPLIFY = TRUE,
    USE.NAMES = FALSE
  )

  out
}

#' Evaluate a single NHANES physical activity quantile
#'
#' @param value Observed physical activity value.
#' @param age Age in years. Set to `NULL` to use the age-overall CDFs. Ignored
#'   when `age_category` is supplied.
#' @param sex Sex/gender. Common values such as `"M"`, `"male"`, `"F"`, and
#'   `"female"` are normalized. Set to `NULL` to use the sex/gender-overall CDFs.
#' @param measure Physical activity measure. Supported aliases include
#'   `"mims"`, `"PAXMTSM"`, `"ssl_steps"`, `"scsslsteps"`, `"steps"`,
#'   Verisense step aliases such as `"steps_stepcount_ssl"`,
#'   `"steps_stepcount_rf"`, `"steps_vs_original"`, `"steps_vs_revised"`,
#'   `"steps_sdt"`, and `"AC"`.
#' @param wave Optional NHANES wave. Supported values are `7`, `8`,
#'   `"2011-2012"`, and `"2013-2014"`.
#' @param age_category Optional NHANES age category such as `"[20,30)"` or
#'   `"Overall"`.
#'
#' @return A numeric quantile in `[0, 1]`, or `NA_real_` when no matching CDF is
#'   available.
#' @export
#'
#' @examples
#' nhanes_pa_quantile(
#'   value = 15000,
#'   age = 25,
#'   sex = "Female",
#'   measure = "mims"
#' )
#'
#' nhanes_pa_quantile(
#'   value = 15000,
#'   age = 25,
#'   sex = NULL,
#'   measure = "mims",
#'   wave = "2013-2014"
#' )
nhanes_pa_quantile <- function(value,
                               age = NULL,
                               sex = NULL,
                               measure,
                               wave = NULL,
                               age_category = NULL) {
  data <- data.frame(
    age = if (is.null(age)) "Overall" else age,
    sex = if (is.null(sex)) "Overall" else sex,
    measure = measure,
    value = value,
    stringsAsFactors = FALSE
  )

  if (!is.null(wave)) {
    data$wave <- wave
  }
  if (!is.null(age_category)) {
    data$age_category <- age_category
  }

  result <- map_nhanes_pa_quantiles(
    data = data,
    age = if (is.null(age) && is.null(age_category)) NULL else "age",
    sex = if (is.null(sex)) NULL else "sex",
    measure = "measure",
    value = "value",
    wave = if (is.null(wave)) NULL else "wave",
    age_category = if (is.null(age_category)) NULL else "age_category"
  )

  result$nhanes_quantile
}

#' Convert ages to NHANES physical activity CDF age categories
#'
#' Ages are grouped into 10-year bins from `[0,10)` through `[70,80)`. Ages
#' greater than or equal to 80 are assigned to the oldest available CDF
#' category, `"[80,85)"`. Ages greater than 85 also map to `"[80,85)"`, with a
#' warning by default.
#'
#' @param age Numeric age in years.
#' @param warn Logical. If `TRUE`, warn when non-missing ages greater than 85
#'   are mapped into the `"[80,85)"` category.
#'
#' @return A character vector of NHANES age category labels.
#' @export
#'
#' @examples
#' nhanes_pa_age_category(c(8, 25, 84, 90))
nhanes_pa_age_category <- function(age, warn = TRUE) {
  age <- suppressWarnings(as.numeric(age))
  if (isTRUE(warn)) {
    .warn_ages_over_85(age)
  }
  labels <- c(
    "[0,10)", "[10,20)", "[20,30)", "[30,40)", "[40,50)",
    "[50,60)", "[60,70)", "[70,80)", "[80,85)"
  )
  out <- rep(NA_character_, length(age))
  ok <- !is.na(age) & age >= 0
  out[ok] <- labels[pmin(floor(age[ok] / 10) + 1, length(labels))]
  out
}

.warn_ages_over_85 <- function(age, id = NULL) {
  age <- suppressWarnings(as.numeric(age))
  over_85 <- which(!is.na(age) & age > 85)
  if (length(over_85) == 0) {
    return(invisible(NULL))
  }

  participant <- if (is.null(id)) {
    paste0("row ", over_85)
  } else {
    paste0("participant ", id[over_85])
  }

  warning(
    paste(
      paste(participant, "has age", age[over_85], "> 85"),
      collapse = "; "
    ),
    ". Mapping to age category [80,85).",
    call. = FALSE
  )
  invisible(NULL)
}


.evaluate_cdf <- function(cdf, value) {
  if (!is.function(cdf) || is.na(value)) {
    return(NA_real_)
  }
  as.numeric(cdf(value))
}

.nhanes_pa_cdf_table <- function(by_wave = FALSE) {
  if (by_wave) {
    cdf_tables <- list(
      AC = cdf_ac_bywave,
      PAXMTSM = cdf_mims_bywave,
      scsslsteps = cdf_ssl_steps_bywave,
      scrfsteps = cdf_rf_steps_bywave,
      oaksteps = cdf_forest_steps_bywave,
      vssteps = cdf_vs_original_steps_bywave,
      vsrevsteps = cdf_vs_revised_steps_bywave
    )
  } else {
    cdf_tables <- list(
      AC = cdf_ac,
      PAXMTSM = cdf_mims,
      scsslsteps = cdf_ssl_steps,
      scrfsteps = cdf_rf_steps,
      oaksteps = cdf_forest_steps,
      vssteps = cdf_vs_original_steps,
      vsrevsteps = cdf_vs_revised_steps
    )
  }

  tables <- Map(function(x, nm) {
    x$measure <- nm
    x
  }, cdf_tables, names(cdf_tables))

  do.call(rbind, tables)
}

.standardize_measure <- function(measure) {
  x <- trimws(as.character(measure))
  key <- gsub("[^a-z0-9]+", "", tolower(x))

  out <- rep(NA_character_, length(key))
  out[key %in% c("ac", "activitycounts", "counts", "totalac")] <- "AC"
  out[key %in% c("mims", "paxmtsm", "totalpaxmtsm", "mimsunit")] <- "PAXMTSM"
  out[key %in% c(
    "sslsteps", "scsslsteps",
    "totalsslsteps", "totalscsslsteps",
    "stepsstepcountssl",
    "steps_stepcount_ssl",
    "steps_stepcounts_ssl"
  )] <- "scsslsteps"
  out[key %in% c(
    "sslsteps", "scsslsteps", "sslstepcount", "sslstepcounts",
    "totalsslsteps", "totalscsslsteps",
    "stepsstepcountssl"
  )] <- "scsslsteps"
  out[key %in% c(
    "rfsteps", "scrfsteps", "rfstepcount", "rfstepcounts",
    "totalrfsteps", "totalscrfsteps",
    "stepsstepcountrf",
    "steps_stepcount_rf",
    "steps_stepcounts_rf"
  )] <- "scrfsteps"
  out[key %in% c(
    "oaksteps",
    "foreststeps",
    "stepsstepcountforest",
    "steps_stepcount_forest",
    "steps_stepcounts_forest"
  )] <- "oaksteps"
  out[key %in% c(
    "vssteps",
    "vsstepsoriginal",
    "stepsvsoriginal"
  )] <- "vssteps"
  out[key %in% c(
    "vsrevsteps",
    "vsstepsrevised",
    "stepsvsrevised"
  )] <- "vsrevsteps"
  out[key %in% c(
    "stepssdt"
  )] <- "sdtsteps"
  out
}

.standardize_gender <- function(gender) {
  x <- trimws(as.character(gender))
  key <- tolower(x)

  out <- rep(NA_character_, length(key))
  out[key %in% c("female", "f", "woman", "women", "2")] <- "Female"
  out[key %in% c("male", "m", "man", "men", "1")] <- "Male"
  out[key %in% c("overall", "all", "both", "total")] <- "Overall"
  out
}

.standardize_wave <- function(wave) {
  x <- trimws(as.character(wave))
  key <- gsub("[^0-9a-z]+", "", tolower(x))

  out <- suppressWarnings(as.integer(x))
  out[key %in% c("20112012", "2011to2012", "cycle7", "wave7")] <- 7L
  out[key %in% c("20132014", "2013to2014", "cycle8", "wave8")] <- 8L
  out
}

.value_or_column <- function(data, x, n) {
  if (length(x) == 1 && is.character(x) && x %in% names(data)) {
    return(data[[x]])
  }
  rep(x, length.out = n)
}

utils::globalVariables(c(
  "cdf_ac",
  "cdf_ac_bywave",
  "cdf_mims",
  "cdf_mims_bywave",
  "cdf_ssl_steps",
  "cdf_ssl_steps_bywave"
))
