#!/usr/local/bin/Rscript
setwd("~/Documents/GitHub/covid19-Rcode/")

library(data.table)
library(dplyr)
library(tidyr)


# read in data
intl_confirmed = fread("data/time_series_covid19_confirmed_global.csv", stringsAsFactors = F)
intl_confirmed = intl_confirmed %>% select(-Lat, -Long)
intl_confirmed = gather(intl_confirmed, Date, Num_Confirmed, 3:ncol(intl_confirmed), factor_key=TRUE)
colnames(intl_confirmed) = c("State", "Country", "Date", "Num_Confirmed")

intl_deaths = fread("data/time_series_covid19_deaths_global.csv", stringsAsFactors = F)
intl_deaths = intl_deaths %>% select(-Lat, -Long)
intl_deaths = gather(intl_deaths, Date, Num_Deaths, 3:ncol(intl_deaths), factor_key=TRUE)
colnames(intl_deaths) = c("State", "Country", "Date", "Num_Deaths")

us_confirmed = fread("data/time_series_covid19_confirmed_US.csv", stringsAsFactors = F)
us_confirmed = us_confirmed %>% select(-UID, -iso2, -iso3, -code3, -FIPS, -Admin2, -Combined_Key, -Lat, -Long_)
us_confirmed = gather(us_confirmed, Date, Num_Confirmed, 3:ncol(us_confirmed), factor_key=TRUE)
colnames(us_confirmed) = c("State", "Country", "Date", "Num_Confirmed")
us_confirmed = us_confirmed %>% group_by(State, Country, Date) %>% summarise(Num_Confirmed = sum(Num_Confirmed)) %>% ungroup()

us_deaths = fread("data/time_series_covid19_deaths_US.csv", stringsAsFactors = F)
us_deaths = us_deaths %>% select(-UID, -iso2, -iso3, -code3, -FIPS, -Admin2, -Combined_Key, -Lat, -Long_)
us_deaths = gather(us_deaths, Date, Num_Deaths, 3:ncol(us_deaths), factor_key=TRUE)
colnames(us_deaths) = c("State", "Country", "Date", "Num_Deaths")
us_deaths = us_deaths %>% group_by(State, Country, Date) %>% summarise(Num_Deaths = sum(Num_Deaths)) %>% ungroup() %>% filter(Date != "Population")


# combine data and clean a little
confirmed = rbind(intl_confirmed %>% filter(Country != "US"), us_confirmed)
deaths = rbind(intl_deaths %>% filter(Country != "US"), us_deaths)

confirmed = confirmed %>% mutate(Date = as.Date(Date, format = "%m/%d/%y"))
deaths = deaths %>% mutate(Date = as.Date(Date, format = "%m/%d/%y"))

# remap hong kong and rename US
confirmed = confirmed %>%
  mutate(Country = ifelse(State == "Hong Kong", "Hong Kong", Country),
         Country = ifelse(Country == "Taiwan*", "Taiwan", Country),
         Country = ifelse(Country == "US", "United States", Country),
         Country = ifelse(Country == "Korea, South", "South Korea", Country))

deaths = deaths %>%
  mutate(Country = ifelse(State == "Hong Kong", "Hong Kong", Country),
         Country = ifelse(Country == "Taiwan*", "Taiwan", Country),
         Country = ifelse(Country == "US", "United States", Country),
         Country = ifelse(Country == "Korea, South", "South Korea", Country))

fwrite(confirmed, '../covid19-Django/trends/data/confirmed_cases.csv')
fwrite(deaths, '../covid19-Django/trends/data/num_deaths.csv')

