# Data

The raw data is **not** stored in this repository (the files are large, and IMD is the data owner). Download it and place the files in this `data/` folder.

## Source

India Meteorological Department (IMD), Pune: **Yearly Gridded Rainfall (0.25° × 0.25°), NetCDF files**
https://imdpune.gov.in/cmpg/Griddata/Rainfall_25_NetCDF.html

- Daily rainfall in mm, one file per year (365 or 366 daily records).
- Grid: 135 × 129 points, from 6.5°N, 66.5°E to 38.5°N, 100.0°E.
- This project uses the years **1983–2022** (40 files).

## What the scripts expect

- File names like `RF25_ind1983_rfp25.nc`, one per year from 1983 to 2022
- A variable `RAINFALL` with dimensions ordered `LONGITUDE`, `LATITUDE`, `TIME` (script 01 stops with an error if the order differs)

## Files created by the scripts

- `delhi_rainfall_1983_2022.rds`: the four Delhi pixels for all days, made by `scripts/01_prepare_delhi_data.R`. It is small, but it can be recreated at any time, so it is not committed.

## Citation

IMD asks users to cite:

Pai, D. S., Sridhar, L., Rajeevan, M., Sreejith, O. P., Satbhai, N. S., & Mukhopadyay, B. (2014). Development of a new high spatial resolution (0.25° × 0.25°) long period (1901–2010) daily gridded rainfall data set over India and its comparison with existing data sets over the region. *MAUSAM, 65*(1), 1–18.

IMD provides the data without any guarantee of correctness; see the disclaimer on the download page.
