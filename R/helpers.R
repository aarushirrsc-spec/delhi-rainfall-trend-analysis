# R/helpers.R
# ---------------------------------------------------------------------------
# Shared settings and functions used by every script in scripts/.
# Run scripts from the repository root, e.g. source("scripts/02_annual_total_trend.R").
# ---------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(ggplot2)   # plots (version 3.4 or newer)
  library(Kendall)   # MannKendall()
  library(trend)     # sens.slope()
})

# ---- Settings --------------------------------------------------------------
START_YEAR <- 1983
END_YEAR   <- 2022

# Bounding box of Delhi (same box as the original clipping step).
# Grid cells whose CENTRE lies inside the box are kept: this gives 2 x 2 = 4 pixels.
DELHI_BOX  <- list(lon = c(76.84, 77.35), lat = c(28.40, 28.88))

DELHI_FILE <- file.path("data", "delhi_rainfall_1983_2022.rds")   # made by script 01
FIG_DIR    <- file.path("outputs", "figures")
TAB_DIR    <- file.path("outputs", "tables")

# ---- Loading and slicing the data ------------------------------------------

# Load the Delhi rainfall made by scripts/01_prepare_delhi_data.R.
# Returns a list: rain = array [longitude, latitude, day] in mm, dates, lon, lat.
load_delhi <- function(file = DELHI_FILE) {
  if (!file.exists(file)) {
    stop("File not found: ", file, ". Run scripts/01_prepare_delhi_data.R first.")
  }
  readRDS(file)
}

# Rainfall array [longitude, latitude, day] for one calendar year.
year_slice <- function(delhi, year) {
  in_year <- as.integer(format(delhi$dates, "%Y")) == year
  delhi$rain[, , in_year, drop = FALSE]
}

# Apply a function to the rainfall of each year.
# `fun` must take the [lon, lat, day] array of one year and return ONE number.
# Returns a data frame with columns Year and Value.
yearly_series <- function(delhi, fun, years = START_YEAR:END_YEAR) {
  values <- vapply(years, function(y) fun(year_slice(delhi, y)), numeric(1))
  data.frame(Year = years, Value = values)
}

# Name each pixel by its position, e.g. "North West". Returns a matrix [lon, lat].
region_names <- function(delhi) {
  ew <- ifelse(delhi$lon > mean(delhi$lon), "East", "West")
  ns <- ifelse(delhi$lat > mean(delhi$lat), "North", "South")
  outer(ew, ns, function(e, n) paste(n, e))
}

# ---- Trend tests -----------------------------------------------------------

# Mann-Kendall test (is there a monotonic trend?) and Sen's slope (how big is it?).
run_trend_tests <- function(x) {
  mk  <- MannKendall(x)
  sen <- sens.slope(x, conf.level = 0.95)
  list(
    mk_p  = as.numeric(mk$sl),        # two-sided Mann-Kendall p-value
    sen_p = as.numeric(sen$p.value),  # p-value reported by sens.slope()
    slope = as.numeric(sen$estimates) # Sen's slope, in units per year
  )
}

describe_result <- function(p, slope) {
  if (slope == 0) return("no trend")
  direction <- if (slope > 0) "increase" else "decrease"
  paste0(if (p < 0.05) "significant " else "non-significant ", direction)
}

# ---- Plot and result table -------------------------------------------------

# Time series with a linear fit line and the test results written on the plot.
# The red line is an ordinary least-squares line, for visual guidance only;
# the reported trend size is Sen's slope.
plot_trend <- function(df, title, ylab, tests, label_size = 2.5) {
  d <- data.frame(x = df$Year, y = df$Value)
  note <- sprintf("Mann-Kendall p-value: %.4f\nSen's slope: %.4f per year",
                  tests$mk_p, tests$slope)

  ggplot(d, aes(x = x, y = y)) +
    geom_line(aes(colour = "Observed")) +
    geom_point(colour = "grey30", size = 1.2) +
    geom_text(aes(label = round(y, 2)), vjust = -0.8, size = label_size) +
    geom_smooth(aes(colour = "Linear fit (OLS)"), method = "lm", formula = y ~ x,
                se = FALSE, linewidth = 0.9) +
    annotate("text", x = Inf, y = Inf, label = note, hjust = 1.05, vjust = 1.3,
             size = 3.5, fontface = "italic") +
    scale_colour_manual(name = NULL,
                        values = c("Observed" = "blue", "Linear fit (OLS)" = "red")) +
    scale_x_continuous(breaks = d$x) +
    labs(title = title, x = "Year", y = ylab) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
}

# One call per series: run the tests, draw and save the plot, return one table row.
#   df: data frame with Year and Value.   file: plot file name without extension.
trend_report <- function(df, analysis, series, period, title, ylab, unit, file,
                         label_size = 2.5) {
  tests <- run_trend_tests(df$Value)

  dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)
  ggsave(file.path(FIG_DIR, paste0(file, ".png")),
         plot_trend(df, title, ylab, tests, label_size),
         width = 12, height = 6, dpi = 150)

  message(sprintf("%-38s %-11s %-10s MK p = %.4f | Sen's slope = %.4f %s",
                  analysis, series, period, tests$mk_p, tests$slope, unit))

  data.frame(
    analysis            = analysis,
    series_or_region    = series,
    period              = period,
    mk_p_value          = round(tests$mk_p, 4),
    sens_p_value        = round(tests$sen_p, 4),
    sens_slope_per_year = round(tests$slope, 4),
    slope_unit          = unit,
    `result_at_0.05`    = describe_result(tests$mk_p, tests$slope),
    check.names         = FALSE,
    stringsAsFactors    = FALSE
  )
}

# Write a list of result rows to outputs/tables/<name>.csv
save_table <- function(rows, name) {
  dir.create(TAB_DIR, recursive = TRUE, showWarnings = FALSE)
  write.csv(do.call(rbind, rows), file.path(TAB_DIR, paste0(name, ".csv")),
            row.names = FALSE)
}
