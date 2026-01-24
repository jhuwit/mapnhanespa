## code to prepare `cdfs_bywave` dataset goes here
library(tidyverse)
df_cdf = read_rds("data-raw/age_sex_cdf_by_wave.rds")
df_cdf = df_cdf %>%
  mutate(measure = sub("total_", "", measure))
cdfs = split(df_cdf, df_cdf$measure)
cdfs = lapply(cdfs, function(x) {
  x %>%
    select(-measure)
})

cdf_ac_bywave = cdfs$AC
usethis::use_data(cdf_ac_bywave, overwrite = TRUE)

cdf_ssl_steps_bywave = cdfs$scsslsteps
usethis::use_data(cdf_ssl_steps_bywave, overwrite = TRUE)

cdf_mims_bywave = cdfs$PAXMTSM
usethis::use_data(cdf_mims_bywave, overwrite = TRUE)

