# EPEK

This repository provides the datasets and codes associated with the following manuscript:

Ananya Natarajan<sup>#</sup>, Nikhil Chivukula<sup>#</sup>, Gokul Balaji Dhanakoti, Ajaya Kumar Sahoo, Janani Ravichandran*, Areejit Samal*, <i>[EPEK: creation and analysis of an Ectopic Pregnancy Expression Knowledgebase](https://www.biorxiv.org/content/10.1101/2022.12.20.521279v1)</i> bioRxiv 2022.12.20.521279.<br>
(<sup>#</sup> Joint First Authors, * Corresponding Authors)

## Repository Organization
This repository is organized into two folders, EnrichmentAnalysis and Comparison

### Enrichment Analysis:
This folder contains the code to plot for:
- GO Term enrichment analysis (Figure 3)
- Pathway enrichment analysis (Figure 4)
- Disease enrichment analysis (Figure 7)

### Comparison:
This folder contains the code to generate UpSet plot (Figure 6).

Each folder has additional README files explaining the contents within them.

## Software requirements
Python package requirements:
pandas, seaborn, Matplotlib, NumPy

R package requirements:
UpSetR, SQLite, readxl, writexl
