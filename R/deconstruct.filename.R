#' Deconstructs a given filename
#'
#' @details
#' Extracts a (parochially defined) set of data from a filename. Not generalisable
#'
#' @param image.filename Character vector. Filename to be deconstructed.
#'
#' @return Dataframe. Column 1 is ID, Column 2 is Datetime from filename.
#'
#' @author Jamie Rylance, \email{jamie.rylance@lstmed.ac.uk}
#'
#' @keywords internal


deconstruct.filename <- function(filename) {
    filename <- sub(".TXT", "", toupper(filename))

    fnLength <- nchar(filename)
    filename <- gsub("-", "_", filename)


    fnSplit <- strsplit(filename, "_")[[1]]
    fnElements <- length(fnSplit)

    if(fnElements>1) id <- fnSplit[2]

    if(fnElements>4) filedate <- as.POSIXct(strptime(paste0(fnSplit[3], fnSplit[4], fnSplit[5]), "%d%b%y"))

  return(data.frame(fileid = id, filedate=filedate))
}

