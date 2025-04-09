# Disease Enrichment analysis using the DisGeNET v7.0 (2020)

Please download the **DisGeNET SQLite 2020 - v7.0** from https://www.disgenet.org/downloads to execute the following codes.

This folder contains the code for plotting the Figure 7 from the paper.

### Folder contents:
- RCode_diseaseEnrichment.R: The R code to run the enrichment analysis of the diseases on EPEK genelist
- Rcode_DiseaseClassaddition.R: The R code to fetch the disease codes and MeSH classes from the database.
- Disease_Enrichment_jaccard.ipynb: The jupyter notebook containing python code to understand and plot the data.

The R code files include inline and commented description to describe each step in the code.

The jupyter notebook contains all the steps to plot the bubble-plot (Figure 7a) and extract the edges and nodes for disease similarity network (Figure 7b). The edges and nodes were imported onto Cytoscape v3.9.1 for visualization.
