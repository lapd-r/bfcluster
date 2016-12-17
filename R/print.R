# 
# print.R
# 
# Created by Zhifei Yan
# Last update 2016-12-14
#

#' Print bfcluster object
#' 
#' This function prints
#' 
#' @param object bfcluster object
#' @export
print.bfcluster <- function(object, ...) {
  print(cbind(
    nclust = object$nclust, 
    maxval = object$maxval, 
    niter = object$niter))
  invisible(object)
}
