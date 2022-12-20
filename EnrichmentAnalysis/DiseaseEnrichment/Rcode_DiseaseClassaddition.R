# To add the disease classes for the diseases from disgenet database

#load the necessary packages
library(RSQLite)
library(readxl)
library(writexl)

# connect to the database
conn <- dbConnect(RSQLite::SQLite(),'disgenet_2020.db')

#import the dataset to add the disease classes:
Disgenet_p0_01 <- read_excel("Bubble_plot/Disgenet_p0_01.xlsx")

# add a column to add the class code. (9th column of the current data)
Disgenet_p0_01 <- cbind(Disgenet_p0_01,0)
names(Disgenet_p0_01)[9] <- paste('DiseaseClassCodes')

# add a column to add the class name. (10th column of the current data)
Disgenet_p0_01 <- cbind(Disgenet_p0_01,0)
names(Disgenet_p0_01)[10] <- paste('DiseaseClassNames')

# add a column to add the disease code (11th column of the current table)
Disgenet_p0_01 <- cbind(Disgenet_p0_01,0)
names(Disgenet_p0_01)[11] <- paste('DiseaseCode')

# SQL codes

## Chhanged the column name in diseaseClass from diseaseClass to diseaseClassCode
# dbExecute(conn,"ALTER TABLE diseaseClass RENAME COLUMN diseaseClass TO diseaseClassCode")

#1. Get the diseaseNID from disease name from the imput dataset
getdiseaseNIDandIDfrominput <- sprintf("SELECT diseaseNID, diseaseID from diseaseAttributes WHERE diseaseName in (\"%s\")",diseasename) 

#2. To access the disease class code and class name from diseaseNID from above
getdiseaseclasscodeandname <- sprintf("SELECT GROUP_CONCAT(diseaseClass.diseaseClassName, '|'), GROUP_CONCAT(diseaseClass.diseaseClassCode,'|') from disease2class INNER JOIN diseaseClass ON diseaseClass.diseaseClassNID = disease2class.diseaseClassNID WHERE disease2class.diseaseNID = %s",diseasenid)

for(i in 1:nrow(Disgenet_p0_01)){
  diseasename <- as.character(Disgenet_p0_01[i,1])
  getdiseaseNIDandIDfrominput <- sprintf("SELECT diseaseNID, diseaseID from diseaseAttributes WHERE diseaseName in (\"%s\")",diseasename)
  diseaseNIDandIDfrominput <- dbGetQuery(conn,getdiseaseNIDandIDfrominput)
  diseasenid <- as.character(diseaseNIDandIDfrominput[[1]])
  diseaseCode <- as.character(diseaseNIDandIDfrominput[[2]])
  getdiseaseclasscodeandname <- sprintf("SELECT GROUP_CONCAT(diseaseClass.diseaseClassName, '|'), GROUP_CONCAT(diseaseClass.diseaseClassCode,'|') from disease2class INNER JOIN diseaseClass ON diseaseClass.diseaseClassNID = disease2class.diseaseClassNID WHERE disease2class.diseaseNID = %s",diseasenid)
  diseaseclasscodeandname <- dbGetQuery(conn,getdiseaseclasscodeandname)
  diseaseclassname <- as.character(diseaseclasscodeandname[[1]])
  diseaseclasscode <- as.character(diseaseclasscodeandname[[2]])
  Disgenet_p0_01[i,9] <- diseaseclasscode
  Disgenet_p0_01[i,10] <- diseaseclassname
  Disgenet_p0_01[i,11] <- diseaseCode
}

write_xlsx(Disgenet_p0_01,"DisGeNET_diseaseenrichment_p0_01.xlsx")
