## code to prepare `nhanes_measure_data` dataset goes here
## code to prepare `cdfs` dataset goes here
library(tidyverse)
df_cdf = read_rds("data-raw/all_measure_data.rds")
df_cdf = df_cdf %>%
  mutate(measure = sub("total_", "", measure))
df_cdf = df_cdf %>%
  mutate(measure = mapnhanespa:::.standardize_measure(measure))

df_cdf = df_cdf %>%
  filter(!is.na(measure))
nhanes_measure_data = df_cdf
usethis::use_data(nhanes_measure_data, overwrite = TRUE)
