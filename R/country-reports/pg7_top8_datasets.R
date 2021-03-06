# page 7, top 8 datasets contributing about country
library(dplyr)
library(jsonlite)

apiUrl <- "http://api.gbif.org/v1/"

# ask the given apiUrl (e.g. "http://api.gbif.org/v1/") for the names of top 8 datasets about country
generatePg7Top8Datasets <- function(apiUrl) {
  top8 <- read.csv("hadoop/cr_pg7_top8_datasets.csv", na.strings="", encoding="UTF-8", header = FALSE)
  colnames(top8) <- c("CountryCode", "dataset_key", "count", "rank")
  top8$count <- prettyNum(top8$count, big.mark = ",", preserve.width = "individual")
  # top8$title <- sapply(top8$dataset_key, getDatasetName)
  # top8$modified <- sapply(top8$dataset_key, getDatasetModified)
  details <- as.data.frame(t(sapply(top8$dataset_key, getDatasetDetails)))
  colnames(details) <- c("title", "modified")
  top8 <- cbind(top8, details)
  # now drop the key column
  top8 <- top8[,-2]

  # clean tabs and linefeeds
  badWhitespace <- "[\n\t]"
  top8$title <- gsub(badWhitespace, "", top8$title)
  # formatting data to look right for InDesign when not enough rows
  top8$title <- paste(top8$title, ".", sep="")
  top8$count <- paste(top8$count, " occurrences in ", sep="")
  top8$modified <- paste("(last updated ", paste(top8$modified, ").", sep=""))

  flat_top8 <- NULL
  for (i in 1:8) {
    singleRank <- top8[top8$rank == i,]
    # rename columns
    header <- c("CountryCode", 
                paste(paste("pg7dataset", i, sep=""), "_count", sep=""),
                paste(paste("pg7dataset", i, sep=""), "_rank", sep=""),
                paste(paste("pg7dataset", i, sep=""), "_title", sep=""),
                paste(paste("pg7dataset", i, sep=""), "_modified", sep=""))
    colnames(singleRank) <- header
    if (is.null(flat_top8)) {
      flat_top8 <- singleRank
    } else {
      flat_top8 <- merge(flat_top8, singleRank, all = TRUE)
    }
  } 
  # remove no country row
  flat_top8 <- flat_top8[!is.na(flat_top8$CountryCode), ]
  # all NA to empty string
  flat_top8[is.na(flat_top8)] <- ""
  
  return(flat_top8)
}

# return 2 element char array with dataset title and last modified date (as yyyy-mm-dd)
getDatasetDetails <- function(datasetKey) {
  datasetPath <- paste(apiUrl, paste("dataset/", datasetKey, sep=""), sep="")
  dataset = tryCatch({
    fromJSON(datasetPath)
  }, warning = function(w) {
    NULL
  }, error = function(e) {
    NULL
  }, finally = {
    NULL
  })
  
  result <- ""
  if (!is.null(dataset)) {
    result <- c(dataset$title, strsplit(dataset$modified, split="T", fixed=TRUE)[[1]][1])
  }
  
  return(result)
}