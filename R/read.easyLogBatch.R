#' Import and process data from multiple EasyLog files
#'
#' @details
#' To extract data from multiple EasyLog files and perform summary calculations
#'
#' @param filedir Character vector. Directory containing EasyLog CSV files to process.
#' @param outputdir Optional. Character vector. Directory into which data will be output (default=current working directory).
#' @param imagedir Optional. Character vector. Only used if noimage=FALSE. Directory into which image files will be output (default=current working directory).
#' @param noimage Logical. If TRUE, no images are produced (default=TRUE).
#'
#' @return Dataframe of test results
#'
#' @author Jamie Rylance, \email{jamie.rylance@lstmed.ac.uk}
#'
#' @examples
#' read.easyLogBatch("/example/data", "/example/output", "/example/output/images", noimage=FALSE)
#'
#' read.easyLogBatch("/example/data", "/example/output", noimage=TRUE)
#'
#' @export
#'
#' @import ggplot2
#' @import grid
#' @import scales
#' @import stringr
#' @import dplyr


read.easyLogBatch <- function(filedir, outputdir = ".", imagedir = ".", noimage = TRUE) {

  if (!noimage) {
    if (is.null(imagedir)) {
      warning("No image directory specified - using current directory")
      imagedir <- "."
    }
    else {
      if (!dir.exists(imagedir)) {
        warning(paste0("Image directory does not exist - creating: ",imagedir))
        dir.create(imagedir)
      }
    }
  }

  if (is.null(outputdir)) {
    warning("No output directory specified - using current directory")
    outputdir <- "."
  }
  else {
    if (!dir.exists(outputdir)) {
      warning(paste0("Output directory does not exist - creating: ",outputdir))
      dir.create(outputdir)
    }
  }


  results.df <- as.data.frame(NULL)

  for (filename in list.files(filedir, full.names=TRUE)) {
    analysis.tmp <- read.easyLog(filename, imagedir =imagedir, noimage = noimage)


    if (is.null(analysis.tmp)) {
      warning(paste0("No results available for: ", filename))
    }
    else {
      results.df <- rbind(results.df, analysis.tmp)
    }
  }

  return(results.df)
}
