function x = mvgrnd(T,mu,sigma)
% random generator of multivariate Gaussian distribution
% mu: 1*d mean vector
% sigma: d*d covariance matrix, must be positive definite
% x: generated random metrix, T*d, T points, d dimensional Gaussian
% distribution
d = length(mu);
R = chol(sigma);
x = randn(T,d)*R + repmat(mu,T,1);
end