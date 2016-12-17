#
# gen_adjmat.R
#
# Created by Zhifei Yan
# Last update 2016-12-14
#

#' Generate a network edge probability matrix and a random adjacency matrix
#'
#' Generate a network edge probability matrix from a specified network model with community structure and a random adjacency matrix
#'
#' @param n the number of nodes
#' @param k the number of communities
#' @param sizes a vector of community sizes
#' @param B a matrix of community-wise edge probabilities.
#'          Ff supplied, it overrides \code{p_min}, \code{p_max}, 
#'          \code{q_min}, \code{q_max}, and \code{type} arguments.
#' @param p_min the minimum within-community edge probability
#' @param p_max the maximum within-community edge probability. 
#'              It has no effect if argument \code{type} is "plantedsbm".
#' @param q_min the minimum between-community edge probability. 
#'              It has no effect if argument \code{type} is "plantedsbm".
#' @param q_max the maximum between-community edge probability
#' @param type type of network model. It has to be "plantedsbm", "sbm", 
#'             or "assortative". It has no effect if argument \code{B} 
#'             is supplied.
#' @param self_loop a logical indicating whether to allow self loops 
#'                  in the network
#' @param perm a logical indicating whether to randomly permute the generated
#'             edge probability matrix, random adjacency matrix, membership
#'             matrix, and label
#'
#' @return A list with the following components:
#'   \item{adjmat}{a random adjacency matrix if \code{sample} is TRUE}
#'   \item{probmat}{a network edge probability matrix}
#'   \item{membermat}{the membership matrix according to node labels}
#'   \item{label}{the label vector of nodes}
#' @export
gen_adjmat <- function(n, k, sizes = NULL, B = NULL, 
                       p_min, p_max, q_min, q_max, 
                       type = c("plantedsbm", "sbm", "assortative"),
                       self_loop = FALSE, perm = FALSE) {
  # sanity check
  if (is.null(sizes)) {
    sizes <- rep(n / k, k)
  } else if (length(sizes) != k) {
    stop("Length of sizes should be equal to the number of communities k")
  }

  label <- rep(1:k, times = sizes)
  cum_sizes <- c(0, cumsum(sizes))
  membermat <- matrix(0, n, k)
  for (i in 1:k){
    membermat[(cum_sizes[i] + 1):cum_sizes[i + 1], i] <- 1
  }
  # Generate expected adjacency matrix that includes self-loops
  if (!is.null(B)){
    # sanity check
    if (!isSymmetric(B)) {
      stop("Community-wise edge probability matrix B should be symmetric")
    }
    if (nrow(B) != k) {
      stop("Number of rows/columns of B should be equal to the number of communities k")
    }
    probmat <- membermat %*% B %*% t(membermat)
  } else {
    type <- match.arg(type)
    if (type == "plantedsbm") {
      B <- q_max + (p_min - q_max) * diag(k)
      probmat <- membermat %*% B %*% t(membermat)
    } else if (type == "sbm") {
      B <- matrix(0, k, k)
      B[upper.tri(B)] <- runif(k * (k - 1) / 2, q_min, q_max)
      B <- B + t(B)
      diag(B) <- runif(k, p_min, p_max)
      probmat <- membermat %*% B %*% t(membermat)
    } else if (type == "assortative") {
      clustermat <- membermat %*% t(membermat)
      probmat <- matrix(0, n, n)
      num_diag <- sum(sizes * (sizes - 1) / 2)
      num_offdiag <- n * (n - 1) / 2 - num_diag
      probmat[clustermat & upper.tri(probmat)] <-
               runif(num_diag, p_min, p_max)
      probmat[!clustermat & upper.tri(probmat)] <-
               runif(num_offdiag, q_min, q_max)
      probmat <- probmat + t(probmat)
      diag(probmat) <- runif(n, p_min, p_max)
    }
  }
  # Adjust diagonal entries of expected adjacency matrix if self_loop is FALSE
  if (!self_loop) diag(probmat) <- 0
  # Randomly permute the probmat, label, and membermat if perm is TRUE
  if (perm) {
    perm_id <- sample(n)
    probmat <- probmat[perm_id, perm_id]
    membermat <- membermat[perm_id, ]
    label <- label[perm_id]
  }
  # Generate a random adjacency matrix based on its expectation
  half_ea <- probmat
  half_ea[lower.tri(half_ea)] <- 0
  adjmat <- matrix(rbinom(n ^ 2, 1, half_ea), n, n)
  adjmat <- adjmat + t(adjmat)
  diag(adjmat) <- diag(adjmat) / 2
  out <- list(adjmat = adjmat, probmat = probmat, 
              membermat = membermat, label = label)
  return(out)
}
