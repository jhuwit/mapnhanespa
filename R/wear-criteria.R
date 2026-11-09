#' Available accelerometer wear-time inclusion criteria
#'
#' Lists the wear-time inclusion criteria that can be selected with the
#' `min_wear_minutes` and `min_valid_days` arguments of
#' [map_nhanes_pa_quantiles()], [nhanes_pa_quantile()],
#' [nhanes_pa_measure_cdf()], and [precompute_nhanes_pa_cdfs()]. Choose the
#' criterion that matches the inclusion rules used for your own data.
#'
#' A day is valid if it has at least `min_wear_minutes` minutes of
#' non-flagged wear (wake wear, sleep wear, or unknown), at least 420 minutes
#' of wake wear, and at least 420 minutes with non-zero MIMS. A participant is
#' included if they have at least `min_valid_days` valid days. Survey weights
#' were re-adjusted separately for each criterion.
#'
#' The default criterion (1,368 minutes, 3 days) uses [nhanes_measure_data],
#' the primary analysis of Koffman, Crainiceanu, and Muschelli (2025). Every
#' other criterion uses the matching subset of
#' [nhanes_measure_data_wear_criteria].
#'
#' @return A data frame with one row per criterion and columns:
#' \describe{
#'   \item{criterion}{criterion label, `"wear{min}_days{d}"`}
#'   \item{min_wear_minutes}{minimum minutes of wear for a valid day}
#'   \item{min_wear_hours}{`min_wear_minutes` in hours}
#'   \item{pct_of_day}{`min_wear_minutes` as a percentage of 1,440 minutes}
#'   \item{min_valid_days}{minimum number of valid days}
#'   \item{default}{`TRUE` for the package default criterion}
#'   \item{note}{short note on where the wear threshold is used}
#' }
#' @references
#' Troiano RP, Berrigan D, Dodd KW, Masse LC, Tilert T, McDowell M (2008).
#' Physical activity in the United States measured by accelerometer.
#' \emph{Medicine & Science in Sports & Exercise}, 40(1), 181-188.
#' \doi{10.1249/mss.0b013e31815a51b3}.
#'
#' Saint-Maurice PF, Troiano RP, Bassett DR, et al. (2020). Association of
#' daily step count and step intensity with mortality among US adults.
#' \emph{JAMA}, 323(12), 1151-1160. \doi{10.1001/jama.2020.1382}.
#'
#' Koffman L, Crainiceanu C, Muschelli J (2025). Comparing Step Counting
#' Algorithms for High-Resolution Wrist Accelerometry Data in NHANES
#' 2011-2014. \emph{Medicine & Science in Sports & Exercise}, 57(4), 746-755.
#' \doi{10.1249/MSS.0000000000003616}.
#' @export
#'
#' @examples
#' nhanes_pa_wear_criteria()
nhanes_pa_wear_criteria <- function() {
  wear <- c(600, 960, 1296, 1368, 1440)
  days <- c(1, 3, 4)
  notes <- c(
    "600" = paste(
      "10 h/day; NHANES 2003-2006 hip-worn standard (Troiano et al. 2008",
      "required >= 4 valid days; Saint-Maurice et al. 2020 JAMA required",
      ">= 1 valid day)"
    ),
    "960" = "16 h/day; used in 24-h wrist-worn protocols",
    "1296" = "21.6 h/day; 90% of a 24-h day",
    "1368" = paste(
      "22.8 h/day; 95% of a 24-h day; primary analysis",
      "(Koffman et al. 2025)"
    ),
    "1440" = "24 h/day; complete wear"
  )
  grid <- expand.grid(min_valid_days = days, min_wear_minutes = wear)
  data.frame(
    criterion = .wear_criterion_label(grid$min_wear_minutes, grid$min_valid_days),
    min_wear_minutes = grid$min_wear_minutes,
    min_wear_hours = grid$min_wear_minutes / 60,
    pct_of_day = round(100 * grid$min_wear_minutes / 1440, 1),
    min_valid_days = grid$min_valid_days,
    default = grid$min_wear_minutes == .default_min_wear_minutes &
      grid$min_valid_days == .default_min_valid_days,
    note = unname(notes[as.character(grid$min_wear_minutes)]),
    stringsAsFactors = FALSE
  )
}

.default_min_wear_minutes <- 1368
.default_min_valid_days <- 3

.wear_criterion_label <- function(min_wear_minutes, min_valid_days) {
  paste0("wear", min_wear_minutes, "_days", min_valid_days)
}

# Validate a wear-time criterion. Returns NULL for the package default, which
# uses `nhanes_measure_data`, or the criterion label used to subset
# `nhanes_measure_data_wear_criteria`.
.resolve_wear_criterion <- function(min_wear_minutes = .default_min_wear_minutes,
                                    min_valid_days = .default_min_valid_days) {
  criteria <- nhanes_pa_wear_criteria()
  .check_criterion_arg(min_wear_minutes, "min_wear_minutes",
                       unique(criteria$min_wear_minutes))
  .check_criterion_arg(min_valid_days, "min_valid_days",
                       unique(criteria$min_valid_days))
  if (min_wear_minutes == .default_min_wear_minutes &&
      min_valid_days == .default_min_valid_days) {
    return(NULL)
  }
  .wear_criterion_label(as.integer(min_wear_minutes), as.integer(min_valid_days))
}

.check_criterion_arg <- function(x, name, allowed) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) || !x %in% allowed) {
    stop(
      "`", name, "` must be one of ", paste(allowed, collapse = ", "),
      ". See nhanes_pa_wear_criteria().",
      call. = FALSE
    )
  }
  invisible(x)
}
