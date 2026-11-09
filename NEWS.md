# mapnhanespa 0.4.0

* Added support for alternative accelerometer wear-time inclusion criteria, so
  study data can be mapped to NHANES quantiles that match the study's own
  inclusion rules. `map_nhanes_pa_quantiles()`, `nhanes_pa_quantile()`,
  `nhanes_pa_measure_cdf()`, and `precompute_nhanes_pa_cdfs()` gain
  `min_wear_minutes` (`600`, `960`, `1296`, `1368`, or `1440`; default
  `1368`) and `min_valid_days` (`1`, `3`, or `4`; default `3`). The defaults
  use `nhanes_measure_data`, so existing results are unchanged.
* New dataset `nhanes_measure_data_wear_criteria` with participant-level
  summaries and criterion-specific survey weights for all 15 criteria.
* New `nhanes_pa_wear_criteria()` lists the available criteria with short
  notes on where each wear threshold is used.
* The CDF cache key now includes the wear-time criterion, so CDFs from
  different criteria never collide.

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

* Added Lily Koffman as an author and references to Koffman, Crainiceanu,
  and Muschelli (2025) and the Koffman and Muschelli (2025) PhysioNet data
  in the package description.

# mapnhanespa 0.2.0

* Removed the magrittr dependency.

# mapnhanespa 0.1.0

* `map_nhanes_quantiles` now maps things to the data.
* CDFs removed.
* Initial CRAN submission.
