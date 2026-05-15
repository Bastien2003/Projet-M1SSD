# Analyse de données sérologiques par méthodes statistiques

## Description du projet

Ce projet a été réalisé dans le cadre du Master Mathématiques Statistique et Sciences des Données.

L’objectif est d’étudier deux méthodes différentes de détermination de seuils sérologiques à partir de données de MFI (Mean Fluorescence Intensity) issues d’analyses sérologiques sur des populations de chauves-souris.

Les deux approches principales étudiées sont :

- méthode des valeurs extrêmes (outlier) ;
- modèles de mélanges gaussiens (Gaussian Mixture Models, GMM).

Le projet comprend :
- l’estimation des seuils sérologiques ;
- le calcul des prévalences ;
- la comparaison des différentes méthodes ;
- la réalisation de graphiques et tableaux ;
- la rédaction d’un rapport.

---

## Auteurs 

Projet réalisé par : 
- Bastien MAGGI
- Mohammed JABRI

Encadrer par : 
- Benjamin CUER

## Struture du projet 

Projet-GMM/
│
├── README.md
├── rapport/
│   └── rapport.pdf
│
├── data/
│   └── ebosursy_all_bats_clean_9593.csv
│
├── scripts/
│   ├── 01_preparation_donnees.R
│   ├── 02_cutoff_outlier.R
│   ├── 03_gmm.R
│   ├── 04_graphiques.R
│   ├── 05_tableaux.R
│   └── fonctions.R
│
├── figures/
│   ├── figure_distribution.png
│   ├── figure_outlier.png
│   └── figure_gmm.png
│
└── tables/
    └── table_cutoffs.tex

Projet-M1_SSD/
│
├── README.md
├── rapport/
|   ├── Projet_M1.tex
│   └── Projet_M1.pdf
|
├── CodeR/
│   ├── mfi_fonction.R
│   ├── mfi_graphe.R
│   ├── mfi_prevalence.R
│   ├── mfi_tab.R
│   └── tableau_desciptif.R
|
|
├── figures/
│   ├── graphe_gmm_mfi
│   ├── graphe_mfi
│   └── graphe_outlier_mfi
│
└── tables/
│   ├── table_descriptif.tex
│   ├── table_parametre.tex
    └── table_prevalence.tex
