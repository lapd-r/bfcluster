#
# clustering.R
#
# Created by Zhifei Yan
# Last update 2016-12-14
#

#' Extract a clustering matrix estimate
#' 
#' \code{clustering} is a generic function for extracting an estimated clustering matrix from a clustering object
#' 
#' @param object object
#' @param ...    other arguments
#' @export
clustering <- function(object, ...) UseMethod("clustering")

#' Extract a normalized clustering matrix estimate
#' 
#' Returns an estimated normalized clustering matrix
#' 
#' @param object bfcluster object
#' @param k      number of clusters
#' @param ...    other arguments
#' @export
clustering.bfcluster <- function(object, k, ...) {
  if (k %in% object$nclust) {
    id <- match(k, object$nclust)
    return(object$clustmat[[id]])
  } else {
    stop('Clustering matrix is not computed using the specified k')
  }
}

#' Compute label estimates
#' 
#' \code{getlab} is a generic function for extracting label estimates from a clustering object
#' 
#' @param object object
#' @param ...    other arguments
#' @export
getlab <- function(object, ...) UseMethod("getlab")

#' Compute label estimates
#' 
#' Produces label estimates using k-means algorithm based on an estimated normalized clustering matrix
#' 
#' @param object      bfcluster object
#' @param k           number of clusters
#' @param normalize   a logical indicating whether to normalize the 
#'                    rows of clustering matrix to have unit norms
#' @param iter_max    the maximum number of iterations allowed for k-means
#'                    algorithm
#' @param rep         number of k-means replicates
#' @param ...         other arguments
#' @export
getlab.bfcluster <- function(object, k, normalize = TRUE, iter_max = 1e3,
                             rep = 1e2, ...) {
  solmat <- clustering(object, k)
  if (normalize) {
    solmat <- t(apply(solmat, 1, function(x) x / sqrt(sum(x ^ 2))))
  }
  kmeans(solmat, k, iter.max = iter_max, nstart = rep)$cluster
}
