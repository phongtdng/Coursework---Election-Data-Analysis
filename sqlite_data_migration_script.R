library(tidyverse)
library(dbplyr)
library(RSQLite)
library(DBI)

#Original Data
election_data <- read_csv(file = "./data/datos_elecciones_brutos.csv")
cod_mun <- read_csv(file = "./data/cod_mun.csv")
surveys <- read_csv(file = "./data/historical_surveys.csv")
abbrev <- read_csv(file = "./data/siglas.csv")

#Pivoted election_data table name: election_data
election_df <- election_data %>% 
  pivot_longer(cols = !tipo_eleccion:votos_candidaturas, names_to = 'party', values_to = 'vote_count') %>% 
  mutate(vote_count = replace_na(vote_count, 0),
         cod_mun = paste(codigo_ccaa, codigo_provincia, codigo_municipio, sep = "-"), .after = codigo_municipio)

#Pivoted surveys table name: surveys
surveys_df <- surveys %>% 
  pivot_longer(cols = !type_survey:turnout, names_to = 'siglas', values_to = 'estimated_voting_intention') %>% 
  mutate(date_elec = as.character(date_elec),
         field_date_from = as.character(field_date_from),
         field_date_to = as.character(field_date_to)) 

#Migrate data to sqlite database
db_file <- "database.sqlite"
db <- src_sqlite(db_file, create = TRUE) #Create database

dbWriteTable(db, "election_data", election_df)
dbWriteTable(db, "cod_mun", cod_mun)
dbWriteTable(db, "surveys", surveys_df, field.types = c(date_elec = "Date", field_date_from ="Date", field_date_to = "Date"))
dbWriteTable(db, "abbrev", abbrev)

