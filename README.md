
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mapnhanespa

<!-- badges: start -->

[![R-CMD-check](https://github.com/jhuwit/mapnhanespa/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jhuwit/mapnhanespa/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/jhuwit/mapnhanespa/graph/badge.svg)](https://app.codecov.io/gh/jhuwit/mapnhanespa)
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
#>    id age    sex   measure   value nhanes_quantile
#> 1 P01  25 Female      mims   15000       0.5349443
#> 2 P02  62   Male ssl_steps    7500       0.3527381
#> 3 P03  84 Female        AC 1000000       0.1322205
```

The `measure` column accepts common aliases:

``` r
measures <- data.frame(
  id = c("P01", "P01", "P01"),
  age = 25,
  sex = "Female",
  measure = c("mims", "PAXMTSM", "total_PAXMTSM"),
  value = 15000
)

map_nhanes_pa_quantiles(measures, id = "id")
#>    id age    sex       measure value nhanes_quantile
#> 1 P01  25 Female          mims 15000       0.5349443
#> 2 P01  25 Female       PAXMTSM 15000       0.5349443
#> 3 P01  25 Female total_PAXMTSM 15000       0.5349443
```

By default, quantiles are evaluated against the combined 2011-2012 and
2013-2014 NHANES waves:

``` r
map_nhanes_pa_quantiles(study_data, id = "id")
#>    id age    sex   measure   value nhanes_quantile
#> 1 P01  25 Female      mims   15000       0.5349443
#> 2 P02  62   Male ssl_steps    7500       0.3527381
#> 3 P03  84 Female        AC 1000000       0.1322205
```

To map against a specific NHANES wave, provide `wave`:

``` r
map_nhanes_pa_quantiles(study_data, id = "id", wave = "2013-2014")
#>    id age    sex   measure   value nhanes_quantile
#> 1 P01  25 Female      mims   15000       0.4943653
#> 2 P02  62   Male ssl_steps    7500       0.3820584
#> 3 P03  84 Female        AC 1000000       0.1181001
```

You can also map without sex or age stratification:

``` r
map_nhanes_pa_quantiles(study_data, id = "id", sex = NULL)
#>    id age    sex   measure   value nhanes_quantile
#> 1 P01  25 Female      mims   15000       0.5688587
#> 2 P02  62   Male ssl_steps    7500       0.4164160
#> 3 P03  84 Female        AC 1000000       0.1408881
map_nhanes_pa_quantiles(study_data, id = "id", age = NULL)
#>    id age    sex   measure   value nhanes_quantile
#> 1 P01  25 Female      mims   15000      0.53548286
#> 2 P02  62   Male ssl_steps    7500      0.28321363
#> 3 P03  84 Female        AC 1000000      0.01040967
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
