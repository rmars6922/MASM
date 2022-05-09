% find optimal hyperparameter for GPmodel
% maximum marginal likelihood
function GPmodel = GPopthyp(GPmodel)

mat.nInput = length(GPmodel.hyp);
mat.xub    = 10*ones(1,mat.nInput);
mat.xlb    = -10*ones(1,mat.nInput);
mat.sm     = GPmodel;

tmpgpm = GPMML(mat);

silent = 1; % use silent mode;
config.ngs    = 2;
config.kstop  = 10;
config.pcento = 0.1;
config.peps   = 0.001;
config.maxn   = 3000; 

result = sceua(tmpgpm,tmpgpm.nInput,config.maxn,config.kstop,...
            config.pcento,config.peps,config.ngs,silent);

mx = GPmodel.mean;
GPmodel = GPtrain(GPmodel.X,GPmodel.y,...
    GPmodel.CovFunc,exp(result.bestx),GPmodel.noise,0);
GPmodel.mean = mx;