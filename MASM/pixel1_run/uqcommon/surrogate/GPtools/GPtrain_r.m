% algorithm 2.1 of GPML page19, train, with reinforcement learning
function GPmodel = GPtrain_r(X,y,GPmodel)
% X: reinforcement input matrix, nSample*nInput
% y: output, nSample*1

%%
% [nSample2, nInput2] = size(X);
% if nInput2 ~= GPmodel.nInput
%     disp('ERROR: dimension of X mismatch!');
% end
% 
% nSample1 = GPmodel.nSample;
% nSample = nSample1+nSample2;
% GPmodel.nSample = nSample;
% 
% X = [GPmodel.X;X];
% GPmodel.X = X;
% 
% K = zeros(nSample);
% K(1:nSample1,1:nSample1) = GPmodel.K;
% for i = nSample1+1:nSample
%     for j = 1:i
%         K(i,j) = feval(GPmodel.CovFunc,GPmodel.hyp,X(i,:),X(j,:));
%     end
% end
% GPmodel.K = K;
% 
% y = [GPmodel.y; y - GPmodel.mean];
% GPmodel.y = y;
% 
% L = mychol(K + GPmodel.noise^2*diag(ones(1,nSample)), GPmodel.L);
% alpha = LUsolve(y,L);
% m = -0.5*(y.*alpha) - sum(log(diag(L))) - 0.5*nSample*log(2*pi);
% 
% GPmodel.L = L;
% GPmodel.alpha = alpha;
% GPmodel.m = m;

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

[XX, yy, KK, LL, a, m] = callGPtrain_r(GPmodel.X, X, GPmodel.y, ...
    y-GPmodel.mean, CovIdx, GPmodel.hyp, GPmodel.noise, GPmodel.K, ...
    GPmodel.L, GPmodel.alpha);

GPmodel.X = XX;
GPmodel.y = yy;
GPmodel.K = KK;
GPmodel.L = LL;
GPmodel.alpha = a;
GPmodel.m = m;
