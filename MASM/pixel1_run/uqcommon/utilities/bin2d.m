% bin counting method for probability density estimation - bivariate
function [t1, t2, f, s1, s2] = bin2d(x,h,lb,ub)
n = length(x);

if nargin == 1
    h  = [hopt(x(:,1),n),hopt(x(:,2),n)];
    lb = [min(x(:,1)),min(x(:,2))];
    ub = [max(x(:,1)),max(x(:,2))];
elseif nargin == 2
    lb = [min(x(:,1)),min(x(:,2))];
    ub = [max(x(:,1)),max(x(:,2))];
elseif nargin ~= 1 && nargin ~= 2 && nargin ~= 4
    error('number of input arguments should be 1, 2 or 4!')
end

for i = 1:2
    nbin(i) = ceil((ub(i)-lb(i))/h(i));
    ub(i) = lb(i) + nbin(i)*h(i);
end

v = bincounting2d(x,n,lb,nbin,h);
[t1, t2, f, s1, s2] = pdf2d(v,n,lb,nbin,h);

end

%% optimum binwidth, p119, normal reference rule
function h = hopt(x,n)
    h = 2.576*std(x)*n^(-0.2);
end

%% bincounting for 2d data, p117
function v = bincounting2d(x,n,lb,nbin,h)
    v = zeros(nbin(1),nbin(2));
    for i = 1:n
        k1 = floor((x(i,1)-lb(1))/h(1) + 1);
        k2 = floor((x(i,2)-lb(2))/h(2) + 1);
        v(k1,k2) = v(k1,k2) + 1;
    end
end

%% pdf estimation with bin counting results
function [t1, t2, f, s1, s2] = pdf2d(v,n,lb,nbin,h)
    f = v;
    s1 = ones(1,nbin(1))*h(1);
    s2 = ones(1,nbin(2))*h(2);
    
    f = f./(n*h(1)*h(2));
    f = f';
    f = f/sum(f*h(1)*h(2));
    tx = zeros(1,nbin(1));
    ty = zeros(1,nbin(2));
    for k = 1:nbin(1); tx(k) = lb(1) + (k-0.5)*h(1); end;
    for l = 1:nbin(2); ty(l) = lb(2) + (l-0.5)*h(2); end;
    [t1, t2] = meshgrid(tx,ty);
end