# 04_percentile_trends.R
# ---------------------------------------------------------------------------
# Trends in low and high daily rainfall: the 10th and 90th percentile of daily
# rainfall for each year.
#
# Only wet days (rainfall > 0 mm) are used, pooled over the four pixels.
# (With dry days included, the 10th percentile would be 0 in every year.)
#
# Output: outputs/figures/*.png and outputs/tables/04_percentile_trends.csv
# ---------------------------------------------------------------------------

source("R/helpers.R")
delhi <- load_delhi()

# Percentile of the wet-day values of one year
wet_day_percentile <- function(prob) {
  function(rain) {
    wet <- rain[!is.na(rain) & rain > 0]
    unname(quantile(wet, prob))
  }
}

period <- sprintf("%d-%d", START_YEAR, END_YEAR)

rows <- list(
  trend_report(
    df       = yearly_series(delhi, wet_day_percentile(0.10)),
    analysis = "10th percentile of daily rainfall",
    series   = "Delhi",
    period   = period,
    title    = paste0("10th Percentile of Daily Rainfall for Each Year (", period, ")"),
    ylab     = "10th Percentile Rainfall (mm)",
    unit     = "mm/year",
    file     = "percentile_10th_daily_rainfall"
  ),
  trend_report(
    df       = yearly_series(delhi, wet_day_percentile(0.90)),
    analysis = "90th percentile of daily rainfall",
    series   = "Delhi",
    period   = period,
    title    = paste0("90th Percentile of Daily Rainfall for Each Year (", period, ")"),
    ylab     = "90th Percentile Rainfall (mm)",
    unit     = "mm/year",
    file     = "percentile_90th_daily_rainfall"
  )
)

save_table(rows, "04_percentile_trends")
