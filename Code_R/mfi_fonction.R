library(dplyr)
library(tidyr)
library(ggplot2)
library(mclust)

df <- read.csv("ebosursy_all_bats_clean_9593.csv")

mfi_vars <- c(
  "NP.ZEBV", "GP.ZEBVkiss", "GP.ZEBVmay", "VP40.ZEBV",
  "NP.SEBV", "GP.SEBV", "VP40.SEBV",
  "GP.BEBV", "VP40.BEBV",
  "GP.REBV", "GP.BOMV"
)

# enlever les colonnes entièrement NA
mfi_vars <- mfi_vars[!sapply(df[mfi_vars], function(x) all(is.na(x)))]


# données en format long
df_long <- df %>%
  select(all_of(mfi_vars)) %>%
  pivot_longer(
    cols = everything(),
    names_to = "MFI",
    values_to = "valeur"
  ) %>%
  filter(!is.na(valeur)) %>%
  mutate(log_valeur = log10(valeur + 1)) # Transformation log


# Fonctions de calcul cut-off outlier
calc_cutoff_outlier <- function(x, prop_control = 0.5, k = 3) {
  x <- x[!is.na(x)]
  if (length(x) < 2) return(NA_real_)

  x_trie <- sort(x)
  n_control <- floor(length(x_trie) * prop_control)
  control <- x_trie[1:n_control]

  control_log <- log10(control + 1)

  mean(control_log) + k * sd(control_log)
}


# Fonction qui effectue un clustering à 2 classe
fit_gmm_2 <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) < 10) return(NULL)

  x_log <- log10(x + 1)

  gmm <- tryCatch(
    Mclust(x_log, G = 2),
    error = function(e) NULL
  )

  if (is.null(gmm)) return(NULL)

  pro <- gmm$parameters$pro
  means <- gmm$parameters$mean
  sds <- sqrt(gmm$parameters$variance$sigmasq)

  ord <- order(means) # # Ordonner les composantes par moyenne croissante

  list(
    x_log = x_log,
    pro = pro[ord],
    means = means[ord],
    sds = sds[ord],
    gmm = gmm,
    ord = ord
  )
}

# Fonction Cut-off GMM par intersection des deux gaussiennes
calc_cutoff_gmm_uniroot <- function(x) {
  fit <- fit_gmm_2(x)
  if (is.null(fit)) return(NA_real_)

  f_cut <- function(t) {
    fit$pro[1] * dnorm(t, fit$means[1], fit$sds[1]) -
      fit$pro[2] * dnorm(t, fit$means[2], fit$sds[2])
  }

  tryCatch(
    uniroot(f_cut, interval = c(fit$means[1], fit$means[2]))$root,
    error = function(e) NA_real_
  )
}


# Fonction Cut-off GMM outlier
calc_cutoff_gmm_outlier <- function(x, k = 3) {
  fit <- fit_gmm_2(x)
  if (is.null(fit)) return(NA_real_)

  fit$means[1] + k * fit$sds[1]
}

# Tableau des cut-offs
cutoff_df <- data.frame(
  MFI = mfi_vars,
  cutoff_outlier = sapply(mfi_vars, function(v) calc_cutoff_outlier(df[[v]])),
  cutoff_gmm_uniroot = sapply(mfi_vars, function(v) calc_cutoff_gmm_uniroot(df[[v]])),
  cutoff_gmm_outlier = sapply(mfi_vars, function(v) calc_cutoff_gmm_outlier(df[[v]]))
)
cutoff_df <- cutoff_df %>%
  mutate(across(-MFI, ~ round(., 2)))
cutoff_df

# Fonction pour la densité des valeurs control outlier
get_control_gaussian <- function(data, varname, prop_control = 0.5) {
  x <- data[[varname]]
  x <- x[!is.na(x)]
  if (length(x) < 2) return(NULL)

  x_log <- log10(x + 1)

  x_trie <- sort(x)
  n_control <- floor(length(x_trie) * prop_control)
  control <- x_trie[1:n_control]
  control_log <- log10(control + 1)

  mu_control <- mean(control_log)
  sd_control <- sd(control_log)

  grid_x <- seq(min(x_log), max(x_log), length.out = 500)

  data.frame(
    MFI = varname,
    x = grid_x,
    dens_control_gauss = dnorm(grid_x, mean = mu_control, sd = sd_control) * prop_control
  )
}

control_gauss_df <- bind_rows(
  lapply(mfi_vars, function(v) get_control_gaussian(df, v))
)

# Fonction pour les densités GMM pour chaque MFI.
get_gmm_density <- function(data, varname) {
  fit <- fit_gmm_2(data[[varname]])
  if (is.null(fit)) return(NULL)

  grid_x <- seq(min(fit$x_log), max(fit$x_log), length.out = 500)

  data.frame(
    MFI = varname,
    x = grid_x,
    dens_neg = fit$pro[1] * dnorm(grid_x, fit$means[1], fit$sds[1]),
    dens_pos = fit$pro[2] * dnorm(grid_x, fit$means[2], fit$sds[2])
  ) %>%
    mutate(dens_mix = dens_neg + dens_pos)
}

gmm_density_df <- bind_rows(
  lapply(mfi_vars, function(v) get_gmm_density(df, v))
)
