setwd("~/Documents/GitHub/covid19-Rcode/")
library(data.table)
library(dplyr)
library(tidyr)

confirmed = fread('../covid19-Django/trends/data/confirmed_cases.csv', stringsAsFactors = F)
deaths = fread('../covid19-Django/trends/data/num_deaths.csv', stringsAsFactors = F)

confirmed = confirmed %>% 
  filter(Date == max(confirmed$Date)) %>%
  group_by(Country) %>% 
  summarise(Num_Confirmed = sum(Num_Confirmed, na.rm=T)) %>% ungroup()

deaths = deaths %>% 
  filter(Date == max(deaths$Date)) %>%
  group_by(Country) %>% 
  summarise(Num_Deaths= sum(Num_Deaths, na.rm=T)) %>% ungroup()

gdp_pc = fread("data/GDP_per_capita.csv", stringsAsFactors = F)
country_abbrevs = fread("data/country_abbrevs.csv", stringsAsFactors = F)
joined_data = confirmed %>% 
  left_join(deaths, by="Country") %>%
  left_join(gdp_pc, by="Country") %>%
  left_join(country_abbrevs, by="Country") %>%
  # filter(Num_Confirmed > 5000) %>%
  filter(Num_Confirmed > 10000) %>%
  mutate(Death_Rate = round(Num_Deaths/Num_Confirmed,3)*100) %>%
  arrange(desc(Death_Rate)) # %>%
  # mutate(Country_Abbr = ifelse(Num_Confirmed > 20000, Country_Abbr, ' '))

# plot(joined_data$GDP_Per_Capita, joined_data$Dath_Rate)
fwrite(joined_data, '../covid19-Django/trends/data/death_rate.csv')


