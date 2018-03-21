library(easyLogReader)

# Set up logging of info / warning / errrors

# Processes each file in the 'data' folder
x <- read.easyLogBatch("data", "output", "output/images", noimage=TRUE)

# Processes each file in the 'data' folder, using only the first 24 hours of each trace
y <- read.easyLogBatch("data", "output", "output/images", noimage=TRUE, leadtime = 0, truncate = 24)

# Writes out results to CSV
write.csv(x, "example/output/AnalysedResults.csv", row.names = TRUE)

