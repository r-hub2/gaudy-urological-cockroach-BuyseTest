### discreteRoot.R --- 
##----------------------------------------------------------------------
## Author: Brice Ozenne
## Created: nov 22 2017 (13:39) 
## Version: 
## Last-Updated: feb 13 2025 (15:02) 
##           By: Brice Ozenne
##     Update #: 317
##----------------------------------------------------------------------
## 
### Commentary: 
## 
### Change Log:
##----------------------------------------------------------------------
## 
### Code:

## * discreteRoot - Documentation
#' @title Dichotomic search for monotone function
#' @description Find the root of a monotone function on a discrete grid of value using dichotomic search
#' @noRd
#'
#' @param fn [function] objective function to minimize in absolute value.
#' @param grid [vector] possible minimizers.
#' @param increasing [logical] is the function fn increasing?
#' @param check [logical] should the program check that fn takes a different sign for the first vs. the last value of the grid?
#' @param tol [numeric] the absolute convergence tolerance.
#' @author Brice Ozenne

## * discreteRoot
discreteRoot <- function(fn, grid, increasing = TRUE, check = TRUE,
                         tol = .Machine$double.eps ^ 0.5) {

    n.grid <- length(grid)    
    value.grid <- rep(NA, n.grid)    
    iter <- 1
    ncv <- TRUE
    iSet <- 1:n.grid
    factor <- c(-1,1)[increasing+1]

    ## ** Check
    if(check){
        value.grid[1] <- fn(grid[1])
        value.grid[n.grid] <- fn(grid[n.grid])
        if(sign(value.grid[1])==value.grid[n.grid]){
            return(list(par = NA,
                        value = NA,
                        counts = 0,
                        cv = 1,
                        message = "Cannot find a solution because the function does not change sign \n"))
        }
        if(increasing && value.grid[1] > value.grid[n.grid]){
            return(list(par = NA,
                        value = NA,
                        counts = 0,
                        cv = 1,
                        message = "Cannot find a solution - argument \'increasing\' does not match the variations of the functions \n"))
        }
        if(!increasing && value.grid[1] < value.grid[n.grid]){
            return(list(par = NA,
                        value = NA,
                        counts = 0,
                        cv = 1,
                        message = "Cannot find a solution - argument \'increasing\' does not match the variations of the functions \n"))
        }
    }

    
    ## ** Expore the grid using dichotomic search
    while(iter <= n.grid && ncv && length(iSet)>0){
        iMiddle <- ceiling(length(iSet)/2)
        iIndexInSet <- iSet[iMiddle]
        if(check==FALSE || iIndexInSet %in% c(1,n.grid) == FALSE){
            ## if the current index we are looking at has not already been computed,
            ## then evaluate the objective function.
            ## this is only the case when check is TRUE and we look at the borders
            value.grid[iIndexInSet] <- fn(grid[iIndexInSet])
        }
        if(is.na(value.grid[iIndexInSet])){
            ## handle NA value by just removing the observation from the set of possibilities
            iSet <- setdiff(iSet,iMiddle)
            iter <- iter + 1
        }else if(factor*value.grid[iIndexInSet] > tol){
            ## look in subgrid corresponding to the lowest values (left part)
            iSet <- iSet[setdiff(1:iMiddle,iMiddle)]
            iter <- iter + 1
        }else if(factor*value.grid[iIndexInSet] < -tol){
            ## look in subgrid corresponding to the largest values (right part)
            iN.set <- length(iSet)
            iSet <- iSet[setdiff(iMiddle:iN.set,iMiddle)]
            iter <- iter + 1
        }else{
            ## convergence
            ncv <- FALSE
            solution <- grid[iIndexInSet]
            value <- value.grid[iIndexInSet]
        }
                
    }

    ## ** If did not find a value whose image matched tol, give the closest solution
    if(ncv){
        iIndexInSet <- which.min(abs(value.grid))

       ncv <- FALSE
       solution <- grid[iIndexInSet]
       value <- value.grid[iIndexInSet]
    }

    return(list(par = solution,
                value = value,
                index = iIndexInSet,
                ## grid = stats::setNames(value.grid,grid),
                counts = iter,
                cv = (ncv==FALSE),
                message = NULL))
}

## * boot2pvalue (documentation)
#' @title Compute the p.value from the distribution under H1
#' @description Compute the p.value associated with the estimated statistic
#' using a bootstrap sample of its distribution under H1.
#' @noRd
#' 
#' @param x [numeric vector] a vector of bootstrap estimates of the statistic.
#' @param null [numeric] value of the statistic under the null hypothesis.
#' @param estimate [numeric] the estimated statistic.
#' @param alternative [character] a character string specifying the alternative hypothesis, must be one of "two.sided" (default), "greater" or "less".
#' @param FUN.ci [function] the function used to compute the confidence interval.
#' Must take \code{x}, \code{alternative}, \code{level}, \code{sign.estimate}, and \code{type.quantile} as arguments.
#' It only returns the relevant limit (either upper or lower) of the confidence interval.
#' @param checkSign [logical] should a warning be output if the sign of the estimate differs from the sign of the mean bootstrap value?
#' @param tol [numeric] the absolute convergence tolerance.
#' @param type.quantile [interger, 1-9] quantile algorithm to be used to evaluate quantiles. Passed to the \code{stats::quantile}.
#' @param add.1 [logical] conservative correction ensuring that the p-value is strictly positive. 
#' 
#' @details
#' For test statistic close to 0, this function returns 1. \cr \cr
#' 
#' For positive test statistic, this function search the quantile alpha such that:
#'\itemize{
#' \item \code{quantile(x, probs = alpha)=0} when the argument alternative is set to \code{"greater"}.
#' \item \code{quantile(x, probs = 0.5*alpha)=0} when the argument alternative is set to \code{"two.sided"}.
#' }
#' If the argument alternative is set to \code{"less"}, it returns 1. \cr \cr
#' 
#' For negative test statistic, this function search the quantile alpha such that:
#' \itemize{
#' \item \code{quantile(x, probs = 1-alpha=0} when the argument alternative is set to \code{"less"}.
#' \item \code{quantile(x, probs = 1-0.5*alpha=0} when the argument alternative is set to \code{"two.sided"}.
#' }
#' If the argument alternative is set to \code{"greater"}, it returns 1.
#' 
#' @examples
#' set.seed(10)
#' 
#' #### no effect ####
#' x <- rnorm(1e3) 
#' boot2pvalue(x, null = 0, estimate = mean(x), alternative = "two.sided")
#' ## expected value of 1
#' boot2pvalue(x, null = 0, estimate = mean(x), alternative = "greater")
#' ## expected value of 0.5
#' boot2pvalue(x, null = 0, estimate = mean(x), alternative = "less")
#' ## expected value of 0.5
#' 
#' #### positive effect ####
#' x <- rnorm(1e3, mean = 1) 
#' boot2pvalue(x, null = 0, estimate = 1, alternative = "two.sided")
#' ## expected value of 0.32 = 2*pnorm(q = 0, mean = -1) = 2*mean(x<=0)
#' boot2pvalue(x, null = 0, estimate = 1, alternative = "greater")  
#' ## expected value of 0.16 = pnorm(q = 0, mean = 1) = mean(x<=0)
#' boot2pvalue(x, null = 0, estimate = 1, alternative = "less")
#' ## expected value of 0.84 = 1-pnorm(q = 0, mean = 1) = mean(x>=0)
#'
#' #### negative effect ####
#' x <- rnorm(1e3, mean = -1) 
#' boot2pvalue(x, null = 0, estimate = -1, alternative = "two.sided") 
#' ## expected value of 0.32 = 2*(1-pnorm(q = 0, mean = -1)) = 2*mean(x>=0)
#' boot2pvalue(x, null = 0, estimate = -1, alternative = "greater")
#' ## expected value of 0.84 = pnorm(q = 0, mean = -1) = mean(x<=0)
#' boot2pvalue(x, null = 0, estimate = -1, alternative = "less") # pnorm(q = 0, mean = -1)
#' ## expected value of 0.16 = 1-pnorm(q = 0, mean = -1) = mean(x>=0)

## * boot2pvalue (code)
boot2pvalue <- function(x, null, estimate = NULL, alternative = "two.sided",
                        FUN.ci = .quantileCI, checkSign = TRUE,
                        tol = .Machine$double.eps ^ 0.5, type.quantile = NULL, add.1 = FALSE){ 

    if(all(is.na(x))){
        stop("Incorrect argument \'x\': only contain NA values. \n")
    }
    x.boot <- stats::na.omit(x)
    n.boot <- length(x.boot)
    if(any(is.infinite(x.boot))){
        statistic.boot <- stats::median(x.boot, na.rm = TRUE) - null
    }else{
        statistic.boot <- mean(x.boot, na.rm = TRUE) - null
    }
    if(is.null(estimate)){
        statistic <- statistic.boot
    }else{
        statistic <- estimate - null
        if(checkSign && sign(statistic.boot)!=sign(statistic)){
            message("the estimate and the average bootstrap estimate are not of the same side of the null hypothesis \n")
        }
    }
    sign.statistic <- statistic>=0
    if(add.1){
        zero <- 1/(n.boot+1)
    }else{
        zero <- 0
    }

    if(abs(statistic) < tol){ ## too small test statistic
        p.value <- 1
    }else if(n.boot < 10){ ## too few bootstrap samples
        p.value <- as.numeric(NA)
    }else if(all(x.boot>null)){ ## clear p.value
        p.value <- switch(alternative,
                          "two.sided" = 0,
                          "less" = 1,
                          "greater" = zero)
    } else if(all(x.boot<null)){ ## clear p.value 
        p.value <- switch(alternative,
                          "two.sided" = zero,
                          "less" = zero,
                          "greater" = 1)
    }else{ ## need search to obtain p.value
        ## when the p.value=1-coverage increases, does the quantile increases?
        increasing <- switch(alternative,
                             "two.sided" = sign.statistic,
                             "less" = FALSE,
                             "greater" = TRUE)
        
        ## grid of confidence level
        grid <- seq(0,by=1/n.boot,length.out=n.boot+1)

        ## search for critical confidence level
        resSearch <- discreteRoot(fn = function(p.value){
            CI <- FUN.ci(x = x.boot,
                         level = p.value,
                         alternative = alternative,
                         sign.estimate = sign.statistic,
                         type.quantile = type.quantile)
            return(CI[1]-null)
        },
        grid = grid,
        increasing = increasing,
        check = FALSE)

        ## cv check
        if(is.na(resSearch$value) || length(resSearch$value)==0 || resSearch$par<0 || resSearch$par>1 || resSearch$cv == FALSE){
            warning("incorrect convergence of the algorithm finding the critical quantile \n",
                    "p-value may not be reliable \n")

        }
        
        ## ## ensures a conservative estimate by taking the first level where the confidence interval excludes 0 (i.e. the next level if the confidence interval still includes 0)
        ## if((resSearch$index+1<length(grid)) && ((resSearch$value>0 && sign.statistic==FALSE) || (resSearch$value<0 && sign.statistic==TRUE))){
        ##     p.value <- grid[resSearch$index+1]
        ## }else{
        ## p.value <- resSearch$par
        ## }
        p.value <- max(resSearch$par, zero)
    }

    if(p.value %in% c(0,1)){
        message("Estimated p-value of ",p.value," - consider increasing the number of boostrap samples \n")
    }
    return(p.value)
}

## * quantileCI
.quantileCI <- function(x, alternative, level, sign.estimate, type.quantile){
    probs <- switch(alternative,
                    "two.sided" = c(level/2,1-level/2)[2-sign.estimate], ## if positive p.value/2 otherwise 1-p.value/2
                    "less" = 1-level,
                    "greater" = level)

    if(!is.null(type.quantile)){
        bound <- stats::quantile(x, probs = probs, type = type.quantile)[1]        
    }else{
        bound <- stats::quantile(x, probs = probs)[1]
    }
    return(bound)
}


##----------------------------------------------------------------------
### discreteRoot.R ends here
