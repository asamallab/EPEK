# PLotting UpSet plots for maternal health database comparisons

library(UpSetR)

## Change working directory to the folder containing the script file
#setwd("~/Comparison/")

# reading the different datasets:
#1. EPEK
epek = read.delim("Datasets/EPEK.tsv")
#2. PrcocityDB
PrecocityDB = read.delim("Datasets/PrecocityDB.tsv")
#3. PcosKB - curated list
PcosKB = read.delim("Datasets/PcosKB_manually_curated.tsv")
#4. EndometDB
EndometKB = read.delim("Datasets/EndometKB.tsv")
#5. CCDB
CCDB = read.delim("Datasets/CCDB.tsv")
#6. Gestational Diabetes
Gestdb = read.delim("Datasets/GestationalDiabetes.csv")
#7. Preeclampsia
preeclampsia = read.delim("Datasets/Preeclampsia.csv")
#8. Preterm Birth
preterm = read.delim("Datasets/PretermBirth.csv")
#9. Placental Abruption
placenta = read.delim("Datasets/PlacentalAbruption.csv")

Listinput <- list(EPEK = epek$OfficialGeneSymbol, PrecocityDB = PrecocityDB$Gene_Symbol, PcosKB = PcosKB$Gene.Symbol,Endometriosis_Knowledgebase = EndometKB$GeneSymbol, CCDB = CCDB$GeneSymbol, Gestational_diabetes = Gestdb$OfficialSymbol, Placental_Abruption = placenta$OfficialSymbol, Preterm_Birth = preterm$OfficialSymbol, Preeclampsia = preeclampsia$OfficialSample)

# Querying the set
upset(fromList(Listinput), order.by = 'freq', mainbar.y.label = "Intersection Size", sets.x.label = "Number of Genes",keep.order = TRUE,sets = c('PrecocityDB','Placental_Abruption', 'Gestational_diabetes','Preterm_Birth','Preeclampsia','CCDB','PcosKB','Endometriosis_Knowledgebase', 'EPEK'),mainbar.y.max = 520,queries = list(list(query = intersects, params = list("EPEK"), color = "red", active = T)))

## Savefile as pdf
# pdf(file = 'comparison_upset.pdf',onefile = FALSE)
