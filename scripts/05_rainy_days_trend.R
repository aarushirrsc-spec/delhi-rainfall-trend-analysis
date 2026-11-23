# 05_rainy_days_trend.R
# ---------------------------------------------------------------------------
# Trends in how often it rains: the number of light and heavy rainy days per year.
#
#   Light rainy days: days with rainfall >= 1 mm, averaged over the four pixels.
#   Heavy rainy days: days with rainfall >= HEAVY_RAIN_MM, counted as a total
#                     over the four pixels (pixel-days).
#
# Output: outputs/figures/*.png and outputs/tables/05_rainy_days_trend.csv
# ---------------------------------------------------------------------------

source("R/helpers.R")
delhi <- load_delhi()

LIGHT_RAIN_MM <- 1    # a light rainy day has rainfall >= 1 mm
HEAVY_RAIN_MM <- 50   # a heavy rainy day has rainfall >= 50 mm

period <- sprintf("%d-%d", START_YEAR, END_YEAR)

light_days <- function(rain) sum(rain >= LIGHT_RAIN_MM, na.rm = TRUE) / prod(dim(rain)[1:2])
heavy_days <- function(rain) sum(rain >= HEAVY_RAIN_MM, na.rm = TRUE)

rows <- list(
  trend_report(
    df       = yearly_series(delhi, light_days),
    analysis = sprintf("Light rainy days (>=%g mm)", LIGHT_RAIN_MM),
    series   = "Delhi",
    period   = period,
    title    = sprintf("Number of Rainy Days (>= %g mm) per Year (%s)", LIGHT_RAIN_MM, period),
    ylab     = "Number of Rainy Days",
    unit     = "days/year",
    file     = "light_rainy_days",
    label_size = 3
  ),
  trend_report(
    df       = yearly_series(delhi, heavy_days),
    analysis = sprintf("Heavy rainy days (>=%g mm)", HEAVY_RAIN_MM),
    series   = "Delhi",
    period   = period,
    title    = sprintf("Number of Heavy Rain Days (>= %g mm) per Year (%s)", HEAVY_RAIN_MM, period),
    ylab     = "Number of Heavy Rain Days",
    unit     = "days/year",
    file     = "heavy_rainy_days",
    label_size = 3
  )
)

save_table(rows, "05_rainy_days_trend")
