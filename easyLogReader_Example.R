library(easyLogReader)

# Set up logging of info / warning / errrors

x <- read.easyLogBatch("example/data", "example/output", "example/output/images", noimage=FALSE)

write.csv(x, "example/output/AnalysedResults.csv", row.names = TRUE)

