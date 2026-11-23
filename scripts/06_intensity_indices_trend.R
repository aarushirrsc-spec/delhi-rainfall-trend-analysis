# 06_intensity_indices_trend.R
# ---------------------------------------------------------------------------
# Trends in rainfall intensity, using three yearly indices:
#   SDII  : Simple Daily Intensity Index = total rainfall / number of days with
#           rainfall >= 1 mm (all four pixels together), in mm/day.
#   Rx1day: the largest 1-day rainfall of the year (any pixel), in mm.
#   Rx5day: the largest 5-day rainfall total of the year (any pixel), in mm.
#
# Output: outputs/figures/*.png and outputs/tables/06_intensity_indices_trend.csv
# ---------------------------------------------------------------------------

source("R/helpers.R")
delhi <- load_delhi()

period <- sprintf("%d-%d", START_YEAR, END_YEAR)

sdii  <- function(rain) sum(rain, na.rm = TRUE) / sum(rain >= 1, na.rm = TRUE)
rx1   <- function(rain) max(rain, na.rm = TRUE)
rx5   <- function(rain) {
  # 5-day running sum for each pixel (within the year), then the overall maximum
  sums <- apply(rain, c(1, 2), function(x) zoo::rollsum(x, 5, fill = NA, align = "right"))
  max(sums, na.rm = TRUE)
}

rows <- list(
  trend_report(
    df       = yearly_series(delhi, sdii),
    analysis = "Simple daily intensity index (SDII)",
    series   = "Delhi",
    period   = period,
    title    = paste0("Simple Daily Intensity Index (SDII) per Year (", period, ")"),
    ylab     = "SDII (mm/day)",
    unit     = "mm/day per year",
    file     = "sdii",
    label_size = 3
  ),
  trend_report(
    df       = yearly_series(delhi, rx1),
    analysis = "Maximum 1-day rainfall",
    series   = "Delhi",
    period   = period,
    title    = paste0("Maximum 1-Day Rainfall per Year (", period, ")"),
    ylab     = "Rx1day (mm)",
    unit     = "mm/year",
    file     = "max_1day_rainfall",
    label_size = 3
  ),
  trend_report(
    df       = yearly_series(delhi, rx5),
    analysis = "Maximum 5-consecutive-day rainfall",
    series   = "Delhi",
    period   = period,
    title    = paste0("Maximum 5-Consecutive-Day Rainfall per Year (", period, ")"),
    ylab     = "Rx5day (mm)",
    unit     = "mm/year",
    file     = "max_5day_rainfall",
    label_size = 3
  )
)

save_table(rows, "06_intensity_indices_trend")
