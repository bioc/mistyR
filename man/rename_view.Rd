% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/view-manipulators.R
\name{rename_view}
\alias{rename_view}
\title{Rename view in a view composition}
\usage{
rename_view(current.views, old.name, new.name, new.abbrev = new.name)
}
\arguments{
\item{current.views}{the current view composition.}

\item{old.name}{old name of the view.}

\item{new.name}{new name of the view.}

\item{new.abbrev}{new abbreviated name.}
}
\value{
A mistyR view composition with a renamed view.
}
\description{
Rename view in a view composition
}
\examples{
view1 <- data.frame(marker1 = rnorm(100, 10, 2), marker2 = rnorm(100, 15, 3))
view2 <- data.frame(marker1 = rnorm(100, 10, 5), marker2 = rnorm(100, 15, 5))

misty.views <- create_initial_view(view1) \%>\%
  add_views(create_view("originalname", view2, "on"))
str(misty.views)

# rename and preview
misty.views \%>\%
  rename_view("originalname", "renamed", "rn") \%>\%
  str()
}
\seealso{
Other view manipulation functions: 
\code{\link{filter_views}()},
\code{\link{select_markers}()}
}
\concept{view manipulation functions}
