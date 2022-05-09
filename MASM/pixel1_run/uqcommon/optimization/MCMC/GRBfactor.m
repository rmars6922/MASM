function grb = GRBfactor(x,nmax,nchain,ndim)
% Gelman-Rubin-Brooks multivariate potential scale
% reduction factor MCMC convergence diagnostic.
% S. Brooks and G. Roberts, Assessing Convergence of Markov Chain 
% Monte Carlo Algorithms, Statistics and Computing 8, 319-335, 1998.

% nchain: number of chains
% nmax: number of iterations
% ndim: dimension of the distribution
% x: MC sequence, size(x) = [nmax,nchain,ndim]

if nchain > 1
    M = zeros(nchain,ndim);
    V = zeros(ndim,ndim);
    for i = 1:nchain
        M(i,:) = mean(x(:,i,:));
        V = V + cov(reshape(x(:,i,:),[nmax,ndim]));
    end

    V1 = V/nchain;
    V2 = cov(M);

    lambda = max(eigs(V1*pinv(V2)));

    grb = sqrt(double((nmax-1)/nmax) + (nchain+1)/nchain*lambda);
else
    grb = NaN;
end