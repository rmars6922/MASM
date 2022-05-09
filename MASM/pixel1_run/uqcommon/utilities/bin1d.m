% bin counting method for probability density estimation - univariate
function [t, f, s] = bin1d(x,h,lb,ub)

n = length(x);

if nargin == 1
    h = 3.73*std(x)*length(x)^(-1/3);
    lb = min(x); ub = max(x);
elseif nargin == 2
    lb = min(x); ub = max(x);
elseif nargin ~= 1 && nargin ~= 2 && nargin ~= 4
    error('number of input arguments should be 1 2 or 4!')
end

nbin = ceil((ub-lb)/h);
ub = lb + nbin*h;

f = zeros(1,nbin);
t = zeros(1,nbin);
s = ones(1,nbin)*h;

for i = 1:n
    k = min(nbin,floor((x(i)-lb)/h + 1));
    f(k) = f(k) + 1;
end

for k = 1:nbin
    f(k) = f(k)/(n*h);
    t(k) = lb+(k-0.5)*h;
end

f = f/sum(f*h);

end