function f = mvgpdf(x,mu,sigma)
% probability density of multivariate Gaussian distribution
% x: T*d random points
% mu: 1*d mean vector
% sigma: d*d covariance matrix, must be positive definite
[T,d] = size(x);
c = 1/sqrt((2*pi)^d * det(sigma));
invsigma = inv(sigma);
f = zeros(T,1);
for i = 1:T
    xmu = x(i,:) - mu;
    f(i) = exp(-0.5 * xmu * invsigma * xmu');
end
f = c * f;
end