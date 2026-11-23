# 00_run_all.R
# ---------------------------------------------------------------------------
# Run the whole Delhi analysis from the repository root:
#   source("scripts/00_run_all.R")
# Needs the 40 yearly IMD files in data/ (see data/README.md).
# ---------------------------------------------------------------------------

scripts <- c(
  "scripts/01_prepare_delhi_data.R",
  "scripts/02_annual_total_trend.R",
  "scripts/03_regional_trends.R",
  "scripts/04_percentile_trends.R",
  "scripts/05_rainy_days_trend.R",
  "scripts/06_intensity_indices_trend.R",
  "scripts/08_check_against_reported.R"
)

for (s in scripts) {
  message("\n==== ", s, " ====")
  source(s, local = new.env())
}
