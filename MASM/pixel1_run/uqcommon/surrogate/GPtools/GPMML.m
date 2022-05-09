classdef GPMML < handle
    % Maximum Marginal Likelihood of Gaussian Processes Regression
    properties
        nInput  % No. of input parameters
        xub     % upper bound of input parameters
        xlb     % lower bound of input parameters
        xrg     % range of input parameters
        xubS    % upper bound of screened para (for opt)
        xlbS    % lower bound of screened para (for opt)
        xrgS    % range of screened para (for opt)
        sm      % trained surrogate models
        parallel % is the model can be run parallely?
    end
    
    methods
        function obj = GPMML(mat)
            % constructor of GPMML
            obj.nInput      = mat.nInput;
            obj.xub         = mat.xub;
            obj.xlb         = mat.xlb;
            obj.xrg         = mat.xub - mat.xlb;
            obj.sm          = mat.sm;
            obj.parallel    = 0;
            
            obj.xubS        = obj.xub;
            obj.xlbS        = obj.xlb;
            obj.xrgS        = obj.xrg;
        end
        
        function x = fromunit(obj, xu)
            % transfer sample ranges from [0,1]
            [T,~] = size(xu);
            x     = zeros(T,obj.nInput);
            for i = 1:T
                x(i,:) = obj.xlb + xu(i,:).* obj.xrg;
            end
        end
        
        function xu = tounit(obj, x)
            % transfer sample ranges to [0,1]
            [T,~] = size(x);
            xu    = zeros(T,obj.nInput);
            for i = 1:T
                xu(i,:) = (x(i,:) - obj.xlb)./obj.xrg;
            end
        end
        
        function y = run(obj, x)
            [T,~] = size(x);
            y     = zeros(T, 1);
            
            hypexp = exp(x);
            if obj.parallel
                parfor i = 1:T
                    gpm = GPtrain(obj.sm.X,obj.sm.y,obj.sm.CovFunc,...
                        hypexp(i,:),obj.sm.noise,obj.sm.mean);
                    y(i) = -gpm.m;
                end
            else
                for i = 1:T
                    gpm = GPtrain(obj.sm.X,obj.sm.y,obj.sm.CovFunc,...
                        hypexp(i,:),obj.sm.noise,obj.sm.mean);
                    y(i) = -gpm.m;
                end
            end
        end
        
        function y = rununit(obj, xu)
            % run the model with normalized parameters (x has been normalized to [0,1])
            x = fromunit(obj, xu);
            y = run(obj, x);
        end
        
    end
end