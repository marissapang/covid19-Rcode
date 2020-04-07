#!/usr/local/bin/Rscript
#setwd("~/Documents/GitHub/covid19-Rcode/")

library(data.table)
library(dplyr)
library(tidyr)


# read in data
intl_confirmed = fread("data/time_series_covid19_confirmed_global.csv", stringsAsFactors = F)
intl_confirmed = intl_confirmed %>% select(-Lat, -Long)
intl_confirmed = gather(intl_confirmed, Date, Num_Confirmed, 3:ncol(intl_confirmed), factor_key=TRUE)
colnames(intl_confirmed) = c("State", "Country", "Date", "Num_Confirmed")

us_confirmed = fread("data/time_series_covid19_confirmed_US.csv", stringsAsFactors = F)
us_confirmed = us_confirmed %>% select(-UID, -iso2, -iso3, -code3, -FIPS, -Admin2, -Combined_Key, -Lat, -Long_)
us_confirmed = gather(us_confirmed, Date, Num_Confirmed, 3:ncol(us_confirmed), factor_key=TRUE)
colnames(us_confirmed) = c("State", "Country", "Date", "Num_Confirmed")
us_confirmed = us_confirmed %>% group_by(State, Country, Date) %>% summarise(Num_Confirmed = sum(Num_Confirmed)) %>% ungroup()


# combine data and clean a little
confirmed = rbind(intl_confirmed %>% filter(Country != "US"), us_confirmed)
confirmed = confirmed %>% mutate(Date = as.Date(Date, format = "%m/%d/%y"))

# remap hong kong and rename US
confirmed = confirmed %>%
  mutate(Country = ifelse(State == "Hong Kong", "Hong Kong", Country),
         Country = ifelse(Country == "US", "United States", Country))

fwrite(confirmed, '../covid19-Django/trends/data/confirmed_cases.csv')
