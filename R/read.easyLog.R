#' Import and process data from a single EasyLog file
#'
#' @details
#' To extract data from an EasyLog file and perform summary calculations
#'
#' @param filename Character vector. Filename of the EasyLog CSV file to process.
#' @param imagedir Optional. Character vector. Only used if noimage=FALSE. Directory into which image files will be output (default=current working directory)
#' @param noimage Logical. If TRUE, no images are produced (default=TRUE).
#'
#' @return Dataframe of test results
#'
#' @author Jamie Rylance, \email{jamie.rylance@lstmed.ac.uk}
#'
#' @examples
#' read.easyLog("example/data/example.txt", noimage=TRUE)
#'
#' read.easyLog("/example/data/example.txt", imagedir="/example/images", noimage=FALSE)
#'
#' @export
#'
#' @import ggplot2
#' @import grid
#' @import scales
#' @import stringr
#' @import dplyr


read.easyLog <- function(filename, imagedir = ".", noimage = TRUE)
{

    raw.data <-
      read.csv(
        filename,
        header = TRUE,
        sep = ",",
        stringsAsFactors = F
      )

    raw.id <- as.character(names(raw.data[1]))
    if (is.na(raw.id)) {
      warning(paste0("ID not included in raw data for: ", filename))
    }
    names(raw.data[1]) <- 'timepoint'

     raw.serial <- as.character(raw.data$Serial.Number[1])
    if (is.na(raw.serial)) {
      warning(paste0("Serial number not included in raw data for: ", filename))
    }

    raw.sensorExpiry <- strptime(raw.data$Sensor.Life.Expiry[1], format = "%d/%m/%Y")
    if (is.na(raw.sensorExpiry)) {
      warning(paste0("Sensor life expiry not included in raw data for: ", filename))
      raw.sensorExpiry <- ""
    }

    raw.overRangeExposure <- as.character(raw.data$Overrange.Exposure[1])
    if (is.na(raw.overRangeExposure)) {
      warning(paste0("Overrange Exposure not given for: ",filename))
    }

    # Remove the headers and one-off information
    raw.data <- raw.data[2:nrow(raw.data),1:4]


    # Name the columns
    names(raw.data)[2] <- 'time'
    raw.data$time <- strptime(raw.data$time, "%Y-%m-%d %H:%M:%S")
    names(raw.data)[3] <- 'co'
    raw.data$co <- as.numeric(raw.data$co)
    names(raw.data)[4] <- 'warning'
    raw.data$warning <- as.numeric(raw.data$warning)

    time.start <- raw.data$time[1]
    time.end <- raw.data$time[nrow(raw.data)]
    time.recorded <- as.numeric(difftime(time.end, time.start, units="hours"))

    if (!noimage) {
      image.df <- data.frame(x = as.list(raw.data$time), y =  raw.data$co)
      image.filename <- paste0(raw.id,"_",strptime(raw.data$time[1], "%Y/%m/%d %H%M%S"))
      res <- imageout(image.df, paste0(imagedir,"/",image.filename))
      if(res) warning(paste0("No image file saved for: ", filename))

      }
    filename.df <- deconstruct.filename(filename)

    return.df <- data.frame(id = as.character(raw.id),
                            serial = raw.serial,
                            sensorExpiry = raw.sensorExpiry,
                            overRange = raw.overRangeExposure,
                            time.start = time.start,
                            time.end = time.end,
                            time.recorded = time.recorded,
                            mean.co = mean(raw.data$co),
                            max.co = max(raw.data$co),
                            over.warning.prop = (sum(raw.data$co>50)/nrow(raw.data)))


    return(cbind(filename.df,return.df))
  }

