//
// bfadmm.h
//
// Created by Zhifei Yan
// Last update 2016-12-14
//

#ifndef __BFADMM_H
#define __BFADMM_H

#include <RcppArmadillo.h>

int bfadmm(const arma::mat& input, arma::mat& z, arma::mat& y, 
           arma::mat& u, arma::mat& v, const int& n, const int& k, 
           const double& admm_penalty, int maxiter, const double& tolerance);

#endif