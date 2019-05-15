#' Produce graphic output of EasyLog data
#'
#' @details
#' Produces a scatter plot of EasyLog data, and saves as a PDF.
#'
#' @param df Dataframe. Columns labelled 'x' which contains POSIT time data and 'y' which contains carbon monoxide data (in ppm)
#' @param image.filename Character vector. Filename for the output.
#'
#' @return Logical. TRUE if image successfully saved, FALSE if not.
#'
#' @author Jamie Rylance, \email{jamie.rylance@lstmed.ac.uk}
#'
#' @examples
#'
#' @import ggplot2
#' @import grid
#' @import scales
#' @import stringr
#' @import dplyr
#'
#' @keywords internal


imageout <- function(df, image.filename) {

  # PLOT IMAGES
  # standardise new (derived) theme
  theme_new <- theme_set(theme_bw())

  theme_new <- theme_update(
    aspect.ratio = .4,
    axis.text.x = element_text(size = 7),
    axis.title.x = element_text(size = 7),
    axis.text.y = element_text(size = 7),
    axis.title.y = element_text(size = 7),
    plot.title = element_text(
      size = 8,
      face = "bold",
      color = "black"
    ),
    panel.grid.minor = element_line(color = "grey90", size = .1),
    panel.grid.major = element_line(color = "grey80", size = .2)
  )

  # plot carbon monoxide data

  text_co <- paste(
    "mean (5-95%) = ",
    round(mean(df$y), digits = 1),
    " (",
    round(quantile(df$y, 0.025), digits = 1),
    "-",
    round(quantile(df$y, 0.975), digits = 1),
    ")",
    sep = ""
  )

  grob <- grobTree(textGrob(
    text_co,
    x = 0.95,
    y = 0.90,
    hjust = 1,
    gp = gpar(
      col = "black",
      fontsize = 6,
      fontface = "italic"
    )
  ))

  g <-
    ggplot(df, aes(x = x, y = y)) +
    geom_point(size = 0.1,
               alpha = 0.75,
               color = "red") +
    annotation_custom(grob) +
    stat_smooth(
      method = "loess",
      size = 0.25,
      se = FALSE,
      span = 0.1
    ) +
    ylab("CO (ppm)") +
    xlab("Time")
  # + scale_x_continuous(breaks = seq(0, time.recorded, 6))


  res <- try(ggsave(paste0(image.filename,".pdf"), g), silent=TRUE)
  return(class(res) == "try-error")
}
