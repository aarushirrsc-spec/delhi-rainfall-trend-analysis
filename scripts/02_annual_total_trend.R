# 02_annual_total_trend.R
# ---------------------------------------------------------------------------
# Trend in Delhi's annual total rainfall (mm): Mann-Kendall test + Sen's slope.
# Runs for the full period 1983-2022 and for the four sub-periods.
#
# Delhi's annual total = the average of the four pixels' annual totals.
# Output: outputs/figures/*.png and outputs/tables/02_annual_total_trend.csv
# ---------------------------------------------------------------------------

source("R/helpers.R")
delhi <- load_delhi()

# Total rainfall of each pixel over the year, then the mean of the four pixels
annual_total <- function(rain) mean(apply(rain, c(1, 2), sum, na.rm = TRUE))
annual <- yearly_series(delhi, annual_total)

periods <- list(c(1983, 2022), c(1983, 2008), c(1988, 2013), c(1993, 2018), c(1998, 2022))

rows <- lapply(periods, function(p) {
  label <- sprintf("%d-%d", p[1], p[2])
  trend_report(
    df       = annual[annual$Year >= p[1] & annual$Year <= p[2], ],
    analysis = "Annual total rainfall",
    series   = "Delhi",
    period   = label,
    title    = paste0("Annual Total Rainfall of Delhi (", label, ")"),
    ylab     = "Total Rainfall (mm)",
    unit     = "mm/year",
    file     = paste0("annual_total_delhi_", p[1], "_", p[2])
  )
})

save_table(rows, "02_annual_total_trend")
