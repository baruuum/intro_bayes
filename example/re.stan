data {

    int N;              // no. of obs.
    int J;              // no. of groups.
    array[N] int topic; // group membership indicator
    vector[N] x;        // predictor
    vector[N] y;        // outcome

}

parameters {

    // reg coef
    real beta;
    // resid std. dev.
    real<lower = 0> sigma_epsilon;

    // grand mean of random intercepts
    real mu_alpha;
    // std. dev. of random intercepts
    real<lower = 0> sigma_alpha;
    // aux var for efficient samping             
    vector[J] alpha_raw;

}

transformed parameters {

    // random intercepts
    // note: alpha ~ Normal(mu_alpha, sigma_alpha^2)
    vector[J] alpha = alpha_raw * sigma_alpha + mu_alpha;

}

model {

    // linear predictor (local variable)
    vector[N] yhat;

    for (n in 1:N)
        yhat[n] = alpha[topic[n]] + beta * x[n];

    // priors
    beta ~ normal(0, 1);
    mu_alpha ~ normal(0, 2);
    sigma_alpha ~ exponential(1);
    alpha_raw ~ normal(0, 1);
    sigma_epsilon ~ exponential(1);

    // vectorized likelihood
    y ~ normal(yhat, sigma_epsilon);

}

// EOF //