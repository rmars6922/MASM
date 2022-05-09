function uqdata = RunOptimization(uqdata,model)
% Parameter Optimization
% use screened parameters
% consider the 'screened' and 'outputidx' options

% trim the full input para if the optimization use screened paras
if isfield(uqdata,'sampling')
    if model.screened
        xf = uqdata.sampling.result.x;
        T  = size(xf,1);
        x  = xf(:,model.inputidx);
        for i = 1:T
            xu(i,:) = (x(i,:) - model.xlbS)./model.xrgS;
        end
        uqdata.sampling.result.xu = xu;
    end
    if ~isfield(uqdata.sampling.result,'y')
        if model.outputidx == 0
            uqdata.sampling.result.y = uqdata.sampling.result.f;
        elseif model.outputidx == -1
            % return weighting function
            T = size(uqdata.sampling.result.x,1);
            y = zeros(T,1);
            for i = 1:model.nOutput
                y = y + model.outputWeights(i) * uqdata.sampling.result.f(:,i);
            end
            uqdata.sampling.result.y = y/sum(model.outputWeights);
        elseif model.outputidx == -2
            % return the distance to the origin
            T = size(uqdata.sampling.result.x,1);
            y = zeros(T,1);
            for i = 1:T
                y(i) = sqrt(sum(uqdata.sampling.result.f(i,:).^2));
            end
        else
            uqdata.sampling.result.y = uqdata.sampling.result.f(:,model.outputidx);
        end
    end
end

switch uqdata.optimization.method    
    case 'GA'
        % Genetic Algorithm
        if ~isfield(uqdata.optimization,'config')
            config.pop = 100;
            config.gen = 100;
            uqdata.optimization.config = config;
        else
            config = uqdata.optimization.config;
        end
        uqdata.optimization.result = ...
            GeneticAlgorithm(model,config.pop,config.gen,model.nInputS);
    case 'NSGA-II'
        % Nondominated Sorting Genetic Algorithm II
        if ~isfield(uqdata.optimization,'config')
            config.pop = 100;
            config.gen = 100;
            uqdata.optimization.config = config;
        else
            config = uqdata.optimization.config;
        end
        uqdata.optimization.result = ...
            NondominatedSortingGeneticAlgorithmII(model,...
            config.pop,config.gen,model.nInputS,model.nOutput);
    case 'WNSGA'
        % Weighted - Nondominated Sorting Genetic Algorithm II
        if ~isfield(uqdata.optimization,'config')
            config.pop = 100;
            config.gen = 100;
            config.ref = 1e9*ones(1,model.nOutput);
            uqdata.optimization.config = config;
        else
            config = uqdata.optimization.config;
        end
        uqdata.optimization.result = WNSGA(model,...
            config.pop,config.gen,model.nInputS,model.nOutput,config.ref);
    case 'SCE-UA'
        % Shuffled Complex Envolution
        if ~isfield(uqdata.optimization,'config')
            config.ngs    = 2;
            config.kstop  = 10;
            config.pcento = 0.1;
            config.peps   = 0.001;
            config.maxn   = 3000; 
            config.silent = 0; % default do not use silient mode
            uqdata.optimization.config = config;
        else
            config = uqdata.optimization.config;
        end
        uqdata.optimization.result = ...
            sceua(model,model.nInputS,config.maxn,config.kstop,...
            config.pcento,config.peps,config.ngs,config.silent);
    case 'MOSCEM-UA'
        % MULTI OBJECTIVE SHUFFLED COMPLEX EVOLUTION METROPOLIS 
        if ~isfield(uqdata.optimization,'config')
            config.q       = 4;
            config.maxloop = 25;
            config.maxn    = 10000;
            uqdata.optimization.config = config;
        else
            config = uqdata.optimization.config;
        end
        uqdata.optimization.result = RunMOSCEM(model,config);
    case 'ASMO'
        % Adaptive surrogate model based optimization
        if ~isfield(uqdata.optimization,'config')
            config.ngs    = 2;
            config.kstop  = 10;
            config.pcento = 0.1;
            config.peps   = 0.001;
            config.maxn_d = 1000;
            config.maxn_s = 3000;
            uqdata.optimization.config = config;
        end
        silent = 0; % default do not use silient mode
        uqdata.optimization.result = RunASMO(uqdata,model,silent);
    case 'MO-ASMO'
        %  Multi-Objective Adaptive Surrogate Model Optimization
        if ~isfield(uqdata.optimization,'config')
            config.niter = 5;
            config.maxn  = 1000;
            config.pop   = 100;
            config.gen   = 100;
            config.pct   = 0.2;
            uqdata.optimization.config = config;
        end
        uqdata.optimization.result = RunMOASMO(uqdata,model);
    case 'WMO-ASMO'
        %  Weighted Multi-Objective Adaptive Surrogate Model Optimization
        if ~isfield(uqdata.optimization,'config')
            config.niter = 5;
            config.maxn  = 1000;
            config.pop   = 100;
            config.gen   = 100;
            config.pct   = 0.2;
            config.ref   = 1e9*ones(1,model.nOutput);
            uqdata.optimization.config = config;
        end
        uqdata.optimization.result = RunWMOASMO(uqdata,model);
    case 'Metro'
        % Metropolis
        if ~isfield(uqdata.optimization,'config')
            config.nchain = 12;
            config.nmax   = 10000;
            uqdata.optimization.config = config;
        end
        uqdata.optimization.result = RunAM2(uqdata,model);
    case 'AM'
        % Adaptive-Metropolis
        if ~isfield(uqdata.optimization,'config')
            config.nchain = 12;
            config.nmax   = 10000;
            uqdata.optimization.config = config;
        end
        uqdata.optimization.result = RunAM(uqdata,model);
    case 'DRAM'
        % Delayed Rejection Adaptive-Metropolis
        if ~isfield(uqdata.optimization,'config')
            config.nchain = 12;
            config.nmax   = 10000;
            uqdata.optimization.config = config;
        end
        uqdata.optimization.result = RunDRAM(uqdata,model);
    case 'ASMO-PODE'
        % Adaptive Surrogate Model Optimization - Parameter Optimization
        % and Distribution Estimation
        if ~isfield(uqdata.optimization,'config')
            config.niter     = 10;
            config.nhist     = 100;
            config.nchain    = 4;
            config.nmax      = 10000;
            config.resolution= 1e-4;
            uqdata.optimization.config = config;
        end
        uqdata.optimization.result = RunASMOPODE2(uqdata,model);
        
%     case 'PGW10'
%         % parallel affine-invariant ensemble sampler for MCMC proposed by Goodman & Weare (2010).
%         if ~isfield(uqdata.optimization,'config')
%             config.nchain = 12;
%             config.nmax   = 10000;
%             uqdata.optimization.config = config;
%         end
%         uqdata.optimization.result = RunPGW10(uqdata,model);
%     case 'PTMCMC'
%         % parallel-temperature MCMC
%         if ~isfield(uqdata.optimization,'config')
%             config.ntemp  = 10;
%             config.nchain = 12;
%             config.nmax   = 10000;
%             uqdata.optimization.config = config;
%         end
%         uqdata.optimization.result = RunPTMCMC(uqdata,model);
%     case 'MH'
%         % Metropolis-Hastings
%         if ~isfield(uqdata.optimization,'config')
%             config.nChain    = 12;
%             config.nChainMax = 10000;
%             config.converge  = 1.001;
%             uqdata.optimization.config = config;
%         end
%         uqdata.optimization.result = RunMH(uqdata,model);
%     case 'AM'
%         % Adaptive-Metropolis
%         if ~isfield(uqdata.optimization,'config')
%             config.nChain    = 12;
%             config.nChainMax = 10000;
%             config.converge  = 1.001;
%             uqdata.optimization.config = config;
%         end
%         uqdata.optimization.result = RunAM(uqdata,model);
%     case 'MHVP'
%         % Metropolis-Hastings with various proposal
%         if ~isfield(uqdata.optimization,'config')
%             config.nChain    = 12;
%             config.nChainMax = 10000;
%             config.converge  = 1.001;
%             uqdata.optimization.config = config;
%         end
%         uqdata.optimization.result = RunMHVP(uqdata,model);
%     case 'DRAM'
%         % Delayed Rejection Adaptive-Metropolis
%         if ~isfield(uqdata.optimization,'config')
%             config.nChain    = 12;
%             config.nChainMax = 10000;
%             config.converge  = 1.001;
%             uqdata.optimization.config = config;
%         end
%         uqdata.optimization.result = RunDRAM(uqdata,model);
%     case 'GEM-SMC'
%         % Delayed Rejection Adaptive-Metropolis
%         if ~isfield(uqdata.optimization,'config')
%             config.N = 1000;
%             config.S = 1000;
%             uqdata.optimization.config = config;
%         end
%         uqdata.optimization.result = RunGEMSMC(uqdata,model);
%     case 'MT-DREAM(ZS)'
%         % Multi-Try - DiffeRential Evolution Adaptive Metropolis 
%         if ~isfield(uqdata.optimization,'config')
%             config.nChain    = 3;
%             config.nChainMax = 10000;
%             config.nTry  = 5;
%             uqdata.optimization.config = config;
%         end
%         uqdata.optimization.result = RunMTDREAMZS(uqdata,model);
%     case 'DREAM'
%         % DiffeRential Evolution Adaptive Metropolis 
%         if ~isfield(uqdata.optimization,'config')
%             config.nChain    = 50;
%             config.nChainMax = 10000;
%             uqdata.optimization.config = config;
%         end
%         uqdata.optimization.result = RunDREAM(uqdata,model);
%     case 'MC-ASMO'
%         % Markov Chain Monte Carlo - Adaptive Surrogate Model Optimization
%         if ~isfield(uqdata.optimization,'config')
%             config.niter     = 10;
%             config.nhist     = 100;
%             config.nChain    = 12;
%             config.nChainMax = 10000;
%             config.converge  = 1.001;
%             config.resamle   = 'tic-toc';
%             config.resolution= 1e-4;
%             uqdata.optimization.config = config;
%         end
%         uqdata.optimization.result = RunMCASMO(uqdata,model);
end
    
end
