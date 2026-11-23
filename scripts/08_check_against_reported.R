# 08_check_against_reported.R
# ---------------------------------------------------------------------------
# Compare the results produced by scripts 02-06 (outputs/tables/*.csv) with the
# results reported in the project presentation (results/results_summary.csv).
#
# For each analysis it prints MATCH, DIFFERENT or NOT RUN, with both values.
# Values are compared after rounding (p-values to 3 decimals, slopes to 2).
# ---------------------------------------------------------------------------

reported_file <- file.path("results", "results_summary.csv")
table_files   <- list.files(file.path("outputs", "tables"), pattern = "\\.csv$", full.names = TRUE)
if (length(table_files) == 0) stop("No results found in outputs/tables/. Run scripts 02-06 first.")

reported <- read.csv(reported_file, check.names = FALSE, stringsAsFactors = FALSE)
computed <- do.call(rbind, lapply(table_files, read.csv, check.names = FALSE, stringsAsFactors = FALSE))

key <- function(d) paste(d$analysis, d$series_or_region, d$period, sep = " | ")
computed_row <- match(key(reported), key(computed))

status <- character(nrow(reported))
for (k in seq_len(nrow(reported))) {
  r <- computed_row[k]
  if (is.na(r)) { status[k] <- "NOT RUN"; next }
  p_ok     <- abs(reported$mk_p_value[k] - computed$mk_p_value[r]) <= 0.0015
  slope_ok <- abs(reported$sens_slope_per_year[k] - computed$sens_slope_per_year[r]) <=
                0.01 * max(abs(reported$sens_slope_per_year[k]), 0.01)
  status[k] <- if (p_ok && slope_ok) "MATCH" else "DIFFERENT"
}

report <- data.frame(
  analysis       = reported$analysis,
  series         = reported$series_or_region,
  period         = reported$period,
  reported_p     = reported$mk_p_value,
  computed_p     = ifelse(is.na(computed_row), NA, computed$mk_p_value[computed_row]),
  reported_slope = reported$sens_slope_per_year,
  computed_slope = ifelse(is.na(computed_row), NA, computed$sens_slope_per_year[computed_row]),
  status         = status
)
print(report, row.names = FALSE)
cat("\n", sum(status == "MATCH"), "of", length(status), "analyses match the reported results.\n")
