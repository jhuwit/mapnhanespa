#' NHANES PA data
#'
#'
#' @format A data frame with 87619 rows and 9 variables:
#' \describe{
#'   \item{SEQN}{ID variable}
#'   \item{data_release_cycle}{wave/data release cycle}
#'   \item{cat_age}{age category}
#'   \item{gender}{sex/gender desigination}
#'   \item{wtmec4yr_adj_norm}{normalized weight for surveys}
#'   \item{masked_variance_pseudo_psu}{PSU - sampling unit}
#'   \item{masked_variance_pseudo_stratum}{sampling stratum}
#'   \item{measure}{measure that was calculated}
#'   \item{value}{value for the measure}
#' }
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data.
"nhanes_measure_data"



#' NHANES activity count cumulative distribution functions
#'
#' Cumulative distribution functions for NHANES physical activity counts,
#' stratified by age category and sex/gender across the combined 2011-2012 and
#' 2013-2014 waves.
#'
#' @format A data frame with 30 rows and 3 variables:
#' \describe{
#'   \item{cat_age}{NHANES age category.}
#'   \item{gender}{Gender stratum: `"Female"`, `"Male"`, or `"Overall"`.}
#'   \item{cdf}{A `stepfun` cumulative distribution function.}
#' }
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data.
"cdf_ac"

#' NHANES MIMS cumulative distribution functions
#'
#' Cumulative distribution functions for Monitor-Independent Movement Summary
#' (MIMS) units, stratified by age category and sex/gender across the combined
#' 2011-2012 and 2013-2014 NHANES waves.
#'
#' @format A data frame with 30 rows and 3 variables:
#' \describe{
#'   \item{cat_age}{NHANES age category.}
#'   \item{gender}{Gender stratum: `"Female"`, `"Male"`, or `"Overall"`.}
#'   \item{cdf}{A `stepfun` cumulative distribution function.}
#' }
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data.
"cdf_mims"

#' NHANES SSL step cumulative distribution functions
#'
#' Cumulative distribution functions for SSL step counts, stratified by age
#' category and sex/gender across the combined 2011-2012 and 2013-2014 NHANES
#' waves.
#'
#' @format A data frame with 30 rows and 3 variables:
#' \describe{
#'   \item{cat_age}{NHANES age category.}
#'   \item{gender}{Gender stratum: `"Female"`, `"Male"`, or `"Overall"`.}
#'   \item{cdf}{A `stepfun` cumulative distribution function.}
#' }
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data.
"cdf_ssl_steps"

#' NHANES RF step cumulative distribution functions
#'
#' Cumulative distribution functions for Verisense RF step counts, stratified
#' by age category and sex/gender across the combined 2011-2012 and 2013-2014
#' NHANES waves.
#'
#' @format A data frame with 30 rows and 3 variables:
#' \describe{
#'   \item{cat_age}{NHANES age category.}
#'   \item{gender}{Gender stratum: `"Female"`, `"Male"`, or `"Overall"`.}
#'   \item{cdf}{A `stepfun` cumulative distribution function.}
#' }
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data.
"cdf_rf_steps"

#' NHANES forest step cumulative distribution functions
#'
#' Cumulative distribution functions for Verisense forest step counts,
#' stratified by age category and sex/gender across the combined 2011-2012 and
#' 2013-2014 NHANES waves.
#'
#' @format A data frame with 30 rows and 3 variables:
#' \describe{
#'   \item{cat_age}{NHANES age category.}
#'   \item{gender}{Gender stratum: `"Female"`, `"Male"`, or `"Overall"`.}
#'   \item{cdf}{A `stepfun` cumulative distribution function.}
#' }
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data.
"cdf_forest_steps"

#' NHANES Verisense original step cumulative distribution functions
#'
#' Cumulative distribution functions for Verisense original step counts,
#' stratified by age category and sex/gender across the combined 2011-2012 and
#' 2013-2014 NHANES waves.
#'
#' @format A data frame with 30 rows and 3 variables:
#' \describe{
#'   \item{cat_age}{NHANES age category.}
#'   \item{gender}{Gender stratum: `"Female"`, `"Male"`, or `"Overall"`.}
#'   \item{cdf}{A `stepfun` cumulative distribution function.}
#' }
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data.
"cdf_vs_original_steps"

#' NHANES Verisense revised step cumulative distribution functions
#'
#' Cumulative distribution functions for Verisense revised step counts,
#' stratified by age category and sex/gender across the combined 2011-2012 and
#' 2013-2014 NHANES waves.
#'
#' @format A data frame with 30 rows and 3 variables:
#' \describe{
#'   \item{cat_age}{NHANES age category.}
#'   \item{gender}{Gender stratum: `"Female"`, `"Male"`, or `"Overall"`.}
#'   \item{cdf}{A `stepfun` cumulative distribution function.}
#' }
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data.
"cdf_vs_revised_steps"

#' NHANES activity count cumulative distribution functions by wave
#'
#' Cumulative distribution functions for NHANES physical activity counts,
#' stratified by survey wave, age category, and sex/gender.
#'
#' @format A data frame with 60 rows and 4 variables:
#' \describe{
#'   \item{data_release_cycle}{NHANES data release cycle, where `7`
#'     corresponds to 2011-2012 and `8` corresponds to 2013-2014.}
#'   \item{cat_age}{NHANES age category.}
#'   \item{gender}{Gender stratum: `"Female"`, `"Male"`, or `"Overall"`.}
#'   \item{cdf}{A `stepfun` cumulative distribution function.}
#' }
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data.
"cdf_ac_bywave"

#' NHANES MIMS cumulative distribution functions by wave
#'
#' Cumulative distribution functions for Monitor-Independent Movement Summary
#' (MIMS) units, stratified by survey wave, age category, and sex/gender.
#'
#' @format A data frame with 60 rows and 4 variables:
#' \describe{
#'   \item{data_release_cycle}{NHANES data release cycle, where `7`
#'     corresponds to 2011-2012 and `8` corresponds to 2013-2014.}
#'   \item{cat_age}{NHANES age category.}
#'   \item{gender}{Gender stratum: `"Female"`, `"Male"`, or `"Overall"`.}
#'   \item{cdf}{A `stepfun` cumulative distribution function.}
#' }
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data.
"cdf_mims_bywave"

#' NHANES SSL step cumulative distribution functions by wave
#'
#' Cumulative distribution functions for SSL step counts, stratified by survey
#' wave, age category, and sex/gender.
#'
#' @format A data frame with 60 rows and 4 variables:
#' \describe{
#'   \item{data_release_cycle}{NHANES data release cycle, where `7`
#'     corresponds to 2011-2012 and `8` corresponds to 2013-2014.}
#'   \item{cat_age}{NHANES age category.}
#'   \item{gender}{Gender stratum: `"Female"`, `"Male"`, or `"Overall"`.}
#'   \item{cdf}{A `stepfun` cumulative distribution function.}
#' }
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data.
"cdf_ssl_steps_bywave"

#' NHANES RF step cumulative distribution functions by wave
#'
#' Cumulative distribution functions for Verisense RF step counts, stratified
#' by survey wave, age category, and sex/gender.
#'
#' @format A data frame with 60 rows and 4 variables:
#' \describe{
#'   \item{data_release_cycle}{NHANES data release cycle, where `7`
#'     corresponds to 2011-2012 and `8` corresponds to 2013-2014.}
#'   \item{cat_age}{NHANES age category.}
#'   \item{gender}{Gender stratum: `"Female"`, `"Male"`, or `"Overall"`.}
#'   \item{cdf}{A `stepfun` cumulative distribution function.}
#' }
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data.
"cdf_rf_steps_bywave"

#' NHANES forest step cumulative distribution functions by wave
#'
#' Cumulative distribution functions for Verisense forest step counts,
#' stratified by survey wave, age category, and sex/gender.
#'
#' @format A data frame with 60 rows and 4 variables:
#' \describe{
#'   \item{data_release_cycle}{NHANES data release cycle, where `7`
#'     corresponds to 2011-2012 and `8` corresponds to 2013-2014.}
#'   \item{cat_age}{NHANES age category.}
#'   \item{gender}{Gender stratum: `"Female"`, `"Male"`, or `"Overall"`.}
#'   \item{cdf}{A `stepfun` cumulative distribution function.}
#' }
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data.
"cdf_forest_steps_bywave"

#' NHANES Verisense original step cumulative distribution functions by wave
#'
#' Cumulative distribution functions for Verisense original step counts,
#' stratified by survey wave, age category, and sex/gender.
#'
#' @format A data frame with 60 rows and 4 variables:
#' \describe{
#'   \item{data_release_cycle}{NHANES data release cycle, where `7`
#'     corresponds to 2011-2012 and `8` corresponds to 2013-2014.}
#'   \item{cat_age}{NHANES age category.}
#'   \item{gender}{Gender stratum: `"Female"`, `"Male"`, or `"Overall"`.}
#'   \item{cdf}{A `stepfun` cumulative distribution function.}
#' }
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data.
"cdf_vs_original_steps_bywave"

#' NHANES Verisense revised step cumulative distribution functions by wave
#'
#' Cumulative distribution functions for Verisense revised step counts,
#' stratified by survey wave, age category, and sex/gender.
#'
#' @format A data frame with 60 rows and 4 variables:
#' \describe{
#'   \item{data_release_cycle}{NHANES data release cycle, where `7`
#'     corresponds to 2011-2012 and `8` corresponds to 2013-2014.}
#'   \item{cat_age}{NHANES age category.}
#'   \item{gender}{Gender stratum: `"Female"`, `"Male"`, or `"Overall"`.}
#'   \item{cdf}{A `stepfun` cumulative distribution function.}
#' }
#' @source NHANES 2011-2012 and 2013-2014 accelerometer data.
"cdf_vs_revised_steps_bywave"
