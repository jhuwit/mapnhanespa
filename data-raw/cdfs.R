## code to prepare `cdfs` dataset goes here
library(tidyverse)
df_cdf = read_rds("data-raw/age_sex_cdf.rds")
df_cdf = df_cdf %>%
  mutate(measure = sub("total_", "", measure))
cdfs = split(df_cdf, df_cdf$measure)
cdfs = lapply(cdfs, function(x) {
  x %>%
    select(-measure)
})

cdf_ac = cdfs$AC
usethis::use_data(cdf_ac, overwrite = TRUE)

cdf_ssl_steps = cdfs$scsslsteps
usethis::use_data(cdf_ssl_steps, overwrite = TRUE)

cdf_mims = cdfs$PAXMTSM
usethis::use_data(cdf_mims, overwrite = TRUE)
