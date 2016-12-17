#
# plot.R
#
# Created by Zhifei Yan
# Last update 2016-12-14
#

#' Plot bfcluster object
#' 
#' Plot an estimated normalized clustering matrix for a specified number of clusters
#' 
#' @param object      bfcluster object
#' @param k           the number of clusters. If not provided, 
#'                    it is set to be the first value of 
#'                    the number of clusters in the object
#' @param prob_thres  the probability at which to threshold the large entries
#'                    of the clustering matrix for better visualization
#' @param perm        a logical indicating whether to permute the 
#'                    estimated normalized clustering matrix 
#'                    according to label estimates 
#'                    computed from it before plotting
#' @param ...         further arguments passed to \code{permute} method
#' @export
plot.bfcluster <- function(object, k = NULL, prob_thres = NULL, 
                           perm = FALSE, ...) {
  if (is.null(k)) k <- object$nclust[1]
  if (perm) plot_obj <- permute(object, k, ...)$perm_mat
  else plot_obj <- clustering(object, k)

  if (!is.null(prob_thres)) {
    thres <- quantile(plot_obj, prob_thres)
    plot_obj[plot_obj > thres] <- thres
  }

  df <- melt(plot_obj, varnames = c("row.index", "column.index"), 
             value.name = "value")

  p <- ggplot(df, aes(x = column.index, y = row.index))
  p <- p + geom_raster(aes(fill = value)) + 
       scale_fill_gradient2(low = "red", mid = "white", 
                            high = "blue", midpoint = 0) + 
       scale_y_reverse() + 
       coord_fixed()
  if (perm) p <- p + ggtitle(paste("Permuted SDP solution matrix when the number of clusters is ", k, sep = ''))
  else p <- p + ggtitle(paste("SDP solution matrix when the number of clusters is ", k, sep = ''))
  p
}

#' Plot matrix object
#' 
#' This function plots a matrix
#' 
#' @param S    matrix object
#' @param ...  other arguments passed to or from other methods 
#' @export
plot.matrix <- function(S, ...) {
  df <- melt(S, varnames = c("row.index", "column.index"), 
             value.name = "value")

  p <- ggplot(df, aes(x = column.index, y = row.index))
  p <- p + geom_raster(aes(fill = value)) + 
       scale_fill_gradient2(low = "red", mid = "white", 
                            high = "blue", midpoint = 0) + 
       scale_y_reverse() + 
       coord_fixed()
  p
}