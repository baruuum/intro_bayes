data {

    int N;          // no. of obs.
    vector[N] x;    // predictor
    vector[N] y;    // outcome

}

parameters {

    real alpha;
    real beta;
    real<lower = 0> sigma_epsilon;

}

model {

    // linear predictor (local variable)
    vector[N] yhat;

    for (n in 1:N)
        yhat[n] = alpha + beta * x[n];

    // priors
    alpha ~ normal(0, 2);
    beta ~ normal(0, 1);
    sigma_epsilon ~ exponential(1);

    // vectorized likelihood
    y ~ normal(yhat, sigma_epsilon);

}

// EOF //