# Chained-run helper for the H1D-K2 coupling (Phase 2 restart-equivalence tool).
# Runs k2_h1d.exe one period at a time: stdin answers, shifted rain file,
# k2_infil.in (constant infiltration per period), k2_state.in/out hand-off.

k2_read_pre <- function(path) {
  x <- trimws(sub("!.*$", "", readLines(path, warn = FALSE)))
  i <- grep("^N *=", x)
  n <- as.integer(sub("^N *= *", "", x[i]))
  rows <- x[(i + 1):length(x)]
  rows <- rows[grepl("^[0-9.+-]", rows)][seq_len(n)]
  m <- do.call(rbind, lapply(strsplit(rows, "[[:space:]]+"), as.numeric))
  data.frame(time = m[, 1], depth = m[, 2])
}

# Cumulative-depth hyetograph restricted to [t0, t1], re-zeroed at t0.
k2_shift_rain <- function(rain, t0, t1) {
  tt <- sort(unique(c(t0, rain$time[rain$time > t0 & rain$time < t1], t1)))
  d <- approx(rain$time, rain$depth, xout = tt, rule = 2)$y
  data.frame(time = tt - t0, depth = d - d[1])
}

k2_write_pre <- function(rain, path, gauge = "RG001") {
  lines <- c(
    paste("BEGIN", gauge), "", paste0("   N = ", nrow(rain)), "",
    "    TIME          DEPTH", "!   (min)         (mm)", "",
    sprintf("%9.4f  %14.6f", rain$time, rain$depth), "", "END"
  )
  writeLines(lines, path, sep = "\n")
}

k2_read_state <- function(path) {
  x <- read.table(path, skip = 1, col.names = c("h", "q", "topw", "xc"))
  x
}

# One period. `fav` is length nk (m/s); node 1 is ignored by K2.
k2_run_period <- function(exe, par, rain, t0, t1, fav, workdir,
                          state_in = NULL, step = 1) {
  exe <- normalizePath(exe, mustWork = TRUE)
  par <- normalizePath(par, mustWork = TRUE)
  dir.create(workdir, showWarnings = FALSE, recursive = TRUE)
  old <- setwd(workdir)
  on.exit(setwd(old))
  unlink(c("kin.fil", "mult.fil", "k2_state.in", "k2_state.out",
           "k2_period.out", "k2_infil.in"))
  file.copy(par, "RUN.PAR", overwrite = TRUE)
  k2_write_pre(k2_shift_rain(rain, t0, t1), "RUN.PRE")
  writeLines(c(as.character(length(fav)), paste(format(fav, digits = 15), collapse = " ")),
             "k2_infil.in")
  if (!is.null(state_in)) {
    writeLines(c(as.character(nrow(state_in)),
                 sprintf("%.9e %.9e %.9e %.9e", state_in$h, state_in$q,
                         state_in$topw, state_in$xc)), "k2_state.in")
  }
  ans <- c("RUN.PAR", "RUN.PRE", "run.out", "k2 chained period",
           format(t1 - t0), format(step), "n", "y", "n", "n")
  log <- system2(exe, input = ans, stdout = TRUE, stderr = TRUE)
  if (!file.exists("k2_period.out") || !file.exists("k2_state.out"))
    stop("K2 run failed:\n", paste(utils::tail(log, 10), collapse = "\n"))
  per <- scan("k2_period.out", skip = 1, quiet = TRUE)
  names(per) <- c("rain_vol", "infil_vol", "stor_vol", "out_vol", "hmean", "out_q")
  list(period = per, state = k2_read_state("k2_state.out"))
}

# Chain periods over breaks (e.g. c(0, 20, 40)); fav may be a vector (constant)
# or a function(period_index, state) returning a vector.
k2_chain <- function(exe, par, rain, breaks, fav, workdir, step = 1) {
  state <- NULL
  out <- vector("list", length(breaks) - 1)
  for (i in seq_along(out)) {
    f <- if (is.function(fav)) fav(i, state) else fav
    r <- k2_run_period(exe, par, rain, breaks[i], breaks[i + 1], f,
                       workdir, state, step)
    state <- r$state
    out[[i]] <- r$period
  }
  list(periods = do.call(rbind, out), state = state)
}
