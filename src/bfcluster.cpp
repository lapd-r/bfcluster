//
// bfcluster.cpp
//
// Created by Zhifei Yan
// Last update 2016-12-14
//

#include <RcppArmadillo.h>
#include <cmath>

#include "bfadmm.h"

using namespace Rcpp;
using namespace arma;

//' Birkhoff-Fan clustering
//'
//' This function computes a solution sequence of the Birkhoff-Fan clustering. 
//' It takes a symmetric matrix \code{S} as input and returns a object 
//' containing a list of normalized clustering matrices estimated by 
//' Birkhoff-Fan clustering over a sequence of the number of clusters.
//'
//' @param S            input pairwise similarity matrix
//'                     (assumed to be symmetric)
//' @param nclust       a vector of the number of clusters
//' @param maxiter      max number of iterations for each solution
//' @param tolerance    convergence threshold 
//' @param admm_penalty penalty parameter of ADMM algorithm
//' @param verbose      level of verbosity
//'
//' @return An S3 object of class \code{bfcluster} which is a list with 
//'         the following components:
//'  \item{nclust}{a vector containing the number of clusters of each estimate}
//'  \item{clustmat}{a list containing the normalized clustering matrix 
//'                  estimates}
//'  \item{maxval}{a vector of optimal objective function values 
//'                for each value of the number of clusters}
//'  \item{niter}{a vector containing the number of ADMM iterations for each 
//'               estimate}
//' @export
// [[Rcpp::export]]
List bfcluster(NumericMatrix S, IntegerVector nclust = IntegerVector::create(),
               int maxiter = 100, double tolerance = 1e-2,
               double admm_penalty = 100, int verbose = 0) {
  // Sanity checks
  if(S.nrow() < 2) stop("Expected S to be a matrix");
  if(maxiter < 1) stop("Expected maxiter > 0");
  if(tolerance <= 0.0) stop("Expected tolerance > 0");

  int ndim = S.nrow(), nsol;
  if(nclust.size() > 0) {
    if(Rcpp::min(nclust) < 2 || Rcpp::max(nclust) > ndim) {
      stop("Expected nclust to be a vector of integers between 2 and the number of rows/columns of S");
    }
    nsol = nclust.size();
  } else {
    stop("Expected length of nclust > 0");
  }

  // Wrap the input matrix with an arma mat
  const mat _S(S.begin(), ndim, ndim, false);
  // Placeholders for solutions
  List clustmat(nsol);
  IntegerVector niter(nsol);
  NumericVector maxval(nsol);
  // ADMM variables, passing by reference to the ADMM algorithm
  // Use a worm start, the results of the previous case is the initial values of the latter case
  // z keeps track of the solution matrix
  mat z = zeros<mat>(ndim, ndim),
      y = zeros<mat>(ndim, ndim),
      u = zeros<mat>(ndim, ndim),
      v = zeros<mat>(ndim, ndim);

  // Outer loop to compute the solution path
  for(int i = 0; i < nsol; i++) {
    if(verbose > 0) Rcout << ".";
    // ADMM
    niter[i] = bfadmm(_S, z, y, u, v, ndim, nclust[i], admm_penalty, maxiter, tolerance);
    // Store solution
    clustmat[i] = z;
    maxval[i] = dot(_S, z);
    if(verbose > 1) Rcout << niter[i];
  }

  if(verbose > 0) Rcout << std::endl;
  // Return
  List out = List::create(
    Named("nclust") = nclust,
    Named("clustmat") = clustmat,
    Named("maxval") = maxval,
    Named("niter") = niter
  );
  out.attr("class") = "bfcluster";
  return out;
}
