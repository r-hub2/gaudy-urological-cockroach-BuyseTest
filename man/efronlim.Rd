% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/efronlim.R
\name{efronlim}
\alias{efronlim}
\title{Constrained Kaplan-Meier Estimator}
\usage{
efronlim(formula, data, ...)
}
\arguments{
\item{formula}{formula with on the right-hand side Hist(time,event) or Surv(time,event) and 1 or stratification variable(s) on the right-hand side.}

\item{data}{A \code{data.frame} containing the variables of present in argument \code{formula}.}

\item{...}{additional arguments passed to \code{prodlim::prodlim}}
}
\value{
A \code{prodlim} object.
}
\description{
Kaplan-Meier estimator, possibly stratified, constrained to 0 just after end of follow-up in each strata.
}
\details{
If in any strata there is censoring at the observed time, then the dataset is updated
by setting one of the censored observations to an infinitesimal later timepoint with an event instead of censoring.
Then the possibly stratified Kaplan-Meier estimator is run on this updated dataset.
}
\examples{
library(data.table)

set.seed(1)
dt.data <- simBuyseTest(1e2, n.strata = 2)
dt.data$time1 <- pmin(dt.data$eventtime, 1)
dt.data$status1 <- dt.data$status * (dt.data$eventtime<=1)

## KM
if(require(prodlim)){
   e.KM <- prodlim(Hist(time1,status1)~1, data = dt.data)
   plot(e.KM)
}

e.KM0 <- efronlim(Hist(time1,status1)~1, data = dt.data)
plot(e.KM0)

## stratfied KM
if(require(prodlim)){
   e.KMS <- prodlim(Hist(time1,status1)~strata, data = dt.data)
   plot(e.KMS)
}

e.KMS <- efronlim(Hist(time1,status1)~strata, data = dt.data)
plot(e.KMS)
}
