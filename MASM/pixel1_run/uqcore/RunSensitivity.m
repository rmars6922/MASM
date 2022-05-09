function uqdata = RunSensitivity(uqdata,model)
% Sensivitity analysis, use all the input paras and output objs
% omit the 'screened' and 'outputidx' options

% normalize the full input para to unit
xf = uqdata.sampling.result.x;
f  = uqdata.sampling.result.f;
[T,d] = size(xf);
xu = zeros(T,d);
for i = 1:T
    xu(i,:) = (xf(i,:) - model.xlb)./model.xrg;
end

switch uqdata.sensitivity.method
    case 'DeltaTest'
        % Delta Test
        for i = 1:model.nOutput
            [screen, delta] = DeltaTest(xu,f(:,i));
            uqdata.sensitivity.result.screen(i,:) = screen;
            uqdata.sensitivity.result.delta(i,:)  = delta;
        end
    case 'Sum_Of_Trees'
        % Sum of Trees
        if ~isfield(uqdata.sensitivity,'config')
            config.nboot = 100;
            uqdata.sensitivity.config = config;
        else
            config = uqdata.sensitivity.config;
        end
        for i = 1:model.nOutput
            score = Sum_Of_Trees(xu,f(:,i),config.nboot);
            uqdata.sensitivity.result.score(i,:) = score;
        end
    case 'MARS'
        % Multivariate Adaptive Regression Splines
        % use ARESLab
        if ~isfield(uqdata.sensitivity,'config')
            %m = aresparams(21, [], [], [], [], 2);
            m = aresparams();
            uqdata.sensitivity.config = m;
        else
            m = uqdata.sensitivity.config;
        end
        uqdata.sensitivity.result = [];
        for i = 1:model.nOutput
            RSTrained = aresbuild(xu,f(:,i),m);
            disp(['Sensetivity Analysis of Output No. ',num2str(i),': ',model.outputNames{i}]);
            anova = aresanova(RSTrained, xu, f(:,i));
            uqdata.sensitivity.result = ...
                setfield(uqdata.sensitivity.result,model.outputNames{i},anova);
        end
%     case 'MOAT'
%         % Morris One At a Time
%         uqdata.sensitivity.result.SAmeas = [];
%         for i = 1:model.nOutput
%             [SAmeas, OutMatrix] = Morris_Measure_Groups(...
%                 model.nInput, xu, f(:,i), uqdata.sampling.config.p);
%             uqdata.sensitivity.result.AbsMu(i,:) = OutMatrix(:,1)';
%             uqdata.sensitivity.result.StDev(i,:) = OutMatrix(:,3)';
%             uqdata.sensitivity.result.SAmeas     = ...
%                 setfield(uqdata.sensitivity.result.SAmeas,model.outputNames{i},SAmeas);
%             disp(['Sensetivity Analysis of Output No. ',num2str(i),': ',model.outputNames{i}]);
%             disp(['AbsMu: ',num2str(uqdata.sensitivity.result.AbsMu(i,:))]);
%             disp(['StDev: ',num2str(uqdata.sensitivity.result.StDev(i,:))]);
%         end
    case 'MOAT'
        % Morris One At a Time
        if ~isfield(uqdata.sensitivity,'config')
            config.nboot = 1000;
            config.alpha = 0.05;
            uqdata.sensitivity.config = config;
        end
        uqdata.sensitivity.result = RunMOAT(uqdata);
    case 'SobolSAboot'
        % Sobol' sensitivity analysis with bootstrap
%         if ~isfield(uqdata.sensitivity,'config')
%             nBoot = 1000;
%             uqdata.sensitivity.config.nBoot = nBoot;
%         else
%             nBoot = uqdata.sensitivity.config.nBoot;
%         end
%         result = sobolSAboot(uqdata.sampling.result.f, ...
%             model.nInput, model.nOutput, ...
%             uqdata.sampling.config.replications, nBoot);
%         uqdata.sensitivity.result = [];
%         for i = 1:model.nOutput
%             uqdata.sensitivity.result = ...
%                 setfield(uqdata.sensitivity.result,model.outputNames{i},result{i});
%         end
%         for i = 1:model.nOutput
%             disp(['Sensetivity Analysis of Output No. ',num2str(i),': ',model.outputNames{i}]);
%             disp(['Main Effect: ',num2str(result{i}.mb_fo)]);
%             disp(['Total Effect: ',num2str(result{i}.mb_to)]);
%         end
        if ~isfield(uqdata.sensitivity,'config')
            nBoot = 100;
            uqdata.sensitivity.config.nBoot = nBoot;
        else
            nBoot = uqdata.sensitivity.config.nBoot;
        end
        result = SaltelliSAboot(uqdata.sampling.result.f, ...
            model.nInput, model.nOutput, ...
            uqdata.sampling.config.replications, nBoot);
        uqdata.sensitivity.result = [];
        for i = 1:model.nOutput
            uqdata.sensitivity.result = ...
                setfield(uqdata.sensitivity.result,model.outputNames{i},result{i});
        end
        for i = 1:model.nOutput
            disp(['Sensetivity Analysis of Output No. ',num2str(i),': ',model.outputNames{i}]);
            disp(['Main Effect: ',num2str(result{i}.mb_S)]);
            disp(['Total Effect: ',num2str(result{i}.mb_St)]);
        end
    case 'RSMSobol'
        % bootstrapped Sobol' sensitivity analysis with surrogate model
        
        % config for SobolSAboot
        if ~isfield(uqdata.sensitivity,'config')
            uqdata.sensitivity.config.nBoot = 100;
            uqdata.sensitivity.config.replications = 5000;
            config = uqdata.sensitivity.config;
        else
            config = uqdata.sensitivity.config;
        end
        
        % config for surrogate model
        mat = readJSONfile(uqdata.modelJSON);
        mat.screened  = 0;
        mat.outputidx = 0;
        if ~isfield(uqdata,'surrogate')
            mat.smtype = 'MARS';
        elseif ~isfield(uqdata.surrogate,'method')
            mat.smtype = 'MARS';
        else
            mat.smtype = uqdata.surrogate.method;
            if isfield(uqdata.surrogate,'config')
                mat.config = uqdata.surrogate.config;
            end
        end
        rsm = SurrogateModel(mat, xu, uqdata.sampling.result.f);
        
        % run SobolSAboot with surrogate
%         xus = sobolSAbootsampling(uqdata.sensitivity.config.replications,model.nInput);
        xus = SaltelliSampling(uqdata.sensitivity.config.replications,model.nInput);
        fs  = rsm.rununit(xus);
%         result = sobolSAboot(fs, model.nInput, model.nOutput,...
%             config.replications, config.nBoot);
        result = SaltelliSAboot(fs, model.nInput, model.nOutput,...
            config.replications, config.nBoot);
        uqdata.sensitivity.result = [];
        for i = 1:model.nOutput
            uqdata.sensitivity.result = ...
                setfield(uqdata.sensitivity.result,model.outputNames{i},result{i});
        end
%         for i = 1:model.nOutput
%             disp(['Sensetivity Analysis of Output No. ',num2str(i),': ',model.outputNames{i}]);
%             disp(['Main Effect: ',num2str(result{i}.mb_fo)]);
%             disp(['Total Effect: ',num2str(result{i}.mb_to)]);
%         end
        for i = 1:model.nOutput
            disp(['Sensetivity Analysis of Output No. ',num2str(i),': ',model.outputNames{i}]);
            disp(['Main Effect: ',num2str(result{i}.mb_S)]);
            disp(['Total Effect: ',num2str(result{i}.mb_St)]);
        end
    otherwise
        % by default use MARS
        % Multivariate Adaptive Regression Splines
        % use ARESLab
        if ~isfield(uqdata.sensitivity,'config')
            %m = aresparams(21, [], [], [], [], 2);
            m = aresparams();
            uqdata.sensitivity.config = m;
        else
            m = uqdata.sensitivity.config;
        end
        uqdata.sensitivity.result = [];
        for i = 1:model.nOutput
            RSTrained = aresbuild(xu,f(:,i),m);
            disp(['Sensetivity Analysis of Output No. ',num2str(i),': ',model.outputNames{i}]);
            anova = aresanova(RSTrained, xu, f(:,i));
            uqdata.sensitivity.result = ...
                setfield(uqdata.sensitivity.result,model.outputNames{i},anova);
        end
end

