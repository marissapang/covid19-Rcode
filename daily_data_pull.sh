#!/bin/bash

cd ../COVID-19
git pull origin master

cd ../covid19-Rcode

cp ../COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv data/time_series_covid19_confirmed_global.csv

cp ../COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv data/time_series_covid19_confirmed_US.csv

cp ../COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv data/time_series_covid19_deaths_global.csv

cp ../COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv data/time_series_covid19_deaths_US.csv

Rscript clean_data.R

cd ../covid19-Django

# git add trends/data/confirmed_cases.csv
# git add trends/data/num_death.csv
git add -A
git commit -m "refresh with today's data"
git push origin master
git push heroku master
