run_cdf = function(data) {
  wtmec4yr_adj_norm = NULL
  rm(list = c("wtmec4yr_adj_norm"))
  temp =
    data %>%
    dplyr::mutate(wt_norm = wtmec4yr_adj_norm / mean(wtmec4yr_adj_norm))

  svy_design =
    survey::svydesign(
      id = ~ masked_variance_pseudo_psu,
      strata = ~ masked_variance_pseudo_stratum,
      weights = ~ wt_norm,
      data = temp,
      nest = TRUE
    )
  survey::svycdf(~value, svy_design)$value
}

