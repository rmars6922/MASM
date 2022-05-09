% squared exponential covariance function
function k = CovSE(hyp,x1,x2)
l = hyp(1);
sf = hyp(2);
sn = hyp(3);
r2 = sum(abs(x1-x2).^2);
if r2 > 0;
    k = sf^2*exp(-0.5*r2/l^2) + sn^2;
else
    k = sf^2*exp(-0.5*r2/l^2);
end