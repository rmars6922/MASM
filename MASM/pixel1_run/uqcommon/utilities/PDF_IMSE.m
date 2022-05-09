function D = PDF_IMSE(x1,x2,lb,ub,nbin)
% Integrated Mean Squared Error of Probability Density Function 
% Scott, 1979, Optimal and Data-based Histograms
[T1,d1] = size(x1);
[T2,d2] = size(x2);

if d1 ~= 1; error('x1 should be a vector!'); end;
if d2 ~= 1; error('x1 should be a vector!'); end; 

if nargin == 2
    h1 = 3.73*std(x1)*T1^(-1/3);
    h2 = 3.73*std(x2)*T2^(-1/3);
    lb = min([min(x1),min(x2)]);
    ub = max([max(x1),max(x2)]);
    nbin = ceil((ub-lb)/((h1+h2)/2));
elseif nargin == 4
    h1 = 3.73*std(x1)*T1^(-1/3);
    h2 = 3.73*std(x2)*T2^(-1/3);
    nbin = floor((ub-lb)/((h1+h2)/2));
elseif nargin ~= 2 && nargin ~= 4 && nargin ~= 5
    error('number of input arguments should be 2 3 or 5!');
end

% p = linspace(lb,ub,nbin)';
% f1 = kernelpdf(x1,p);
% f2 = kernelpdf(x2,p);
% % subplot(2,1,1); plot(p,f1);
% % subplot(2,1,2); plot(p,f2);
% 
% D = 0; dp = (ub-lb)/(nbin-1);
% for i = 1:nbin
%     D = D + (f1(i)-f2(i))^2 * dp;
% end

h = (ub-lb)/nbin;

[t1, f1, s1] = bin1d(x1,h,lb,ub);
[t2, f2, s2] = bin1d(x2,h,lb,ub);
% subplot(2,1,1); plot(t1,f1);
% subplot(2,1,2); plot(t2,f2);

D = 0;

for i = 1:nbin
    D = D + (f1(i)-f2(i))^2 * h;
end
