# Pathway Enrichment analysis using KEGG 2021 Human database

This folder contains the code for plotting the Figure 4 from the paper.

### Folder contents
-  KEGG_2021_Human_ENRICHR.tsv: The output file from Enrichr web-application.
-  KEGG_2021_Human_KEGGID&Class.tsv: The manually curated pathway identifiers and classifications from KEGG database.
-  KEGG_2021_Human_bgdata.tsv: The complete list of pathways and their corresponding gene sets from Enrichr librabries.
-  KEGG_Enrichment_Jaccard.ipynb: The python code to understand and plot the data.

The code files include inline and commented description to describe each step in the code.

The jupyter notebook contains all the steps to plot the bubble-plot (Figure 4a) and extract the edges and nodes for pathway similarity network (Figure 4b). The edge and nodes were imported onto Cytoscape v3.9.1 for visualization.
