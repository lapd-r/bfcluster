#
# count_miscls.R
#
# Created by Zhifei Yan
# Last update 2016-12-14
#

#' Count the number of misclassified objects
#' 
#' Count the number of misclassified objects comparing to provided true labels
#' 
#' @param label_est   a vector of estimated labels
#' @param label_true  a vector of true labels
#' @return The number of misclassified objects
#' @export
count_miscls <- function(label_est, label_true) {
  if (length(unique(label_est)) != length(unique(label_true))) 
    stop("The number of clusters in estimated labels is different from the number of clusters in true labels")
  k <- length(unique(label_true))
  n <- length(label_true)
  all_perm <- permutations(k, k)
  num_perm <- nrow(all_perm)
  member_mat <- matrix(0, n, k)
  miscls_all <- rep(NA, num_perm)
  for (i in 1:n) {
    member_mat[i, label_est[i]] <- 1
  }
  for (i in 1:num_perm) {
    perm <- all_perm[i, ]
    member_mat_perm <- member_mat[, perm]
    label_perm <- apply(member_mat_perm, 1, function(x) which(x == 1))
    miscls_all[i] <- sum(label_perm != label_true)
  }
  min(miscls_all)
}