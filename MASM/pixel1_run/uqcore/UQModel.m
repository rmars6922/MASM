classdef UQModel < handle
    % the base class UQModel for simple test problems
    properties
        modelName   % name of model, call the model with function handle
        modelPath   % path of model's exe and data files
        nInput      % No. of input parameters
        nOutput     % No. of output objectives
        inputNames  % name of input parameters
        outputNames % name of output objectives
        xub         % upper bound of input parameters
        xlb         % lower bound of input parameters
        xdf         % default value of input parameters
        xrg         % range of input parameters
        parallel    % is the model can be run parallely?
    end
    
    methods
        function obj = UQModel(mat)
            % constructor of UQModel
            obj.modelName   = mat.modelName;
            obj.modelPath   = mat.modelPath;
            obj.nInput      = mat.nInput;
            obj.nOutput     = mat.nOutput;
            obj.inputNames  = mat.inputNames;
            obj.outputNames = mat.outputNames;
            obj.xub         = mat.xub;
            obj.xlb         = mat.xlb;
            obj.xdf         = mat.xdf;
            obj.xrg         = mat.xub - mat.xlb;
            obj.parallel    = mat.parallel;
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
            % run the model with original input parameters
            [T,~] = size(x);
            y     = zeros(T, obj.nOutput);
            
            if obj.parallel
                Name = obj.modelName;
                parfor i = 1:T
                    y(i,:) = feval(Name, x(i,:));
                end
            else
                for i = 1:T
                    y(i,:) = feval(obj.modelName, x(i,:));
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