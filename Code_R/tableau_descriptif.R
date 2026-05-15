library(dplyr)
library(gtsummary)

df <- read.csv("ebosursy_all_bats_clean_9593.csv")


df <- df %>%
  mutate(
    Pays = as.factor(Pays),
    Sexe = as.factor(Sexe),
    Age = as.factor(Age),
    Gestante = as.factor(Gestante),
    Lactation = as.factor(Lactation)
  )

tbl <- df %>%
  select(Pays, Sexe, Age, Gestante, Lactation) %>%
  tbl_summary(
    statistic = all_categorical() ~ "{n} ({p}%)",
    missing = "ifany"
  ) %>%
  bold_labels()

tbl

# code LaTeX du tableau
library(knitr)

latex_table <- kable(
  tbl,
  format = "latex",
  booktabs = TRUE,
  caption = "Tableau descriptif"
)

cat(latex_table)

# sauvegarde du tableau en LaTeX
writeLines(latex_table, "table/table_descriptif.tex")
