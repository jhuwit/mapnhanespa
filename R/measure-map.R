#' Supported physical activity measure names
#'
#' Returns every accepted measure name and the NHANES summary used to build
#' its CDF. Matching ignores case, spaces, underscores, and punctuation.
#' Measures absent from this table have no supported CDF.
#'
#' @return A data frame with `measure` (accepted name) and `summary` (the
#'   measure in `nhanes_measure_data` used for its CDF).
#' @export
nhanes_pa_measure_map <- function() {
  aliases <- list(
    AC = c("AC", "activity_counts", "activitycounts", "counts", "total_AC",
           "total_activity_counts"),
    log10AC = c("log10AC", "log10_activity_counts", "log10_counts", "total_log10AC"),
    PAXMTSM = c("PAXMTSM", "mims", "mims_unit", "total_PAXMTSM"),
    log10PAXMTSM = c("log10PAXMTSM", "log10_mims", "total_log10PAXMTSM",
                     "log10_mims_unit"),
    scsslsteps = c("scsslsteps", "ssl_steps", "sslstepcount", "sslstepcounts",
                   "total_ssl_steps", "total_scsslsteps", "steps_stepcount_ssl",
                   "steps_stepcounts_ssl"),
    scrfsteps = c("scrfsteps", "rf_steps", "rfstepcount", "rfstepcounts",
                  "total_rf_steps", "total_scrfsteps", "steps_stepcount_rf",
                  "steps_stepcounts_rf"),
    oaksteps = c("oaksteps", "foreststeps", "steps_oak", "steps_forest",
                 "nsteps_oak", "nsteps_forest", "total_oaksteps",
                 "steps_stepcount_forest", "steps_stepcounts_forest"),
    vssteps = c("vssteps", "vssteps_original", "steps_vs_original",
                "total_vssteps"),
    vsrevsteps = c("vsrevsteps", "vssteps_revised", "steps_vs_revised",
                   "total_vsrevsteps")
  )
  data.frame(
    measure = unlist(aliases, use.names = FALSE),
    summary = rep(names(aliases), lengths(aliases)),
    stringsAsFactors = FALSE
  )
}

#' Select the NHANES CDF for a measure
#'
#' Uses the explicit aliases in [nhanes_pa_measure_map()] to select the CDF
#' calculated from the corresponding summary in `nhanes_measure_data`.
#'
#' @param measure A single supported measure name.
#' @param age Age in years, or `NULL` for the overall age CDF.
#' @param sex Sex/gender, or `NULL` for the overall sex/gender CDF.
#' @param wave Optional NHANES wave (`7`, `8`, `"2011-2012"`, or `"2013-2014"`).
#' @param age_category Optional NHANES age category, used instead of `age`.
#' @return A CDF function, or `NA_real_` if no CDF is available.
#' @export
nhanes_pa_measure_cdf <- function(measure, age = NULL, sex = NULL,
                                  wave = NULL, age_category = NULL) {
  if (length(measure) != 1L) {
    stop("`measure` must have length one.", call. = FALSE)
  }
  summary <- .standardize_measure(measure)
  if (is.na(summary)) {
    .warn_unmapped_measures(measure)
    return(NA_real_)
  }
  category <- if (!is.null(age_category)) {
    as.character(age_category)
  } else if (is.null(age)) {
    "Overall"
  } else {
    nhanes_pa_age_category(age)
  }
  gender <- if (is.null(sex)) "Overall" else .standardize_gender(sex)
  cycle <- if (is.null(wave)) NULL else .standardize_wave(wave)
  if (length(category) != 1L || length(gender) != 1L ||
      (!is.null(cycle) && length(cycle) != 1L)) {
    stop("`age`, `sex`, `wave`, and `age_category` must be scalar.", call. = FALSE)
  }
  if (is.na(category) || is.na(gender) || (!is.null(cycle) && is.na(cycle))) {
    return(NA_real_)
  }
  .nhanes_pa_cdf_one(summary, category, gender, cycle)
}

.standardize_measure <- function(measure) {
  key <- gsub("[^a-z0-9]+", "", tolower(trimws(as.character(measure))))
  mapping <- nhanes_pa_measure_map()
  alias_key <- gsub("[^a-z0-9]+", "", tolower(mapping$measure))
  mapping <- mapping[!duplicated(alias_key), , drop = FALSE]
  alias_key <- alias_key[!duplicated(alias_key)]
  mapping$summary[match(key, alias_key)]
}

.warn_unmapped_measures <- function(measure) {
  missing <- unique(as.character(measure[is.na(.standardize_measure(measure))]))
  if (length(missing)) {
    missing[is.na(missing)] <- "NA"
    warning("No NHANES CDF mapping for measure(s): ",
            paste(shQuote(missing), collapse = ", "), call. = FALSE)
  }
  invisible(NULL)
}
