% squared exponential covariance function
function k = CovSEnoisefree(hyp,x1,x2)
l = hyp(1);
sf = hyp(2);
r2 = sum(abs(x1-x2).^2);
k = sf^2*exp(-0.5*r2/(l^2));
