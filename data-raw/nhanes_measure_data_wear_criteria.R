## code to prepare `nhanes_measure_data_wear_criteria` dataset goes here
##
## Source: all_measure_data_wear_criteria.rds, created by
## code/step_99_get_step_quantiles.R in the nhanes_steps_mortality project.
## It is participant-level long data (one row per SEQN x criterion x measure)
## for 15 wear-time inclusion criteria. Survey weights were re-adjusted
## separately within each criterion.
##
## To keep the package well under CRAN's 5 MB limit, the data are stored
## wide: one row per SEQN x criterion with one column per measure. This is
## lossless. `min_wear_minutes` and `min_valid_days` are dropped because they
## are encoded in `criterion` and returned by `nhanes_pa_wear_criteria()`.
library(tidyverse)
df_cdf = read_rds("data-raw/all_measure_data_wear_criteria.rds")

# Same measure standardization as data-raw/nhanes_measure_data.R
df_cdf = df_cdf %>%
  mutate(measure = sub("total_", "", measure))
df_cdf = df_cdf %>%
  mutate(measure = mapnhanespa:::.standardize_measure(measure))
df_cdf = df_cdf %>%
  filter(!is.na(measure))

# The criterion string must agree with its numeric parts
stopifnot(all(
  df_cdf$criterion ==
    paste0("wear", df_cdf$min_wear_minutes, "_days", df_cdf$min_valid_days)
))
criteria = mapnhanespa:::nhanes_pa_wear_criteria()
stopifnot(setequal(unique(df_cdf$criterion), criteria$criterion))

measures = sort(unique(df_cdf$measure))
nhanes_measure_data_wear_criteria = df_cdf %>%
  select(-min_wear_minutes, -min_valid_days) %>%
  pivot_wider(names_from = measure, values_from = value) %>%
  select(
    SEQN, criterion, data_release_cycle, cat_age, gender,
    wtmec4yr_adj_norm, masked_variance_pseudo_psu,
    masked_variance_pseudo_stratum, num_valid_days,
    all_of(measures)
  ) %>%
  arrange(criterion, data_release_cycle, SEQN)

# One row per participant x criterion, no values lost in the pivot
stopifnot(
  !anyDuplicated(nhanes_measure_data_wear_criteria[, c("SEQN", "criterion")]),
  nrow(nhanes_measure_data_wear_criteria) * length(measures) == nrow(df_cdf),
  !anyNA(nhanes_measure_data_wear_criteria[, measures])
)

usethis::use_data(nhanes_measure_data_wear_criteria, overwrite = TRUE,
                  compress = "xz")
