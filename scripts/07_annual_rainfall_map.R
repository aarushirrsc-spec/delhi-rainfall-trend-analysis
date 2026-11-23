# 07_annual_rainfall_map.R
# ---------------------------------------------------------------------------
# Quick-look map: total annual rainfall (mm) over India for one year, from an
# IMD 0.25-degree NetCDF file. Useful to check the data and see the large-scale
# pattern. Separate from the Delhi trend analysis (scripts 01-06).
#
# Input : data/RF25_ind<year>_rfp25.nc
# Output: outputs/figures/annual_rainfall_<year>_map.png
# ---------------------------------------------------------------------------

library(ncdf4)
library(raster)

# ---- Settings --------------------------------------------------------------
year      <- 2023
n_classes <- 5          # equal-interval legend classes
nc_file   <- file.path("data", sprintf("RF25_ind%d_rfp25.nc", year))
out_png   <- file.path("outputs", "figures", sprintf("annual_rainfall_%d_map.png", year))

if (!file.exists(nc_file)) stop("File not found: ", nc_file, " (see data/README.md)")

# ---- Read the data ---------------------------------------------------------
nc       <- nc_open(nc_file)
rainfall <- ncvar_get(nc, "RAINFALL")    # array [longitude, latitude, day]
lon      <- ncvar_get(nc, "LONGITUDE")
lat      <- ncvar_get(nc, "LATITUDE")
nc_close(nc)

# Negative values are not valid rainfall: treat them as missing
rainfall[rainfall < 0] <- NA

# ---- Total rainfall per pixel over the year --------------------------------
# Summing the days gives the annual TOTAL in mm. (Averaging the days would give
# mm per DAY.) Pixels with no data at all stay NA instead of becoming 0.
annual_total <- apply(rainfall, c(1, 2), function(x) {
  if (all(is.na(x))) NA_real_ else sum(x, na.rm = TRUE)
})

# ---- Build the raster ------------------------------------------------------
# raster() puts the FIRST row of the matrix at the TOP of the map. IMD stores
# latitude from south to north, so reverse the latitude columns first,
# otherwise the map is upside down.
if (lat[1] < lat[length(lat)]) {
  annual_total <- annual_total[, ncol(annual_total):1]
}

# lon/lat are pixel CENTRES, so the raster edges lie half a pixel further out
half_x <- abs(lon[2] - lon[1]) / 2
half_y <- abs(lat[2] - lat[1]) / 2

rainfall_raster <- raster(
  t(annual_total),                      # t(): rows = latitude, columns = longitude
  xmn = min(lon) - half_x, xmx = max(lon) + half_x,
  ymn = min(lat) - half_y, ymx = max(lat) + half_y,
  crs = "+proj=longlat +datum=WGS84"
)

# ---- Plot with equal-interval classes --------------------------------------
breaks  <- seq(min(annual_total, na.rm = TRUE), max(annual_total, na.rm = TRUE),
               length.out = n_classes + 1)
colours <- colorRampPalette(c("lightblue", "blue"))(n_classes)

draw_map <- function() {
  plot(rainfall_raster, breaks = breaks, col = colours,
       main = sprintf("Annual Total Rainfall, %d (mm)", year),
       xlab = "Longitude", ylab = "Latitude",
       axis.args = list(at = breaks, labels = round(breaks)))
}

draw_map()

dir.create(dirname(out_png), recursive = TRUE, showWarnings = FALSE)
png(out_png, width = 1800, height = 1800, res = 250)
draw_map()
dev.off()
