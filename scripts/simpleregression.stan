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
    vector[N] xb;

    for (n in 1:N)
        xb[n] = alpha + beta * x[n];

    // priors 
    alpha ~ normal(0, 3);
    beta ~ normal(0, 1);
    sigma_epsilon ~ exponential(3);

    // vectorized log-likelihood
    y ~ normal(xb, sigma_epsilon);

}