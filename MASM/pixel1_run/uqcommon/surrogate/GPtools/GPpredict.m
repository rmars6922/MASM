% algorithm 2.1 of GPML page19
function [f, pv] = GPpredict(GPmodel,x)
% f: predictive mean
% pv: predictive varaince
% x: input vector nSample2*nInput
%%
% [nSample2,nInput] = size(x);
% X = GPmodel.X'; x = x';
% f = zeros(nSample2,1);
% pv = zeros(nSample2,1);
% for j = 1:nSample2
%     k = feval(GPmodel.CovFunc,GPmodel.hyp,x(:,j),x(:,j));
%     kstar = zeros(GPmodel.nSample,1);
%     for i = 1:GPmodel.nSample
%         kstar(i) = feval(GPmodel.CovFunc,GPmodel.hyp,x(:,j),X(:,i));
%     end
%     f(j) = kstar'*GPmodel.alpha;
%     v = GPmodel.L\kstar;
%     pv(j) = k - v'*v;
% end
% f = f + 2*GPmodel.mean;
%%
switch GPmodel.CovFunc
    case 'CovMatern3' 
        CovIdx = 1;
    case 'CovMatern5' 
        CovIdx = 2;
    case 'CovSE' 
        CovIdx = 3;
    case 'CovSEnoisefree' 
        CovIdx = 4;
    case 'CovNN'
        CovIdx = 5;
    otherwise
        CovIdx = 1;
end

[f, pv] = callGPpredict(GPmodel.X, x, CovIdx, GPmodel.hyp, GPmodel.L, GPmodel.alpha);

f = f + GPmodel.mean;

