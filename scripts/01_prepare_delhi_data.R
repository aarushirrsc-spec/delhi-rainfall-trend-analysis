# 01_prepare_delhi_data.R
# ---------------------------------------------------------------------------
# Cut the four IMD grid pixels that cover Delhi out of the yearly NetCDF files
# (1983-2022) and save them as one small file used by all later scripts.
#
# Input : data/RF25_ind<year>_rfp25.nc   (40 files, see data/README.md)
# Output: data/delhi_rainfall_1983_2022.rds
# ---------------------------------------------------------------------------

library(ncdf4)
source("R/helpers.R")

rain_by_year  <- list()   # one [lon, lat, day] array per year
dates_by_year <- list()   # the matching dates

for (year in START_YEAR:END_YEAR) {
  nc_file <- file.path("data", sprintf("RF25_ind%d_rfp25.nc", year))
  if (!file.exists(nc_file)) stop("File not found: ", nc_file, " (see data/README.md)")

  nc  <- nc_open(nc_file)
  lon <- ncvar_get(nc, "LONGITUDE")
  lat <- ncvar_get(nc, "LATITUDE")

  # The code below assumes the array is ordered [longitude, latitude, time].
  dim_names <- vapply(nc$var[["RAINFALL"]]$dim, function(d) d$name, character(1))
  stopifnot(identical(dim_names, c("LONGITUDE", "LATITUDE", "TIME")))

  # Pixels whose centre lies inside the Delhi box (expect 2 x 2)
  lon_idx <- which(lon >= DELHI_BOX$lon[1] & lon <= DELHI_BOX$lon[2])
  lat_idx <- which(lat >= DELHI_BOX$lat[1] & lat <= DELHI_BOX$lat[2])
  stopifnot(length(lon_idx) == 2, length(lat_idx) == 2)

  # Read only the Delhi block, for all days: array [2, 2, days]
  rain <- ncvar_get(nc, "RAINFALL",
                    start = c(min(lon_idx), min(lat_idx), 1),
                    count = c(length(lon_idx), length(lat_idx), -1))
  nc_close(nc)

  # Each yearly file has one record per day: 365, or 366 in a leap year
  n_days  <- dim(rain)[3]
  is_leap <- (year %% 4 == 0 & year %% 100 != 0) | year %% 400 == 0
  stopifnot(n_days == if (is_leap) 366 else 365)

  rain_by_year[[as.character(year)]]  <- rain
  dates_by_year[[as.character(year)]] <- seq(as.Date(sprintf("%d-01-01", year)),
                                             by = "day", length.out = n_days)
  pixel_lon <- lon[lon_idx]
  pixel_lat <- lat[lat_idx]
}

# Join the years end to end along the time axis.
# (Each array is stored column by column, so joining the raw values works.)
dates_all <- do.call(c, unname(dates_by_year))
rain_all  <- array(unlist(lapply(rain_by_year, as.vector)),
                   dim = c(2, 2, length(dates_all)))

if (any(rain_all < 0, na.rm = TRUE)) warning("Negative rainfall values found: check the data.")

delhi <- list(rain = rain_all, dates = dates_all, lon = pixel_lon, lat = pixel_lat)
saveRDS(delhi, DELHI_FILE)

message("Saved ", DELHI_FILE, ": 2 x 2 pixels, ", length(dates_all), " days (",
        format(min(dates_all)), " to ", format(max(dates_all)), ")")
message("Pixel longitudes: ", paste(pixel_lon, collapse = ", "))
message("Pixel latitudes : ", paste(pixel_lat, collapse = ", "))
