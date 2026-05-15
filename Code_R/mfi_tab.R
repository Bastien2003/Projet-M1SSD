library(dplyr)
library(tidyr)
library(ggplot2)
library(mclust)
library(gt)

df <- read.csv("ebosursy_all_bats_clean_9593.csv")

mfi_vars <- c(
  "NP.ZEBV", "GP.ZEBVkiss", "GP.ZEBVmay", "VP40.ZEBV",
  "NP.SEBV", "GP.SEBV", "VP40.SEBV",
  "GP.BEBV", "VP40.BEBV",
  "GP.REBV", "GP.BOMV"
)

# enlever les colonnes entièrement NA
mfi_vars <- mfi_vars[!sapply(df[mfi_vars], function(x) all(is.na(x)))]

compute_all_stats <- function(x, prop_control = 0.5) {
  x <- x[!is.na(x)]

  if (length(x) < 2) {
    return(NULL)
  }

  x_log <- log10(x + 1)

  # -------------------------
  # OUTLIER
  # -------------------------
  x_trie <- sort(x)
  n_control <- floor(length(x_trie) * prop_control)
  control <- x_trie[1:n_control]
  control_log <- log10(control + 1)

  mean_outlier <- mean(control_log)
  sd_outlier <- sd(control_log)

  # -------------------------
  # GMM
  # -------------------------
  gmm <- tryCatch(
    Mclust(x_log, G = 2, modelNames = "V"),
    error = function(e) NULL
  )

  if (is.null(gmm)) {
    return(list(
      mean_outlier = mean_outlier,
      sd_outlier = sd_outlier,
      mean_gmm = c(NA, NA),
      sd_gmm = c(NA, NA)
    ))
  }

  means <- gmm$parameters$mean
  sds <- sqrt(gmm$parameters$variance$sigmasq)

  ord <- order(means)

  list(
    mean_outlier = mean_outlier,
    sd_outlier = sd_outlier,
    mean_gmm = means[ord],
    sd_gmm = sds[ord],
    gmm = gmm  # 🔥 important : on garde le modèle complet
  )
}

all_stats <- lapply(mfi_vars, function(v) compute_all_stats(df[[v]]))
names(all_stats) <- mfi_vars


params_table <- data.frame(
  MFI = mfi_vars,
  mean_outlier = sapply(all_stats, function(x) x$mean_outlier),
  sd_outlier = sapply(all_stats, function(x) x$sd_outlier),
  mean_gmm_1 = sapply(all_stats, function(x) x$mean_gmm[1]),
  sd_gmm_1 = sapply(all_stats, function(x) x$sd_gmm[1]),
  mean_gmm_2 = sapply(all_stats, function(x) x$mean_gmm[2]),
  sd_gmm_2 = sapply(all_stats, function(x) x$sd_gmm[2])
)

params_table

params_tableau <- params_table %>%
  mutate(across(-MFI, ~ round(., 2)))

params_tableau

# code LaTeX du tableau
library(knitr)

latex_table <- kable(
  params_tableau,
  format = "latex",
  booktabs = TRUE,
  caption = "Moyenne et écart type Méthode 1 et 2"
)

cat(latex_table)

# sauvegarde du tableau en LaTeX
writeLines(latex_table, "table/table_params.tex")


