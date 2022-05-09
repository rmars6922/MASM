function uqdata = RunSampling(uqdata,model)

switch uqdata.sampling.method
    case 'userdef'
        % user defined samples stored in config file
        x  = uqdata.sampling.config.x;
        xu = model.tounit(x);
    case 'MC'
        % Monte Carlo
        if ~isfield(uqdata.sampling,'config')
            config.sampleSize = model.nInputS * 10;
            uqdata.sampling.config = config;
        else
            config = uqdata.sampling.config;
        end
        xu = MonteCarloDesign(config.sampleSize, model.nInputS);
    case 'LH'
        % Latin Hypercube
        if ~isfield(uqdata.sampling,'config')
            config.sampleSize = model.nInputS * 10;
            config.maxiter = 5;
            uqdata.sampling.config = config;
        else
            config = uqdata.sampling.config;
        end
        xu = LatinHypercubeDesign(config.sampleSize, ...
            model.nInputS, config.maxiter);
    case 'SLH'
        % Symmetric Latin Hypercube
        if ~isfield(uqdata.sampling,'config')
            config.sampleSize = model.nInputS * 10;
            config.maxiter = 5;
            uqdata.sampling.config = config;
        else
            config = uqdata.sampling.config;
        end
        xu = SymmetricLatinHypercubeDesign(config.sampleSize, ...
            model.nInputS, config.maxiter);
    case 'GLP'
        % Good Lattice Point
        if ~isfield(uqdata.sampling,'config')
            config.sampleSize = model.nInputS * 10;
            config.maxiter = 5;
            uqdata.sampling.config = config;
        else
            config = uqdata.sampling.config;
        end
        xu = GoodLatticePointsDesign(config.sampleSize, ...
            model.nInputS, config.maxiter);
    case 'sobol'
        % Sobol quasi-random point set with random linear scramble
        if ~isfield(uqdata.sampling,'config')
            config.sampleSize = model.nInputS * 10;
            config.skip = 0;
            config.leap = 0;
            config.scramble = false;
            uqdata.sampling.config = config;
        else
            config = uqdata.sampling.config;
        end
        p = sobolset(model.nInputS,...
            'Skip',config.skip,...
            'Leap',config.leap);
        if config.scramble == true
            p = scramble(p,'MatousekAffineOwen');
        end
        xu = net(p,config.sampleSize);
    case 'halton'
        %  Halton quasi-random point set with everse-radix scrambling
        if ~isfield(uqdata.sampling,'config')
            config.sampleSize = model.nInputS * 10;
            config.skip = 0;
            config.leap = 0;
            config.scramble = false;
            uqdata.sampling.config = config;
        else
            config = uqdata.sampling.config;
        end
        p = haltonset(model.nInputS,...
            'Skip',config.skip,...
            'Leap',config.leap);
        if config.scramble == true
            p = scramble(p,'RR2');
        end
        xu = net(p,config.sampleSize);
    case 'SobolSAboot'
        % sampling for sobol' quantitative sensitivity analysis with bootstrap
        if ~isfield(uqdata.sampling,'config')
            config.replications = 5000;
            uqdata.sampling.config = config;
        else
            config = uqdata.sampling.config;
        end
%         xu = sobolSAbootsampling(config.replications,model.nInputS);
        xu = SaltelliSampling(config.replications,model.nInputS);
%     case 'MOAT'
%         % sampling for Morris One-At-a-Time
%         if ~isfield(uqdata.sampling,'config')
%             config.N = 100;
%             config.p = 4;
%             config.r = 8;
%             uqdata.sampling.config = config;
%         else
%             config = uqdata.sampling.config;
%         end
%         [OptMatrix, OptOutVec] = Optimized_Groups(model.nInputS,...
%             config.N,config.p,config.r);
% %         uqdata.sampling.result.OptMatrix = OptMatrix;
% %         uqdata.sampling.result.OptOutVec = OptOutVec;
%         xu = OptMatrix;
    case 'MOAT'
        % sampling for Effective Morris One-At-a-Time
        if ~isfield(uqdata.sampling,'config')
            config.p = 4;
            config.r = 8;
            uqdata.sampling.config = config;
        else
            config = uqdata.sampling.config;
        end
        xu = MOATsampling(config.r,config.p,model.nInputS);
    otherwise
        % by default use SLH
        config.sampleSize = model.nInputS * 10;
        config.maxiter = 5;
        uqdata.sampling.config = config;
        xu = SymmetricLatinHypercubeDesign(config.sampleSize, ...
            model.nInputS, config.maxiter);
end

[y,f] = model.rununit(xu);

uqdata.sampling.result.xu = xu; % the screened input para transed to [0,1]
uqdata.sampling.result.x  = model.xextend(model.fromunit(xu)); % the full inputpara
uqdata.sampling.result.f  = f;  % the full output obj
uqdata.sampling.result.y  = y;  % the assigned output obj
