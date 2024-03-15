#!/usr/bin/env Rscript


## ------------------------------------------------------------------
## Setup
## ------------------------------------------------------------------

library("here")
library("brms")

# set seed
set.seed(42)



## ------------------------------------------------------------------
## Load data
## ------------------------------------------------------------------

data = read.csv(here("example", "data.csv"))
head(data)



## ------------------------------------------------------------------
## Model fitting using brms
## ------------------------------------------------------------------

# simple linear regression
slr_brms = brms::brm(
    formula = y ~ date,
    data = data,
    family = gaussian(),
    warmup = 500,
    iter = 1500,
    refresh = 1000,
    chains = 4,
    cores = 4,
    seed = 123
)

# results
print(slr_brms, digits = 4)
prior_summary(slr_brms)

# simple linear regression
slr_brms_w_prior = brms::brm(
    formula = y ~ date,
    data = data,
    family = gaussian(),
    prior = c(
        set_prior("normal(0, 1)", class = "Intercept"),
        set_prior("normal(0, 1)", class = "b", coef = "date"),
        set_prior("exponential(1)", class = "sigma")
    ),
    warmup = 1000,
    iter = 2000,
    refresh = 1000,
    chains = 4,
    cores = 4,
    seed = 123
)

print(slr_brms_w_prior, digits = 4)
prior_summary(slr_brms_w_prior)


pdf(here("slides", "graphics", "brms1.pdf"), width = 6, height = 8)
plot(slr_brms_w_prior, newpage = FALSE)
dev.off()

pdf(here("slides", "graphics", "brms2.pdf"), width = 6, height = 6)
brms::conditional_effects(slr_brms_w_prior, effects = "date")
dev.off()


mlm_brms = brms::brm(
    formula = y ~ date + (1 | topic),
    data = data,
    family = gaussian(),
    warmup = 1000,
    iter = 2000,
    refresh = 1000,
    chains = 4,
    cores = 4,
    seed = 123
)
print(mlm_brms)
prior_summary(mlm_brms)


mlm_brms_w_prior = brms::brm(
    formula = y ~ date + (1 | topic),
    data = data,
    family = gaussian(),
    prior = c(
        set_prior("normal(0, 1)", class = "Intercept"),
        set_prior("normal(0, 1)", class = "b", coef = "date"),
        set_prior("exponential(1)", class = "sigma"),
        set_prior("exponential(1)", class = "sd")
    ),
    warmup = 1000,
    iter = 2000,
    refresh = 1000,
    chains = 4,
    cores = 4,
    seed = 123
)

print(mlm_brms_w_prior, digits = 4)
conditional_effects(mlm_brms_w_prior, effect = "date")

psamples = as_draws(mlm_brms_w_prior)
class(psamples)
length(psamples)
class(psamples[[1]])
names(psamples[[1]])


## ------------------------------------------------------------------
## Cmdstanr
## ------------------------------------------------------------------

library("cmdstanr")

# compile model 
mod = cmdstan_model(here("example", "slr.stan"))

# make data for stan
standata = list(
    N = nrow(dat),
    x = dat$date,
    y = dat$y
)

# fit model
fit = mod$sample(
    data = standata,
    chains = 4,
    parallel_chains = 4,
    iter_warmup = 1000,
    iter_sampling = 1000,
    refresh = 1000
)

fit$summary()
psamples2 = fit$draws()

# Auto-diff variational Bayes
vb = mod$variational(data = standata)

# penalized MLE 
pmle = = mod$optimize(data = standata)

# pathfinder approximation
pfinder = mod$pathfinder(data = standata)

# laplace approximation
laplace = mod$laplace(data = standata)


## ------------------------------------------------------------------
## mlm
## ------------------------------------------------------------------

# no of topics
J = length(unique(dat$topic))

# check topic ids
stopifnot(all(seq_len(J) == sort(unique(dat$topic))))

standata_mlm = list(
    N = nrow(dat),
    J = J,
    topic = dat$topic,
    x = dat$date,
    y = dat$y
)

mlm = cmdstan_model(here("example", "re.stan"))
pf = mlm$pathfinder(data = standata_mlm)
pf$print(digits = 5, max_rows = 100)
