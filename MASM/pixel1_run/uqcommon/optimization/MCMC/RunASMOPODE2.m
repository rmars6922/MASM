function result = RunASMOPODE2(uqdata,model)
% Adaptive Surrogate Model Optimization - Parameter Optimization and Distribution Estimation
% coded by gongwei, GCESS, BNU
% model: information about the model and its likelihood function

% config of ASMO-PODE
niter     = uqdata.optimization.config.niter;
nhist     = uqdata.optimization.config.nhist;
resample  = 'tic-toc-mostlikely';
% resolution = sqrt(model.nInputS*((...
%     uqdata.optimization.config.resolution)^2));
resolution = uqdata.optimization.config.resolution;


% config of surrogate model
mat = readJSONfile(uqdata.modelJSON);
if ~isfield(uqdata,'surrogate')
    mat.smtype = 'GPR';
elseif ~isfield(uqdata.surrogate,'method')
    mat.smtype = 'GPR';
else
    mat.smtype = uqdata.surrogate.method;
    if isfield(uqdata.surrogate,'config')
        mat.config = uqdata.surrogate.config;
    end
end
if model.outputidx == 0 && model.nOutput > 1
    % for multi-objective optimization
    tmpinputidx = [];
    if ~isfield(mat,'outputFlags')
        mat = setfield(mat,'outputFlags',{});
        for i = 1:mat.nOutput
            mat.outputFlags = setfield(mat.outputFlags,mat.outputNames{i},1:mat.nInput);
            %obj.outputFlags{i} = 1:obj.nInput;
        end
    end
    for i = 1:mat.nInput
        tick = 0;
        for j = 1:mat.nOutput
            if ~isempty( find(getfield(mat.outputFlags,mat.outputNames{j}) == i, 1) )
                tick = tick + 1;
            end
        end
        if tick > 0
            tmpinputidx = [tmpinputidx, i];
        end
    end
    mat.outputFlags = setfield(mat.outputFlags,mat.outputNames{1},tmpinputidx);
    mat.nOutput = 1;
end

xu = uqdata.sampling.result.xu; % initial samples: para (screened)
x  = uqdata.sampling.result.x;
f  = uqdata.sampling.result.f;  % initial samples: raw obj
if model.outputidx == 0 && model.nOutput > 1
    % multi-objective MCMC using the fit function in [Li, 2012]
    if ~isfield(uqdata.optimization.config,'ref')
        y = fitfunc(f);
    else
        ref = uqdata.optimization.config.ref;
        y = fitfunc(f,ref);
    end
else
    % single-objective MCMC using the outputidx
    y  = uqdata.sampling.result.y;  % initial samples: obj  (outputidx)
end

% run ASMO-PODE
SM_KL = zeros(niter,model.nInputS); % Kullback-Leibler divergence
SM_RMSE = zeros(1,niter); % RMSE of surrogate model
SM_ntoc = zeros(1,niter); % number of toc (maxmin distance resampling) in each iteration
result.xflat = {};  % save the history of posterior distribution
for iter = 1:niter+1
    disp(['Surrogate Opt Loop: ',num2str(iter)]);
 %   load rsm;
    rsm = fitrgp(fromunit(xu),y,'Basis','linear','KernelFunction','matern32',...
      'FitMethod','exact','PredictMethod','exact','Standardize',1);
    ypred = predict(rsm,fromunit(xu));
    SM_RMSE(iter,1) = sqrt(mean((ypred - y).^2));
    
%     VisualRS(rsm);
    rsresult = RunMetro(uqdata,rsm);
%     rsresult = RunDRAM(uqdata,rsm);
%     rsresult = RunDREAM(uqdata,rsm);
%     rsresult = RunMTDREAMZS(uqdata,rsm);
    result.grb(iter) = rsresult.grb;
    disp(['GRB factor: ',num2str(rsresult.grb)]);
    result.xflat{iter} = rsresult.xflat; % save the history of posterior distribution
    result.pflat{iter} = rsresult.pflat; % save the history of posterior distribution
    
%     [yp, idx] = sort(rsresult.pflat,'descend'); % sort the likelihood with descend order
    [yp, idx] = sort(rsresult.pflat); % sort the -2log(likelihood) with acsend order
    
    if iter == 1
        xpold = rand(length(yp),model.nInputS);
    else
        xpold = xp;
    end
    xp = tounit(rsresult.xflat(idx,:));
   % for i = 1:model.nInputS
   %     SM_KL(iter,i) = KLdivergence(xp(:,i),xpold(:,i),0,1);
   % end
 % % save results
    if(iter== niter+1 )
        save([model.modelPath,'/rsm_',num2str(fix(clock),'%04d_%02d_%02d_%02d_%02d_%02d'),'.mat'],'rsm');
        %save([model.modelPath,'/SM_KL_',num2str(fix(clock),'%04d_%02d_%02d_%02d_%02d_%02d'),'.mat'],'SM_KL');
        %save([model.modelPath,'/result_',num2str(fix(clock),'%04d_%02d_%02d_%02d_%02d_%02d'),'.mat'],'result');
        save([model.modelPath,'/SM_RMSE_',num2str(fix(clock),'%04d_%02d_%02d_%02d_%02d_%02d'),'.mat'],'SM_RMSE');
    end   
    if iter <= niter % adaptive sampling strategy
        ntotal = length(yp);
        nbin   = floor(ntotal/nhist);

        xrf = zeros(nhist,model.nInputS);

        switch resample
            case 'tic-toc-mostlikely'
                nbin = floor(ntotal/(nhist-1));
                % tic-toc resampling and the most likeli point
                for ihist = 1:nhist-1
                    [xtmp, mdist] = maxmindist(xu,...
                        unique(xp(nbin*(ihist-1)+1:nbin*ihist,:),'rows'));
                    if mdist < resolution;
                        [xtmp, ~] = maxmindist(xu,rand(10000,model.nInputS));
                        SM_ntoc(iter) = SM_ntoc(iter) + 1;
                    end
                    xrf(ihist,:) = xtmp;
                    xu = [xu;xrf(ihist,:)];
                end
                xrf(nhist,:) = xp(1,:);
                xu = [xu;xrf(nhist,:)];
            case 'tic-toc'
                % resampling tic-toc
                for ihist = 1:nhist
                    [xtmp, mdist] = maxmindist(xu,...
                        unique(xp(nbin*(ihist-1)+1:nbin*ihist,:),'rows'));
                    if mdist < resolution;
                        [xtmp, ~] = maxmindist(xu,rand(10000,model.nInputS));
                        SM_ntoc(iter) = SM_ntoc(iter) + 1;
                    end
                    xrf(ihist,:) = xtmp;
                    xu = [xu;xrf(ihist,:)];
                end
            case 'uniform'
                % resampling with maximum minimum distance, uniformly
                for ihist = 1:nhist
                    xrf(ihist,:) = maxmindist(xu,rand(10000,model.nInputS));
                    xu = [xu;xrf(ihist,:)];
                end
            case 'posterior'
                % resampling with maximum minimum distance, in each quantile-bin
                for ihist = 1:nhist
                    xrf(ihist,:) = maxmindist(xu,...
                        unique(xp(nbin*(ihist-1)+1:nbin*ihist,:),'rows'));
                    xu = [xu;xrf(ihist,:)];
                end
            case 'posterior-randomly'
                % resampling randomly, in each quantile-bin
                for ihist = 1:nhist
                    xrf(ihist,:) = xp(int32(ceil(nbin*(ihist-1)+nbin*rand)),:);
                end
                xu = [xu;xrf];
            case 'posterior-mostlikely'
                % resampling mostlikely, in each quantile-bin
                for ihist = 1:nhist
                    xrf(ihist,:) = xp(nbin*(ihist-1)+1,:);
                end
                xu = [xu;xrf];        
        end

        [yrf, frf] = model.rununit(xrf);
        f = [f;frf];
        if model.outputidx == 0 && model.nOutput > 1
            % for multi-objective optimization
            if ~isfield(uqdata.optimization.config,'ref')
                y = fitfunc(f);
            else
                y = fitfunc(f,ref);
            end
        else
            y = [y;yrf];
        end
    end
end

[~, bestidx] = min(result.pflat{niter+1});
bestx1 = result.xflat{niter+1}(bestidx,:);
besty1 = model.run(bestx1);
[besty2, bestidx] = min(y);
bestx2 = model.fromunit(xu(bestidx,:));
if besty1 < besty2
    result.besty = besty1;
    result.bestx = bestx1;
else
    result.besty = besty2;
    result.bestx = bestx2;
end

result.SM_KL = SM_KL; % Kullback-Leibler divergence
result.SM_RMSE = SM_RMSE; % RMSE of surrogate model
result.SM_ntoc = SM_ntoc; % number of 'toc' (uniform samples) in each iteration
result.xp = result.xflat{end}; % final posterior distribution
result.xu = xu; % evaluated points, xu (screened, unit para)
result.f  = f;  % evaluated points, all model outputs for multi-obj problems 
result.y  = y;  % evaluated points, -2log(likelihood) or fitfunc

end

%%
function [P,D] = maxmindist(A,B)
% maximize the minimum distance from point set B to A
% A is the referene point set
% for each point in B, compute its distance to its nearest neighbor of A
% find the point in B that has largest min-dist
% P: the coordinate of point
% D: the maxmin distance
[T1,~] = size(A);
[T2,~] = size(B);

Dist = zeros(T1,T2);
for i = 1:T1
    for j = 1:T2
        Dist(i,j) = sum((A(i,:) - B(j,:)).^2);
    end
end

mindist = min(Dist);
[D,idx] = max(mindist);
P = B(idx,:);

end

%%
function y = fitfunc(f,ref)
% fit function for multi-objective MCMC
% [Li, 2012]
% f: the full output obj
% y: the loged-likelihood function for MCMC
% Don't use the original likelihood function because it's usually too small

[n,d] = size(f);
y = zeros(n,1);
[rank, dom] = fast_non_dominated_sort(f);

for i = 1:n
    if rank(i) == 1
        % non-dominated points
        % compute the strength of each point
        % strength = number of dominated points / total points
        s = 0;
        for j = 1:n
            if dom(i,j) == 1
                s = s + 1;
            end
        end
        s = s - 1; % exclude itself
        s = s/n;
        y(i) = s;
    else
        % dominated points
        % sum of the hyper-volumn between Pi and all points dominating it
        v = 1;
        for j = 1:n
            if dom(i,j) == 2
                v = v + prod(f(i,:)-f(j,:));
            end
        end
        y(i) = v;
    end
end

if nargin == 2
    % assign weights if ref point is given
    weight = 100;
    for i = 1:n
        for j = 1:d
            if f(i,j) > ref(j)
                y(i) = y(i) + weight;
            end
        end
    end
end

end
% ---------------------------------------- Running Metro 
function result = RunMetro(uqdata,gprMdl)
% Metropolis sampler
% nchain: number of Markov Chains
% nmax:   maximum number of sample points of each chain
% model:  information about the model and its likelihood function
nchain = uqdata.optimization.config.nchain;
nmax   = uqdata.optimization.config.nmax;
ndim   = 7;

% define posterior distribution
% posterior = likelihood * prior/marginal likelihood
% use -2log(pdf); prior distribution is U[0,1]
posterior = 1;

% run MCMC sampler
[x,px,xf,pf,acc] = metro_sampler(gprMdl,nchain,nmax,ndim);

% compute GRB factor, exclude the burn-in part
nburnin = int32(ceil(nmax/2));
grb = GRBfactor(x((nmax-nburnin+1):end,:,:),nmax-nburnin,nchain,ndim);

result.x = x;
result.px = px;
result.acc = acc;
result.arate = sum(acc)/nmax;
result.xflat = xf(((nmax-nburnin)*nchain+1):end,:);
result.pflat = pf(((nmax-nburnin)*nchain+1):end);
result.grb = grb;

end

%%
function [x,px,xf,pf,acc] = metro_sampler(gprMdl,nchain,nmax,ndim,xprior)
% Metropolis sampler
% pdf: -2log(posterior distribution)
% nchain: number of Markov Chains
% nmax: maximum chain length
% ndim: number of dimensionality
% xprior: samples of prior distribution (nchain*ndim, [0,1])

x   = zeros(nmax,nchain,ndim); % Markov Chain, parameter history
px  = zeros(nmax,nchain);      % pdf history
xf  = zeros(nmax*nchain,ndim); % flatten Markov Chain history
pf  = zeros(nmax*nchain,1);    % flatten posterior history
acc = zeros(nmax,1);           % accept/decline history

s = 0.1;  % sigma of proposal distribution
% vmaxub,p5,p14,p15,p17,p18,p20
%     parub = [0.1,0.996,0.996,7.0e-05,0.1,0.7,365];
% 	parlb = [0.05,0.6,0.6,2.0e-5,1.0e-04,0.2,200];
% 	pardf = [0.06,0.97,0.99,3.0e-05,0.06,0.48,270];

cmax = [0.1,0.996,0.996,8.0e-05,0.1,0.7,365];
cmin = [0.05,0.6,0.6,2.0e-5,1.0e-04,0.1,200];
xdf = [0.06,0.97,0.99,3.0e-05,0.06,0.48,270];
parrng = cmax - cmin;
parrngd = zeros(nchain,ndim)+1;
Xd = zeros(nchain,ndim)+1;
for i = 1:nchain
    for j = 1:ndim
        X(i,j) = Xd(i,j).*xdf(1,j);
    end
end
for i = 1:nchain
    for j = 1:ndim
        range(i,j) = parrngd(i,j).*parrng(1,j);
    end
end

for i = 1:nchain
    pX(i,:) = predict(gprMdl,X(i,:)); % compute posterior pdf (pX is nchain*1)
end
ydf = pX(1,:);
x(1,:,:) = X; 
px(1,:) = pX; 
XP = X; 
pXP = pX; % initialize
allow = 50;
for mm = 2:nmax
    mm
    % step 1, generate proposed point  
      sump = 0;
      while (sump<4)
             X = XP + (rand(nchain,7)-0.5).*range/allow;
          for i = 1:nchain
              if  (X(i,1)>cmin(1)&X(i,1)<cmax(1)...
                &X(i,2)>cmin(2)&X(i,2)<cmax(2)...
                &X(i,3)>cmin(3)&X(i,3)<cmax(3)...
                &X(i,4)>cmin(4)&X(i,4)<cmax(4)...
                &X(i,5)>cmin(5)&X(i,5)<cmax(5)...               
                &X(i,6)>cmin(6)&X(i,6)<cmax(6)...                    
                &X(i,7)>cmin(7)&X(i,7)<cmax(7)) 
                p(i,:) = 1;    
              else
                p(i,:) = 0;
              end
          end
          sump = p(1,1)+p(2,1)+p(3,1)+p(4,1);
       end
 
  %  X  = fromunit(bound(s*randn(nchain,ndim) + XP)); % use normal distribution as proposal
  
    for h = 1:nchain
        pX(h,:) = predict(gprMdl,X(h,:)); % compute posterior pdf
    end
    % step 2, compute the acceptance ratio
%     r = min(1, pX./pXP);             % likelihood
    r = min(1,exp(-0.5*(pX-pXP))); % -2log(likelihood)
     for i = 1:nchain
        if(pX(i,:)<0.0)
            pX(i,:) = ydf;
            X(i,:) = xdf;
        end
     end   
    % step 3, acceptance or decline
    u = rand(nchain,1);
    idx = u<r; acc(i) = sum(idx)/nchain;
    Xt = XP; Xt(idx,:) = X(idx,:);
    pXt = pXP; pXt(idx) = pX(idx);
    x(mm,:,:) = Xt; px(mm,:) = pXt;
    xf(((mm-1)*nchain+1):(mm*nchain),:) = Xt;
    pf(((mm-1)*nchain+1):(mm*nchain)) = pXt;
    
    % store previous X and pX
    XP = Xt; pXP = pXt;
end

end

%%
function X = bound(X)
% constrain the point set X to [0,1] bound
bdoption = 'reflect';
idx0 = X<0;
idx1 = X>1;
switch bdoption
    case 'bound'
        X(idx1) = 1; X(idx0) = 0;
    case 'reflect'
        X(idx1) = ceil(X(idx1))-X(idx1);
        X(idx0) = ceil(X(idx0))-X(idx0);
    case 'fold'
        X(idx1) = X(idx1)-floor(X(idx1));
        X(idx0) = X(idx0)-floor(X(idx1));
end
end