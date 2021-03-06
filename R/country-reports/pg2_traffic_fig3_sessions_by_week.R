# Figure 3 - web traffic: sessions per week from country, for the last year
library(ggplot2)
library(plyr)
library(RGoogleAnalytics)
source("R/graph/utils.R")
source("R/graph/plot_utils.R")

generateTrafficWeeklyPlots <- function(start_date, end_date) {
  # real secrets, not for commit!
  load("R/country-reports/token_file")
  ValidateToken(token)
  
  reportsDir <- "report/country"
  plotsDir <- "country_reports"
  plotName <- "web_traffic_sessions_by_week"
  
  query.list <- Init(start.date = start_date,
                     end.date = end_date,                   
                     dimensions = "ga:countryIsoCode, ga:yearWeek, ga:yearMonth",
                     metrics = "ga:sessions",
                     max.results = 10000,
                     table.id = "ga:73962076")
  ga.query <- QueryBuilder(query.list)
  ga.data <- GetReportData(ga.query, token, paginate_query = T)
  colnames(ga.data) <- c("CountryCode", "yearWeek", "yearMonth", "sessions")

  #For every country; create a data frame and a plot based on that, then save .pdf
  countries <- unique(ga.data$CountryCode)
  for (country in countries) {
    # TODO: FIX THIS! - see http://dev.gbif.org/issues/browse/POR-2826
    if (!country %in% c("NA", "XK", "ZZ")) {
      byWeek <- ga.data[ga.data[,1]==country, ]
      generateWeeklyTrafficPlot(byWeek, paste(paste(reportsDir, country, sep="/"), plotsDir, sep="/"), plotName)  
    }
  }
}