% algorithm 2.1 of GPML page19, train
function GPmodel = GPtrain(X,y,CovFunc,hyp,noise,mean)
% X: input matrix, nSample*nInput
% y: output, nSample*1
% CovFunc: name string of covariance function
% hyp: list of hyperparameters
% noise: std variance of observation noise, sigma^2
% mean: mean function of GP
% m: predictive marginal likelihood log(p(y|X))

[nSample, nInput] = size(X);

%%
% y = y - mean;
% X = X';
% K = zeros(nSample);
% for i = 1:nSample
%     for j = 1:i
%         K(i,j) = feval(CovFunc,hyp,X(:,i),X(:,j));
%     end
% end
% 
% L = mychol(K + noise^2*diag(ones(1,nSample)));
% alpha = LUsolve(y,L);
% m = -0.5*sum(y.*alpha) - sum(log(diag(L))) - 0.5*nSample*log(2*pi);
% X = X';
%%
switch CovFunc
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
y = y - mean;
[K, L, alpha, m] = callGPtrain(X, y, CovIdx, hyp, noise);
%%

GPmodel.CovFunc = CovFunc;
GPmodel.hyp = hyp;
GPmodel.noise = noise;
GPmodel.mean  = mean;
GPmodel.nSample = nSample;
GPmodel.nInput = nInput;
GPmodel.X = X;
GPmodel.y = y;
GPmodel.K = K;
GPmodel.L = L;
GPmodel.alpha = alpha;
GPmodel.m = m;

