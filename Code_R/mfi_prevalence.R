library(dplyr)
library(mclust)
library(gt)

source("mfi_fonction.R")

# -------------------------
# Fonctions de prévalence
# -------------------------

calc_prev_outlier <- function(x, cutoff_outlier) {
  x <- x[!is.na(x)]
  if (length(x) == 0 || is.na(cutoff_outlier)) return(NA_real_)

  x_log <- log10(x + 1)
  mean(x_log > cutoff_outlier)
}

calc_prev_gmm_uniroot <- function(x, cutoff_gmm_uniroot) {
  x <- x[!is.na(x)]
  if (length(x) == 0 || is.na(cutoff_gmm_uniroot)) return(NA_real_)

  x_log <- log10(x + 1)
  mean(x_log > cutoff_gmm_uniroot)
}

calc_prev_gmm_outlier <- function(x, cutoff_gmm_outlier) {
  x <- x[!is.na(x)]
  if (length(x) == 0 || is.na(cutoff_gmm_outlier)) return(NA_real_)

  x_log <- log10(x + 1)
  mean(x_log > cutoff_gmm_outlier)
}

# -------------------------
# Tableau cutoffs + prévalences
# -------------------------

tab_df <- cutoff_df %>%
  rowwise() %>%
  mutate(
    prev_outlier = calc_prev_outlier(
      df[[MFI]],
      cutoff_outlier
    ),
    prev_gmm_uniroot = calc_prev_gmm_uniroot(
      df[[MFI]],
      cutoff_gmm_uniroot
    ),
    prev_gmm_outlier = calc_prev_gmm_outlier(
      df[[MFI]],
      cutoff_gmm_outlier
    )
  ) %>%
  ungroup()

# Arondir les valeurs
tab_prev <- tab_df %>%
  mutate(
    across(
      c(cutoff_outlier, cutoff_gmm_uniroot, cutoff_gmm_outlier),
      ~ round(., 2)
    ),
    across(
      c(prev_outlier, prev_gmm_uniroot, prev_gmm_outlier),
      ~ round(100 * ., 1)
    )
  )

# affichage du tableau avec gt

tab_prev %>%
  gt() %>%
  tab_header(
    title = "Cut-offs et prévalences estimées par antigène"
  ) %>%
  cols_label(
    MFI = "Antigène",
    cutoff_outlier = "cut-off outlier",
    prev_outlier = "prévalence outlier (%)",
    cutoff_gmm_uniroot = "cut-off GMM uniroot",
    prev_gmm_uniroot = "prévalence GMM uniroot (%)",
    cutoff_gmm_outlier = "cut-off GMM outlier",
    prev_gmm_outlier = "prévalence GMM outlier (%)"
  )


# création d'un dossier pour stocker les tableaux
dir.create("table", showWarnings = FALSE)

# code LaTeX du tableau
library(knitr)

latex_table <- kable(
  tab_prev,
  format = "latex",
  booktabs = TRUE,
  caption = "Cut-offs et prévalences estimées par antigène"
)

cat(latex_table)

# sauvegarde du tableau en LaTeX
writeLines(latex_table, "table/table_prev_cutoffs.tex")



