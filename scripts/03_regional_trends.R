# 03_regional_trends.R
# ---------------------------------------------------------------------------
# Trend in annual total rainfall for each of the four grid pixels (regions)
# that cover Delhi. Each pixel is named by its position (North West, ...)
# using the longitude/latitude stored in the data, so the names do not depend
# on the order of the array.
#
# Output: outputs/figures/*.png and outputs/tables/03_regional_trends.csv
# ---------------------------------------------------------------------------

source("R/helpers.R")
delhi   <- load_delhi()
regions <- region_names(delhi)   # matrix [lon, lat] of names

rows <- list()
for (i in seq_along(delhi$lon)) {
  for (j in seq_along(delhi$lat)) {
    region <- regions[i, j]

    # Annual total of this one pixel
    pixel_total <- function(rain) sum(rain[i, j, ], na.rm = TRUE)
    annual <- yearly_series(delhi, pixel_total)

    rows[[region]] <- trend_report(
      df       = annual,
      analysis = "Annual total rainfall",
      series   = region,
      period   = sprintf("%d-%d", START_YEAR, END_YEAR),
      title    = sprintf("Annual Total Rainfall in %s Delhi (%d-%d)", region, START_YEAR, END_YEAR),
      ylab     = "Total Rainfall (mm)",
      unit     = "mm/year",
      file     = paste0("annual_total_", gsub(" ", "_", tolower(region)))
    )
  }
}

save_table(rows, "03_regional_trends")
