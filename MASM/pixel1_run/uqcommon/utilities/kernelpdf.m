function f = kernelpdf(x, p)
% compute the probability density of each point in lattice p.
% the probability density is computed from dataset x.
if nargin == 1; p = x; end;

%% use pre-compiled mex file
% f = calc_kernelpdf(x, p);

%% use matlab script
[T,d] = size(x);

lambda = (4/(d+2))^(1/(d+4))*T^(-1/(d+4));
sigma = cov(x);
invss = -0.5*inv(sigma)/lambda^2;
c = 1/(T*sqrt((2*pi)^d * det(sigma))*lambda^d);

n = size(p,1);
f = zeros(n,1);

[C, ia, ic] = unique(x,'rows');
TC = size(C,1);
H = histcounts(ic,TC);

for i = 1:TC
    mu = C(i,:);
    xm = p - repmat(mu,n,1);
    f = f + H(i) * exp(sum(xm * invss .* xm, 2));
end

f = c * f;


%%
% [T,d] = size(x);
% 
% lambda = (4/(d+2))^(1/(d+4))*T^(-1/(d+4));
% sigma = cov(x);
% invss = -0.5*inv(sigma)/lambda^2;
% c = 1/(T*sqrt((2*pi)^d * det(sigma))*lambda^d);
% 
% n = size(p,1);
% f = zeros(n,1);
% 
% for i = 1:T
%     mu = x(i,:);
%     xm = p - repmat(mu,n,1);
%     f = f + exp(sum(xm * invss .* xm, 2));
% end
% 
% f = c * f;

end


