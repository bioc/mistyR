% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/misty.R
\docType{import}
\name{reexports}
\alias{reexports}
\alias{\%>\%}
\title{Objects exported from other packages}
\examples{
# Create a view composition of an intraview and a paraview with radius 10 then
# run MISTy for a single sample.

library(dplyr)

# get the expression data
data("synthetic")
expr <- synthetic[[1]] \%>\% select(-c(row, col, type))
# get the coordinates for each cell
pos <- synthetic[[1]] \%>\% select(row, col)

# compose
misty.views <- create_initial_view(expr) \%>\% add_paraview(pos, l = 10)

# run with default parameters
run_misty(misty.views)
}
\keyword{internal}
\description{
These objects are imported from other packages. Follow the links
below to see their documentation.

\describe{
  \item{dplyr}{\code{\link[dplyr:reexports]{\%>\%}}}
}}

