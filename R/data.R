#' NHANES PA data
#'
#'
#' @format A data frame with 87619 rows and 9 variables:
#' \describe{
#'   \item{SEQN}{ID variable}
#'   \item{data_release_cycle}{wave/data release cycle}
#'   \item{cat_age}{age category}
#'   \item{gender}{sex/gender designation}
#'   \item{wtmec4yr_adj_norm}{normalized weight for surveys}
#'   \item{masked_variance_pseudo_psu}{PSU - sampling unit}
#'   \item{masked_variance_pseudo_stratum}{sampling stratum}
#'   \item{num_valid_days}{number of valid days of wear (e.g. 1368 minutes, see Details)}
#'   \item{measure}{measure that was calculated}
#'   \item{value}{value for the measure}
#' }
#' @details
#' Valid days are defined as in Koffman, Crainiceanu, and Muschelli (2025).
#' A day is valid if (1) at least 1,368 minutes (95% of a full day) were
#' classified as wake wear, sleep wear, or unknown and had no data quality
#' flags; (2) at least 420 minutes were classified as wake wear; and (3) at
#' least 420 minutes had non-zero MIMS. Only participants with at least
#' 3 valid days are included.
#' @references
#' Koffman L, Crainiceanu C, Muschelli J (2025). Comparing Step Counting
#' Algorithms for High-Resolution Wrist Accelerometry Data in NHANES
#' 2011-2014. \emph{Medicine & Science in Sports & Exercise}, 57(4), 746-755.
#' \doi{10.1249/MSS.0000000000003616}. PMID: 39589008,
#' \url{https://pubmed.ncbi.nlm.nih.gov/39589008/}.
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data.
"nhanes_measure_data"


#' NHANES PA data under alternative wear-time inclusion criteria
#'
#' Participant-level NHANES 2011-2014 physical activity summaries computed
#' under 15 accelerometer wear-time inclusion criteria: every combination of
#' a minimum of 600, 960, 1296, 1368, or 1440 wear minutes per valid day and a
#' minimum of 1, 3, or 4 valid days. Use [nhanes_pa_wear_criteria()] to list
#' the criteria and select one with the `min_wear_minutes` and
#' `min_valid_days` arguments of the mapping functions.
#'
#' The data are stored wide, with one row per participant and criterion and
#' one column per summary, to keep the package small.
#'
#' @format A data frame with 193114 rows and 18 variables:
#' \describe{
#'   \item{SEQN}{ID variable}
#'   \item{criterion}{wear-time criterion, `"wear{min}_days{d}"`, e.g.
#'     `"wear1368_days3"`. See [nhanes_pa_wear_criteria()].}
#'   \item{data_release_cycle}{wave/data release cycle}
#'   \item{cat_age}{age category}
#'   \item{gender}{sex/gender designation}
#'   \item{wtmec4yr_adj_norm}{normalized survey weight, adjusted separately
#'     within each criterion}
#'   \item{masked_variance_pseudo_psu}{PSU - sampling unit}
#'   \item{masked_variance_pseudo_stratum}{sampling stratum}
#'   \item{num_valid_days}{number of valid days under the criterion}
#'   \item{AC, log10AC, PAXMTSM, log10PAXMTSM, oaksteps, scrfsteps,
#'     scsslsteps, vsrevsteps, vssteps}{values for each summary, as in the
#'     `measure` and `value` columns of [nhanes_measure_data]}
#' }
#' @details
#' A day is valid if (1) at least `min_wear_minutes` minutes were classified
#' as wake wear, sleep wear, or unknown and had no data quality flags; (2) at
#' least 420 minutes were classified as wake wear; and (3) at least 420
#' minutes had non-zero MIMS. A participant is included under a criterion if
#' they have at least `min_valid_days` valid days. Survey weights were
#' re-adjusted for each criterion, so rows from different criteria should
#' never be combined.
#'
#' The `"wear1368_days3"` criterion matches [nhanes_measure_data], except for
#' two participants (SEQN 69762 and 80584) who each differ by one valid day.
#' This is because the PhysioNet `PAXFLGSM` quality-flag file omits some flags
#' present in the original NHANES data. The package default
#' (`min_wear_minutes = 1368`, `min_valid_days = 3`) therefore continues to use
#' [nhanes_measure_data], so earlier results are unchanged.
#' @references
#' Koffman L, Crainiceanu C, Muschelli J (2025). Comparing Step Counting
#' Algorithms for High-Resolution Wrist Accelerometry Data in NHANES
#' 2011-2014. \emph{Medicine & Science in Sports & Exercise}, 57(4), 746-755.
#' \doi{10.1249/MSS.0000000000003616}.
#'
#' Koffman L, Muschelli J (2025). Minute Level Step Counts and Physical
#' Activity Data from the National Health and Nutrition Examination Survey
#' (NHANES) 2011-2014 (version 1.0.1). \emph{PhysioNet}.
#' \doi{10.13026/9n0r-tv02}.
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data, via PhysioNet.
"nhanes_measure_data_wear_criteria"
