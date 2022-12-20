# Accessing the DisGeNET database SQLite file for Enrichment analysis.

# Set working directory to the database folder
#setwd("~/DiseaseEnrichment/")

# Load Necessary Packages
library(RSQLite)
library(readxl)

# Read the genes from EPEK.
epek <- read_excel("EP_unique_ENSEmBLID_list_314.xlsx", 
                   col_types = c("skip", "text", "text", "text", "text"),
                   col_names = TRUE,
                   .name_repair = 'unique',skip = 1) #skipping an additional header line on top!

#getting list of unique gene-symbols as a string for SQL query.
# Get a list of the genesymbols
listofgenesyms <- list(epek$OfficialGeneSymbol)
# Convert list to string
listofgenesymstostring <- toString(listofgenesyms)
#remove any newline characters
listofgenesymstostring <- sub('/n','',listofgenesymstostring)
#remove the initial 'c' character from the string
epekgenesymlist <- gsub('^.','',listofgenesymstostring)



#Connect to the database file in the folder
conn <- dbConnect(RSQLite::SQLite(),'disgenet_2020.db')

# 24-11-2022, database release -> 2020, version 7.0

#List tables available in the database
#ListofTables <- dbListTables(conn)

#The database can be queried for necessary information
#Example:
#dbGetQuery(conn,sprintf('SELECT * from %s',ListofTables[1]))

#User Input for Disgenet GDA score cut-off, and Evidence Index value cut-off:
gda_cutoff <- readline(prompt = 'Enter GDA cut-off: ')
gda_cutoff <- as.numeric(gda_cutoff)

ei_cutoff <- readline(prompt = 'Enter Ei cut-off: ')
ei_cutoff <- as.numeric(ei_cutoff)

#------------ SQL statements in one place! ----------------------------------
#1. To count the number of connections in the genediseasenetwork
numconn <- sprintf("SELECT COUNT(*) from geneDiseaseNetwork WHERE source in ('CTD_human','CGI','CLINGEN','GENOMICS_ENGLAND','ORPHANET','PSYGENET','UNIPROT') AND score > %s AND EI > %s",gda_cutoff,ei_cutoff)

#2. To get the names of unique diseases which obey the GDA and EI cut-offs.
getuniquediseaselist <- sprintf("SELECT DISTINCT diseaseAttributes.diseaseName from diseaseAttributes INNER JOIN geneDiseaseNetwork ON diseaseAttributes.diseaseNID = geneDiseaseNetwork.diseaseNID WHERE geneDiseaseNetwork.source in ('CTD_human','CGI','CLINGEN','GENOMICS_ENGLAND','ORPHANET','PSYGENET','UNIPROT') AND geneDiseaseNetwork.score > %s AND geneDiseaseNetwork.EI > %s",gda_cutoff,ei_cutoff)

#3. Get a list of unique genes in the network connected to the disease of Interest.
getuniquegenecount <- sprintf("SELECT COUNT(DISTINCT geneDiseaseNetwork.geneNID) from diseaseAttributes INNER JOIN geneDiseaseNetwork ON diseaseAttributes.diseaseNID = geneDiseaseNetwork.diseaseNID WHERE diseaseAttributes.diseaseName in (\"%s\") AND geneDiseaseNetwork.source in ('CTD_human','CGI','CLINGEN','GENOMICS_ENGLAND','ORPHANET','PSYGENET','UNIPROT') AND geneDiseaseNetwork.score > %s AND geneDiseaseNetwork.EI > %s",diseasename, gda_cutoff, ei_cutoff)

#4. Get count of genes from the input list, and connected to the diseases
getinputgenecount <- sprintf("SELECT COUNT(DISTINCT geneDiseaseNetwork.geneNID) from geneDiseaseNetwork INNER JOIN diseaseAttributes ON diseaseAttributes.diseaseNID = geneDiseaseNetwork.diseaseNID INNER JOIN geneAttributes ON geneAttributes.geneNID = geneDiseaseNetwork.geneNID WHERE geneAttributes.geneName in %s AND diseaseAttributes.diseaseName in (\"%s\") AND geneDiseaseNetwork.source in ('CTD_human','CGI','CLINGEN','GENOMICS_ENGLAND','ORPHANET','PSYGENET','UNIPROT') AND geneDiseaseNetwork.score > %s AND geneDiseaseNetwork.EI > %s",epekgenesymlist,diseasename, gda_cutoff, ei_cutoff)

#5. Get total unique genes in geneDiseaseNetwork
gettotaluniquegenescount <- sprintf("SELECT COUNT(DISTINCT geneNID) from geneDiseaseNetwork WHERE source in ('CTD_human','CGI','CLINGEN','GENOMICS_ENGLAND','ORPHANET','PSYGENET','UNIPROT') AND score > %s AND EI > %s", gda_cutoff, ei_cutoff)

#6. Get total input genes present in the geneDiseaseNetwork.
gettotalinputgenescount <- sprintf("SELECT COUNT(DISTINCT geneDiseaseNetwork.geneNID) from geneDiseaseNetwork INNER JOIN geneAttributes ON geneAttributes.geneNID = geneDiseaseNetwork.geneNID WHERE geneAttributes.geneName in %s AND geneDiseaseNetwork.source in ('CTD_human','CGI','CLINGEN','GENOMICS_ENGLAND','ORPHANET','PSYGENET','UNIPROT') AND geneDiseaseNetwork.score > %s AND geneDiseaseNetwork.EI > %s",epekgenesymlist, gda_cutoff, ei_cutoff)

#7. Get the list of all gene symbols associated with the disease in the network..
getlisttotalgenesym <- sprintf("SELECT GROUP_CONCAT(geneAttributes.geneName, ';') from geneDiseaseNetwork INNER JOIN diseaseAttributes ON diseaseAttributes.diseaseNID = geneDiseaseNetwork.diseaseNID INNER JOIN geneAttributes ON geneAttributes.geneNID = geneDiseaseNetwork.geneNID WHERE diseaseAttributes.diseaseName in (\"%s\") AND geneDiseaseNetwork.source in ('CTD_human','CGI','CLINGEN','GENOMICS_ENGLAND','ORPHANET','PSYGENET','UNIPROT') AND geneDiseaseNetwork.score > %s AND geneDiseaseNetwork.EI > %s",diseasename, gda_cutoff, ei_cutoff)

#8. Get the list of all INPUT gene symbols associated with the disease in the network..
getlisttotalinputgenesym <- sprintf("SELECT GROUP_CONCAT(geneAttributes.geneName, ';') from geneDiseaseNetwork INNER JOIN diseaseAttributes ON diseaseAttributes.diseaseNID = geneDiseaseNetwork.diseaseNID INNER JOIN geneAttributes ON geneAttributes.geneNID = geneDiseaseNetwork.geneNID WHERE geneAttributes.geneName in %s AND diseaseAttributes.diseaseName in (\"%s\") AND geneDiseaseNetwork.source in ('CTD_human','CGI','CLINGEN','GENOMICS_ENGLAND','ORPHANET','PSYGENET','UNIPROT') AND geneDiseaseNetwork.score > %s AND geneDiseaseNetwork.EI > %s",epekgenesymlist,diseasename, gda_cutoff, ei_cutoff)


# ------------------------ CODE  ----------------------------

#Getting list of Unique Disease in the Database
Uniquediseases <- dbGetQuery(conn,getuniquediseaselist)

# storing the values into a matrix.
#first column is Disease Name.
diseaseenrichmentmat <- matrix(unlist(Uniquediseases[1]),ncol=1)
#second column is number  of genes associated to disease in Disgenet filtered DB.
diseaseenrichmentmat <- cbind(diseaseenrichmentmat,0)
#third column is the list of genes associated to disease in Disgenet filtered DB.
diseaseenrichmentmat <- cbind(diseaseenrichmentmat,0)
#fourth column is number of genes from input associated to disease in the Disgenet filtered DB.
diseaseenrichmentmat <- cbind(diseaseenrichmentmat,0)
#Fifth column is the list of genes from input associated to disease in the Disgenet filtered DB.
diseaseenrichmentmat <- cbind(diseaseenrichmentmat,0)


# THE FOLLOWING CODE FILTERS THE DISGENET DATABASE FOR CURATED ENTRIES WITH THE USER DEFINED GDA SCORE AND EI CUTOFF VALUES

cat('SQL query for gene_count and gene_list started \n')
for(i in 1:nrow(diseaseenrichmentmat)){
  diseasename <- diseaseenrichmentmat[i,1]
  #cat(diseasename)
  getuniquegenecountandlist <- sprintf("SELECT COUNT(DISTINCT geneDiseaseNetwork.geneNID), GROUP_CONCAT(geneAttributes.geneName, ';') from diseaseAttributes INNER JOIN geneDiseaseNetwork ON diseaseAttributes.diseaseNID = geneDiseaseNetwork.diseaseNID INNER JOIN geneAttributes ON geneAttributes.geneNID = geneDiseaseNetwork.geneNID WHERE diseaseAttributes.diseaseName in (\"%s\") AND geneDiseaseNetwork.source in ('CTD_human','CGI','CLINGEN','GENOMICS_ENGLAND','ORPHANET','PSYGENET','UNIPROT') AND geneDiseaseNetwork.score > %s AND geneDiseaseNetwork.EI > %s",diseasename,gda_cutoff,ei_cutoff)
  genecountandlist <- dbGetQuery(conn,getuniquegenecountandlist)
  getinputgenecountandlist <- sprintf("SELECT COUNT(DISTINCT geneDiseaseNetwork.geneNID), GROUP_CONCAT(geneAttributes.geneName, ';') from geneDiseaseNetwork INNER JOIN diseaseAttributes ON diseaseAttributes.diseaseNID = geneDiseaseNetwork.diseaseNID INNER JOIN geneAttributes ON geneAttributes.geneNID = geneDiseaseNetwork.geneNID WHERE geneAttributes.geneName in %s AND diseaseAttributes.diseaseName in (\"%s\") AND geneDiseaseNetwork.source in ('CTD_human','CGI','CLINGEN','GENOMICS_ENGLAND','ORPHANET','PSYGENET','UNIPROT') AND geneDiseaseNetwork.score > %s AND geneDiseaseNetwork.EI > %s",epekgenesymlist,diseasename, gda_cutoff, ei_cutoff)
  inputgenecountandlist <- dbGetQuery(conn,getinputgenecountandlist)
  #cat(genecount[[1]],'\n')
  diseaseenrichmentmat[i,2] <- as.numeric(genecountandlist[[1]]) # for count
  diseaseenrichmentmat[i,3] <- genecountandlist[[2]] #for list
  diseaseenrichmentmat[i,4] <- as.numeric(inputgenecountandlist[[1]]) # for count
  diseaseenrichmentmat[i,5] <- inputgenecountandlist[[2]] #for list
  # Just to check for progress:
  if(i%%100==0){
    cat('Done with ',i,' diseases \n')
  }
}

cat('Done with SQL queries. \n')
#-------------- Disease Enrichment --------------------------

# Get the numbers of genes from the table
totaluniquegenescount <- dbGetQuery(conn,gettotaluniquegenescount)
totalinputgenescount <- dbGetQuery(conn,gettotalinputgenescount)

# N <- Total genes in the custom database
totalgenes <- as.numeric(totaluniquegenescount[[1]])
# n <- Total genes from input list present in the custom database
totalinputgenes <- as.numeric(totalinputgenescount[[1]])

# sorting the diseaseenrichmentmat to include diseases that contain atleast 1 gene from the input list and storing into dat file
dat <- diseaseenrichmentmat[ diseaseenrichmentmat[,4]>=1,]

#sixth column is p-value calculated using fisher test
dat <- cbind(dat,0)
#Seventh column is for adjusted p-values adjusted using BH method
dat <- cbind(dat,0)

# Doing Fisher test
for(i in 1:nrow(dat)){
  diseasetotalgenes <- as.numeric(dat[i,2]) # total genes in a disease
  diseasetotalinputgenes <- as.numeric(dat[i,4]) # genes in a disease belonging to input set
  contingency_table <- data.frame(gene.not.in.interest = c(diseasetotalgenes-diseasetotalinputgenes,totalgenes- diseasetotalgenes-totalinputgenes+diseasetotalinputgenes), gene.in.interest = c(diseasetotalinputgenes,totalinputgenes- diseasetotalinputgenes))
  row.names(contingency_table) <- c("Genes_in_disease","Genes_not_in_disease")
  dat[i,6] <- fisher.test(contingency_table)$p.value
}

# Adjusting P values based on Benjamini-Hochberg (BH) adjustment
dat[,7] <- p.adjust(dat[,6],method="BH",n = length(dat[,6]))
Enriched_data <- dat[order(dat[,6],decreasing = FALSE),]
write.csv(Enriched_data,'Disgenet_diease_enrichment_gda03_ei05.csv')
