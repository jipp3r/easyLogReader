#' Import and process data from a single EasyLog file
#'
#' @details
#' To extract data from an EasyLog file and perform summary calculations
#'
#' @param filename Character vector. Filename of the EasyLog CSV file to process.
#' @param imagedir Optional. Character vector. Only used if noimage=FALSE. Directory into which image files will be output (default=current working directory)
#' @param noimage Optional. Logical. If TRUE, no images are produced (default=TRUE).
#' @param leadtime Optional. Double. Hours into recording before which data is ignored (default=0 i.e. no lead-time).
#' @param truncate Optional. Double. Hours into recording after which data is ignored (default=NA i.e. no truncation). NB: recording is truncated after any leadtime is employed.
#'NA
#' @return Dataframe of test results
#'
#' @author Jamie Rylance, \email{jamie.rylance@lstmed.ac.uk}
#'
#' @examples
#' read.easyLog("example/data/example.txt", noimage=TRUE)
#'
#' read.easyLog("example/data/example.txt", imagedir="example/images", noimage=FALSE)
#'
#' read.easyLog("example/data/example.txt", imagedir="example/images", leadtime=1, truncate=24)
#'
#' @export
#'
#' @import ggplot2
#' @import grid
#' @import scales
#' @import stringr
#' @import dplyr
#' @import flux


read.easyLog <-
  function(filename,
           imagedir = ".",
           noimage = TRUE,
           truncate = NA,
           leadtime = 0)


  {
    return.df <- data.frame(
      filename = character(),
      id = character(),
      serial = character(),
      sensorExpiry = character(),
      overRange = character(),
      start = character(),
      end = character(),
      recorded = double(),
      truncate = double(),
      leadtime = double(),
      analysed = double(),
      co.mean = double(),
      co.max = double(),
      co.overprop = double(),
      co.sd = double(),
      co.median = double(),
      co.q5 = double(),
      co.q95 = double(),
      co.auc = double(),
      stringsAsFactors = FALSE
    )

    return.df[1, ] <- NA  # Empty row in dataframe
    return.df[1, "filename"] <- filename
    return.df[1, "truncate"] <- truncate
    return.df[1, "leadtime"] <- leadtime

    raw.data <-
      read.csv(
        filename,
        header = TRUE,
        sep = ",",
        stringsAsFactors = FALSE
      )

    return.df[1, "id"] <- as.character(names(raw.data[1]))
    if (is.na(return.df[1, "id"])) {
      warning(paste0("ID not included in raw data for: ", filename))
    }
    names(raw.data[1]) <- 'timepoint'

    return.df[1, "serial"] <-
      as.character(raw.data$Serial.Number[1])
    if (is.na(return.df[1, "serial"])) {
      warning(paste0("Serial number not included in raw data for: ", filename))
    }

    return.df[1, "sensorExpiry"] <- as.character(strptime(raw.data$Sensor.Life.Expiry[1], format = "%d/%m/%Y"))
    if (is.na(return.df[1, "sensorExpiry"])) {
      warning(paste0("Sensor life expiry not included in raw data for: ", filename))
    }

    return.df[1, "overRange"] <-
      as.character(raw.data$Overrange.Exposure[1])
    if (is.na(return.df[1, "overRange"])) {
      warning(paste0("Overrange Exposure not given for: ", filename))
    }

    # Remove the headers and one-off information
    raw.data <- raw.data[2:nrow(raw.data), 1:4]


    # Only do analysis if any data, otherwise return NA values

    if (nrow(raw.data) > 0) {
      # Name the columns
      names(raw.data)[2] <- 'time'
      names(raw.data)[3] <- 'co'
      names(raw.data)[4] <- 'warning'

      raw.data$time <- strptime(raw.data$time, "%Y-%m-%d %H:%M:%S")
      raw.data$co <- as.numeric(raw.data$co)
      raw.data$warning <- as.numeric(raw.data$warning)

      raw.data$hour <-
        as.numeric(difftime(raw.data$time, raw.data$time[1], units = "hours")) - leadtime

      return.df[1, "start"] <- as.character(raw.data$time[1])
      return.df[1, "end"] <-
        as.character(raw.data$time[nrow(raw.data)])
      return.df[1, "recorded"] <-
        as.numeric(difftime(raw.data$time[nrow(raw.data)], raw.data$time[1], units =
                              "hours"))






      # remove truncated data
      if (!is.na(truncate)) {
        if (raw.data$hour[nrow(raw.data)] < truncate)
          warning(paste0("Data ends before truncation period for: ", return.df[1, "filename"]))
        raw.data <- raw.data[raw.data$hour < truncate,]

      }

      # remove offset data
      raw.data <- raw.data[raw.data$hour >= 0, ]


      # Only continue with analysis if any data remaining

      if (nrow(raw.data) > 0) {
        # Write images out if requested
        # For future development: Add truncation bars to grey out non-analysed period

        if (!noimage) {
          image.df <- data.frame(x = as.list(raw.data$time), y =  raw.data$co)
          image.filename <-
            paste0(return.df[1, "id"],
                   "_",
                  substr(return.df[1, "start"],1,10))
          res <-
            imageout(image.df, paste0(imagedir, "/", image.filename))


          if (res)
            warning(paste0("No image file saved for: ", filename))

        }


        return.df[1, "analysed"] <- raw.data$hour[nrow(raw.data)]
        return.df[1, "co.mean"] <- mean(raw.data$co, na.rm = TRUE)
        return.df[1, "co.max"] <- max(raw.data$co, na.rm = TRUE)
        return.df[1, "co.overprop"] <-
          sum(raw.data$co > 50, na.rm = TRUE) /
          nrow(raw.data)
        return.df[1, "co.sd"] <- sd(raw.data$co, na.rm = TRUE)
        return.df[1, "co.median"] <- median(raw.data$co, na.rm = TRUE)
        return.df[1, "co.q5"] <-
          quantile(raw.data$co, c(0.05), na.rm = TRUE)
        return.df[1, "co.q95"] <-
          quantile(raw.data$co, c(0.95), na.rm = TRUE)
        return.df[1, "co.auc"] <-
          sum(raw.data$co, na.rm = TRUE) / return.df[1, "recorded"]
      }
      else {
        warning(paste0(
          "Applying truncation parameters resulted in no data for: ",
          filename
        ))
      }
    }
    else {
      warning(paste0("File contains no data: ", filename))
    }



    return(return.df)
  }
