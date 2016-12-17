#
# permute.R
#
# Created by Zhifei Yan
# Last update 2016-12-14
#

#' Permute a clustering matrix estimate
#' 
#' \code{permute} is a generic function for permuting an estimated clustering matrix according to label estimates computed from it
#' 
#' @param object object
#' @param ...    other arguments
#' @export
permute <- function(object, ...) UseMethod("permute")

#' Permute a normalized clustering matrix estimate
#' 
#' Produces a permuted normalized clustering matrix according to label estimates computed from it
#' 
#' @param object bfcluster object
#' @param k      number of clusters
#' @param ...    optional arguments to \code{getlab} method
#' 
#' @return A list with the following arguments:
#'   \item{perm_mat}{permuted normalized clustering matrix estimate}
#'   \item{perm_label}{a vector of permuted label estimates}
#'   \item{perm_id}{a vector of indices based on which to permute the 
#'                  normalized clustering matrix and the label vector}
#' @export
permute.bfcluster <- function(object, k, ...) {
  solmat <- clustering(object, k)
  label <- getlab(object, k, ...)
  sort_cls <- as.numeric(names(sort(table(label))))
  perm_id <- NULL
  for (i in sort_cls) {
    perm_id <- c(perm_id, which(label == i))
  }
  perm_mat <- solmat[perm_id, perm_id]
  perm_label <- label[perm_id]
  list(perm_mat = perm_mat, perm_label = perm_label, perm_id = perm_id)
}
