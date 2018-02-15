library(easyLogReader)


# Set up logging of info / warning / errrors

x <- read.easyLogBatch("data", "output", "output/images", noimage=FALSE)
write.csv(x, "output/AnalysedResults.csv", row.names = TRUE)

