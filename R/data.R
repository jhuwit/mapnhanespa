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
#'   \item{num_valid_days}{number of valid days of wear >= 1396 minutes}
#'   \item{measure}{measure that was calculated}
#'   \item{value}{value for the measure}
#' }
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data.
"nhanes_measure_data"

