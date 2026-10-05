
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mapnhanespa

<!-- badges: start -->

[![R-CMD-check](https://github.com/jhuwit/mapnhanespa/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jhuwit/mapnhanespa/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/jhuwit/mapnhanespa/graph/badge.svg)](https://app.codecov.io/gh/jhuwit/mapnhanespa)
[![CRAN
status](https://www.r-pkg.org/badges/version/mapnhanespa)](https://CRAN.R-project.org/package=mapnhanespa)
<!-- badges: end -->

`mapnhanespa` maps physical activity summaries from a study sample onto
population-level quantiles estimated from NHANES accelerometer data.

## Installation

You can install the development version of mapnhanespa from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("jhuwit/mapnhanespa")
```

## Example

Map one row per participant-measure observation with
`map_nhanes_pa_quantiles()`:

``` r
library(mapnhanespa)

study_data <- data.frame(
  id = c("P01", "P02", "P03"),
  age = c(25, 62, 84),
  sex = c("Female", "Male", "Female"),
  measure = c("mims", "ssl_steps", "AC"),
  value = c(15000, 7500, 1000000)
)

map_nhanes_pa_quantiles(study_data, id = "id")
#>    id age    sex   measure   value age_category_pa_map nhanes_quantile
#> 1 P01  25 Female      mims   15000             [20,30)       0.5349443
#> 2 P02  62   Male ssl_steps    7500             [60,70)       0.3527381
#> 3 P03  84 Female        AC 1000000             [80,85)       0.1322205
```

The returned `age_category_pa_map` column shows the NHANES age category
used to select each participant’s CDF. The following example covers all
nine supported summaries:

``` r
all_measures <- data.frame(
  id = rep("P01", 9),
  age = 25,
  sex = "Female",
  measure = c("total_activity_counts", "total_log10AC", "total_PAXMTSM",
              "total_log10PAXMTSM", "total_scsslsteps", "total_scrfsteps",
              "total_oaksteps", "total_vssteps", "total_vsrevsteps"),
  value = c(2773035, 3039, 14653, 1043, 8694, 11421, 12055, 9505, 9631)
)

map_nhanes_pa_quantiles(all_measures, id = "id")
#>    id age    sex               measure   value age_category_pa_map
#> 1 P01  25 Female total_activity_counts 2773035             [20,30)
#> 2 P01  25 Female         total_log10AC    3039             [20,30)
#> 3 P01  25 Female         total_PAXMTSM   14653             [20,30)
#> 4 P01  25 Female    total_log10PAXMTSM    1043             [20,30)
#> 5 P01  25 Female      total_scsslsteps    8694             [20,30)
#> 6 P01  25 Female       total_scrfsteps   11421             [20,30)
#> 7 P01  25 Female        total_oaksteps   12055             [20,30)
#> 8 P01  25 Female         total_vssteps    9505             [20,30)
#> 9 P01  25 Female      total_vsrevsteps    9631             [20,30)
#>   nhanes_quantile
#> 1       0.4852706
#> 2       0.5714842
#> 3       0.4873396
#> 4       0.5564848
#> 5       0.5872852
#> 6       0.4938108
#> 7       0.4892558
#> 8       0.5019565
#> 9       0.5158600
```

The complete list of accepted names and the summary used for each CDF is
available from `nhanes_pa_measure_map()`. Other names return `NA` with a
warning listing the unmapped measures. Each `value` should be calculated
using the summary named in the map and supplied on that summary’s scale.

``` r
nhanes_pa_measure_map()
#>                    measure      summary
#> 1                       AC           AC
#> 2          activity_counts           AC
#> 3           activitycounts           AC
#> 4                   counts           AC
#> 5                 total_AC           AC
#> 6    total_activity_counts           AC
#> 7                  log10AC      log10AC
#> 8    log10_activity_counts      log10AC
#> 9             log10_counts      log10AC
#> 10           total_log10AC      log10AC
#> 11                 PAXMTSM      PAXMTSM
#> 12                    mims      PAXMTSM
#> 13               mims_unit      PAXMTSM
#> 14           total_PAXMTSM      PAXMTSM
#> 15            log10PAXMTSM log10PAXMTSM
#> 16              log10_mims log10PAXMTSM
#> 17      total_log10PAXMTSM log10PAXMTSM
#> 18         log10_mims_unit log10PAXMTSM
#> 19              scsslsteps   scsslsteps
#> 20               ssl_steps   scsslsteps
#> 21            sslstepcount   scsslsteps
#> 22           sslstepcounts   scsslsteps
#> 23         total_ssl_steps   scsslsteps
#> 24        total_scsslsteps   scsslsteps
#> 25     steps_stepcount_ssl   scsslsteps
#> 26    steps_stepcounts_ssl   scsslsteps
#> 27               scrfsteps    scrfsteps
#> 28                rf_steps    scrfsteps
#> 29             rfstepcount    scrfsteps
#> 30            rfstepcounts    scrfsteps
#> 31          total_rf_steps    scrfsteps
#> 32         total_scrfsteps    scrfsteps
#> 33      steps_stepcount_rf    scrfsteps
#> 34     steps_stepcounts_rf    scrfsteps
#> 35                oaksteps     oaksteps
#> 36             foreststeps     oaksteps
#> 37               steps_oak     oaksteps
#> 38            steps_forest     oaksteps
#> 39              nsteps_oak     oaksteps
#> 40           nsteps_forest     oaksteps
#> 41          total_oaksteps     oaksteps
#> 42  steps_stepcount_forest     oaksteps
#> 43 steps_stepcounts_forest     oaksteps
#> 44                 vssteps      vssteps
#> 45        vssteps_original      vssteps
#> 46       steps_vs_original      vssteps
#> 47           total_vssteps      vssteps
#> 48              vsrevsteps   vsrevsteps
#> 49         vssteps_revised   vsrevsteps
#> 50        steps_vs_revised   vsrevsteps
#> 51        total_vsrevsteps   vsrevsteps
```

The `measure` column accepts common aliases, including `total_ac` and
`total_activity_counts` for the `AC` CDF:

``` r
measures <- data.frame(
  id = rep("P01", 4),
  age = 25,
  sex = "Female",
  measure = c("mims", "PAXMTSM", "total_ac", "total_activity_counts"),
  value = c(15000, 15000, 2773035, 2773035)
)

map_nhanes_pa_quantiles(measures, id = "id")
#>    id age    sex               measure   value age_category_pa_map
#> 1 P01  25 Female                  mims   15000             [20,30)
#> 2 P01  25 Female               PAXMTSM   15000             [20,30)
#> 3 P01  25 Female              total_ac 2773035             [20,30)
#> 4 P01  25 Female total_activity_counts 2773035             [20,30)
#>   nhanes_quantile
#> 1       0.5349443
#> 2       0.5349443
#> 3       0.4852706
#> 4       0.4852706

# Select a CDF function directly for a supported measure and stratum.
nhanes_pa_measure_cdf("total_activity_counts", age = 25, sex = "Female")(2773035)
#> [1] 0.4852706
```

By default, quantiles are evaluated against the combined 2011-2012 and
2013-2014 NHANES waves:

``` r
map_nhanes_pa_quantiles(study_data, id = "id")
#>    id age    sex   measure   value age_category_pa_map nhanes_quantile
#> 1 P01  25 Female      mims   15000             [20,30)       0.5349443
#> 2 P02  62   Male ssl_steps    7500             [60,70)       0.3527381
#> 3 P03  84 Female        AC 1000000             [80,85)       0.1322205
```

To map against a specific NHANES wave, provide `wave`:

``` r
map_nhanes_pa_quantiles(study_data, id = "id", wave = "2013-2014")
#>    id age    sex   measure   value age_category_pa_map nhanes_quantile
#> 1 P01  25 Female      mims   15000             [20,30)       0.4943653
#> 2 P02  62   Male ssl_steps    7500             [60,70)       0.3820584
#> 3 P03  84 Female        AC 1000000             [80,85)       0.1181001
```

You can also map without sex or age stratification:

``` r
map_nhanes_pa_quantiles(study_data, id = "id", sex = NULL)
#>    id age    sex   measure   value age_category_pa_map nhanes_quantile
#> 1 P01  25 Female      mims   15000             [20,30)       0.5688587
#> 2 P02  62   Male ssl_steps    7500             [60,70)       0.4164160
#> 3 P03  84 Female        AC 1000000             [80,85)       0.1408881
map_nhanes_pa_quantiles(study_data, id = "id", age = NULL)
#>    id age    sex   measure   value age_category_pa_map nhanes_quantile
#> 1 P01  25 Female      mims   15000             Overall      0.53548286
#> 2 P02  62   Male ssl_steps    7500             Overall      0.28321363
#> 3 P03  84 Female        AC 1000000             Overall      0.01040967
```

For a single participant-measure value, use `nhanes_pa_quantile()`:

``` r
nhanes_pa_quantile(
  value = 15000,
  age = 25,
  sex = "Female",
  measure = "mims"
)
#> [1] 0.5349443
```

If a study already has age categories, pass the column name through
`age_category`.
