% Matern covariance function, GPML page85 eq4,17
function k = CovMatern3(hyp,x1,x2)
l = hyp(1);
sf = hyp(2);
r = sqrt(sum(abs(x1-x2).^2));
k = sf^2 *(1 + sqrt(3)*r/l) * exp(-sqrt(3)*r/l);
