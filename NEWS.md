# mapnhanespa 0.3.0

* Added an explicit map of accepted measure names to the nine NHANES summaries,
  including `total_ac` and `total_activity_counts`. The new
  `nhanes_pa_measure_map()` lists all supported names, and
  `nhanes_pa_measure_cdf()` selects a CDF for a measure and stratum.
* Unmapped measures now produce missing quantiles with a warning that lists
  each unique unmapped name. `steps_sdt` is unmapped because no corresponding
  NHANES CDF is available.
* `map_nhanes_pa_quantiles()` now adds `age_category_pa_map` to show the age
  category used for each observation's CDF.
* Expanded the README and vignette examples to cover all nine supported
  summaries while retaining the three-participant example.

# mapnhanespa 0.1.0

* `map_nhanes_quantiles` now maps things to the data.
* CDFs removed.
* Initial CRAN submission.
