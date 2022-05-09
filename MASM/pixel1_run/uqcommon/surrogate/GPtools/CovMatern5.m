% Matern covariance function, GPML page85 eq4,17
function k = CovMatern5(hyp,x1,x2)
l = hyp(1);
sf = hyp(2);
r = sqrt(sum(abs(x1-x2).^2));
k = sf^2 * (1 + sqrt(5)*r/l + (5*r^2)/(3*l^2)) * exp(-sqrt(5)*r/l);