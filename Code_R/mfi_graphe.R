library(dplyr)
library(tidyr)
library(ggplot2)
library(mclust)

source("mfi_fonction.R")

# graphe simple
g <- ggplot(df_long, aes(x = log_valeur)) +
  geom_histogram(
    aes(y = after_stat(density)),
    bins = 30,
    fill = "lightblue",
    color = "black"
  ) +
  geom_density(
    aes(y = after_stat(density)),
    linewidth = 1)+
  theme_classic()+
  coord_cartesian(xlim = c(0, 4)) +
  facet_wrap(~ MFI, scales = "free") +
  labs(
    x = "log10(MFI + 1)",
    y = "Densité"
  )
g


# graphe gmm
clustering_plot <- ggplot(df_long, aes(x = log_valeur)) +
  geom_histogram(
    aes(y = after_stat(density)),
    bins = 30,
    fill = "lightblue",
    color = "black",
    alpha = 0.7
  ) +
  geom_line(
    data = gmm_density_df,
    aes(x = x, y = dens_neg),
    linewidth = 1,
    color = "red"
  ) +
  geom_line(
    data = gmm_density_df,
    aes(x = x, y = dens_pos),
    linewidth = 1,
    color = "blue"
  ) +
  geom_vline(
    data = cutoff_df,
    aes(xintercept = cutoff_gmm_uniroot),
    linewidth = 0.8,
    linetype = "dashed",
    color = "black"
  ) +
  geom_vline(
    data = cutoff_df,
    aes(xintercept = cutoff_gmm_outlier),
    linewidth = 0.8,
    linetype = "dashed",
    color = 'red',
  ) +
  facet_wrap(~ MFI, scales = "free") +
  coord_cartesian(xlim = c(0, 4)) +
  theme_classic() +
  labs(
    x = "log10(MFI + 1)",
    y = "Densité"
  )
clustering_plot

# graphe outlier
outlier_plot <- ggplot() +
  geom_histogram(
    data = df_long,
    aes(x = log_valeur, y = after_stat(density)),
    bins = 30,
    fill = "lightblue",
    color = "black",
    alpha = 0.7
  ) +
  geom_line(
    data = control_gauss_df,
    aes(x = x, y = dens_control_gauss),
    color = "red",
    linewidth = 1
  ) +
  geom_vline(
    data = cutoff_df,
    aes(xintercept = cutoff_outlier),
    color = "red",
    linetype = "dashed",
    linewidth = 0.8
  ) +
  facet_wrap(~ MFI, scales = "free") +
  coord_cartesian(xlim = c(0, 4)) +
  theme_classic() +
  labs(
    x = "log10(MFI + 1)",
    y = "Densité"
  )
outlier_plot

# création d'un dossier pour stocker les graphes
dir.create("figures", showWarnings = FALSE)

# sauvegarde des graphe au format pdf
ggsave("figures/graphe_mfi.pdf", g, width = 12, height = 8, dpi = 300)
ggsave("figures/graphe_gmm_mfi.pdf", clustering_plot, width = 12, height = 8, dpi = 300)
ggsave("figures/graphe_outlier_mfi.pdf", outlier_plot, width = 12, height = 8, dpi = 300)

