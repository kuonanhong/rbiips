% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pmmh.r
\name{pmmh-object}
\alias{pmmh-object}
\alias{pmmh}
\alias{biips_pmmh_update}
\alias{biips_pmmh_samples}
\alias{is.pmmh}
\alias{biips_pmmh_update.pmmh}
\alias{biips_pmmh_samples.pmmh}
\title{Manipulate PMMH objects.}
\usage{
is.pmmh(object)

\method{biips_pmmh_update}{pmmh}(object, n_iter, n_part, thin = 1,
  max_fail = 0, rw_adapt = TRUE, output = "p", ...)

\method{biips_pmmh_samples}{pmmh}(object, n_iter, n_part, thin = 1,
  max_fail = 0, output = "p", ...)
}
\arguments{
\item{object}{a \code{pmmh} object as returned by
\code{\link{biips_pmmh_init}}.}

\item{n_iter}{integer. Number of burn-in iterations.}

\item{n_part}{integer. Number of particles used in SMC algorithms.}

\item{thin}{integer. Thinning interval. Returns samples every \code{thin}
iterations (default = 1)}

\item{max_fail}{integer. maximum number of failed SMC algorithms allowed.
(default=0).}

\item{rw_adapt}{logical. Activate adaptation of the proposal
(default=\code{TRUE}).}

\item{output}{string. Select additional members to be returned in the
\code{\link{mcmcarray.list}} output. The string can contain several
characters in \code{('p', 'l', 'a', 's', 'f')}. See details. (default = \code{'p'})}

\item{...}{Additional arguments to be passed to the SMC
algorithm such as \code{rs_thres} and \code{rs_type}.
See \code{\link{biips_smc_samples}}  for more details.}
}
\value{
The function \code{is.pmmh} returns \code{TRUE} if the object is of
  class \code{pmmh}.

The methods \code{biips_pmmh_update} and \code{biips_pmmh_update}
  return an object of class \code{\link{mcmcarray.list}}.

\code{biips_pmmh_samples} output contains one \code{\link{mcmcarray}}
  member for each monitored variable returned by the \code{param_names()} and
  \code{latent_names()} member functions of the \code{pmmh} object.

The members of the \code{\link{mcmcarray.list}} object are
  \code{\link{mcmcarray}} objects for different variables. Assuming
  \code{dim} is the dimension of the monitored variable, the
  \code{\link{mcmcarray}} object is an array of dimension \code{c(dim,
  n_iter)} with the following attributes (accessible with
  \code{\link[base]{attr}}):
  \item{name}{string with the name of the variable.}
  \item{lower}{vector with the lower bounds of the variable.}
  \item{upper}{vector with the upper bounds of the variable.}

If the \code{output} argument is not empty, the output contains
  additional members. See details.
}
\description{
Manipulate PMMH objects.

The method \code{biips_pmmh_update} performs adaptation and burn-in
iterations for the PMMH algorithm.

The method \code{biips_pmmh_samples} performs iterations for the PMMH
algorithm and returns samples.
}
\details{
The \code{output} string arguments can be used to query additional
  members in the \code{\link{mcmcarray.list}} output. If \code{output}
  contains:
  \describe{
    \item{p}{returns member \code{log_marg_like_pen}. \code{\link{mcmcarray}} with penalized
    log marginal likelihood estimates over iterations.}
    \item{l}{returns member \code{log_marg_like}. \code{\link{mcmcarray}}
    with log marginal likelihood estimates over iterations.}
    \item{a}{returns member \code{info$accept_rate}. \code{\link{mcmcarray}} with acceptance
    rate over iterations.}
    \item{s}{returns member \code{info$rw_step}. \code{\link{mcmcarray}}
    with standard deviations of the random walk over iterations.}
    \item{f}{returns member \code{info$n_fail}. number of failed SMC algorithms.}
  }
}
\examples{
modelfile <- system.file('extdata', 'hmm.bug', package = 'rbiips')
stopifnot(nchar(modelfile) > 0)
cat(readLines(modelfile), sep = '\\n')

data <- list(tmax = 10, p = c(.5, .5), logtau_true = log(1))
model <- biips_model(modelfile, data)

n_part <- 50
obj_pmmh <- biips_pmmh_init(model, 'logtau', latent_names = c('x', 'c[2:10]'),
                            inits = list(logtau = -2))  # Initialize
is.pmmh(obj_pmmh)
out_pmmh_burn <- biips_pmmh_update(obj_pmmh, 100, n_part)  # Burn-in
out_pmmh <- biips_pmmh_samples(obj_pmmh, 100, n_part, thin = 1)  # Samples

dens_pmmh_lt <- biips_density(out_pmmh$logtau)
summ_pmmh_x <- biips_summary(out_pmmh$x, order = 2, probs = c(0.025, 0.975))
dens_pmmh_x <- biips_density(out_pmmh$x)
summ_pmmh_c <- biips_summary(out_pmmh[['c[2:10]']])
table_pmmh_c <- biips_table(out_pmmh[['c[2:10]']])

par(mfrow = c(2, 2))
plot(c(out_pmmh_burn$log_marg_like_pen, out_pmmh$log_marg_like_pen), type = 'l',
     col = 'blue', xlab = 'PMMH iteration', ylab = 'log p(y|logtau) + log p(logtau)')

plot(out_pmmh$logtau[1, ], type = 'l', col = 'blue',
     xlab = 'PMMH iteration', ylab = 'logtau')
points(0, model$data()$logtau_true, pch = 17, col = 'green')

plot(dens_pmmh_lt, col = 'blue', ylab = 'posterior density')
points(model$data()$logtau_true, 0, pch = 17, col = 'green')

biips_hist(out_pmmh$logtau, col = 'blue', ylab = 'posterior density')
points(model$data()$logtau_true, 0, pch = 17, col = 'green')

par(mfrow = c(2, 2))
plot(model$data()$x_true, type = 'l', col = 'green', xlab = 't', ylab = 'x[t]')
lines(summ_pmmh_x$mean, col = 'blue')
matlines(matrix(unlist(summ_pmmh_x$quant), data$tmax), lty = 2, col = 'blue')
legend('topright', leg = c('true', 'PMMH estimate'), lty = c(2, 1),
       col = c('green', 'blue'), bty = 'n')

barplot(.5*(model$data()$c_true==1), col = 'green', border = NA, space = 0, offset = 1,
        ylim=c(0,2), xlab='t', ylab='c[t]==1', axes = FALSE)
axis(1, at=1:data$tmax-.5, labels=1:data$tmax)
axis(2, line = 1, at=c(0,2), labels=NA)
text(data$tmax/2, 1.75, 'true')
barplot(.5*c(NA, summ_pmmh_c$mode==1), col = 'blue', border = NA, space = 0,
        axes = FALSE, add = TRUE)
text(data$tmax/2, .75, 'PMMH mode')

t <- 5
plot(dens_pmmh_x[[t]], col='blue', ylab = 'posterior density')
points(model$data()$x_true[t], 0, pch = 17, col = 'green')

plot(table_pmmh_c[[t-1]], col='blue', ylab = 'posterior probability mass')
points(model$data()$c_true[t], 0, pch = 17, col = 'green')
}
\seealso{
\code{\link{biips_pmmh_init}}
}
