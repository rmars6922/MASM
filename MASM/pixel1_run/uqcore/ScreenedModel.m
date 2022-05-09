classdef ScreenedModel < UQModel
    % for large complex dynamic models with screened parameters
    properties
        outputidx % Index of output obj that returned by 'run' method.
                  % Actually all of the outputs are computed and stored in
                  % a log file, but only the required one is retured.
                  % For multi-obj optimization, outputidx <= 0, it can also 
                  % identify the weighting function.
        screened  % Use the screened parameters (1) or not (0)
                  % Must also provide 'outputFlags'
        outputFlags   % screened parameter indeces of each outputs
        outputWeights % weighting factors of each output objectives
        inputidx  % the indeces of input parameters (if screened)
        nInputS   % the dimension of input parameters (if screened)
        nOutputS  % the dimension of output objectives
        xlbS      % lower bound (if screened)
        xubS      % upper bound (if screened)
        xrgS      % range (if screened)
        icall     % total number of model runs
    end
    
    methods
        function obj = ScreenedModel(mat)
            % constructor of ScreenedModel
            
            obj = obj@UQModel(mat);
            
            if ~isfield(mat,'outputidx')
                % if outputidx not assigned, return all objectives
                obj.outputidx = 0;
            else
                obj.outputidx = mat.outputidx;
            end
            
            if ~isfield(mat,'screened')
                obj.screened = 0;
            else
                obj.screened = mat.screened;
            end
            
            if ~isfield(mat,'outputFlags')
                for i = 1:obj.nOutput
                    obj.outputFlags = setfield(obj.outputFlags,obj.outputNames{i},1:obj.nInput);
                    %obj.outputFlags{i} = 1:obj.nInput;
                end
            else
                obj.outputFlags = mat.outputFlags;
            end
            
            if ~isfield(mat,'outputWeights')
                obj.outputWeights = ones(1,obj.nOutput);
            else
                obj.outputWeights = mat.outputWeights;
            end
            
            % the indeces of input parameters (if screened)
            obj.inputidx = [];
            if obj.screened
                if obj.outputidx <= 0
                    for i = 1:obj.nInput
                        tick = 0;
                        for j = 1:obj.nOutput
                            if ~isempty( find(getfield(obj.outputFlags,obj.outputNames{j}) == i, 1) )
                                tick = tick + 1;
                            end
                        end
                        if tick > 0
                            obj.inputidx = [obj.inputidx, i];
                        end
                    end
                else
                    obj.inputidx = getfield(obj.outputFlags,obj.outputNames{obj.outputidx});
                end
            else
                obj.inputidx = 1:obj.nInput;
            end
            
            if obj.outputidx == 0
                % return all objectives
                obj.nOutputS = obj.nOutput;
            else
                % return the assigned objective
                obj.nOutputS = 1;
            end
            obj.nInputS = length(obj.inputidx);
            obj.xlbS    = obj.xlb(obj.inputidx);
            obj.xubS    = obj.xub(obj.inputidx);
            obj.xrgS    = obj.xrg(obj.inputidx);
            obj.icall   = 0;
        end
        
        function x = fromunit(obj, xu)
            % transfer sample ranges from [0,1]
            % if screened = 1, both xu and x only contain screened paras
            [T,ndim] = size(xu);
            if ndim ~= obj.nInputS
                error('ERROR: the dimension of input is wrong!')
            end
            x = zeros(T,obj.nInputS);
            for i = 1:T
                x(i,:) = obj.xlbS + xu(i,:).* obj.xrgS;
            end
        end
        
        function xu = tounit(obj, x)
            % transfer sample ranges to [0,1]
            % if screened = 1, both xu and x only contain screened paras
            [T,ndim] = size(x);
            if ndim ~= obj.nInputS
                error('ERROR: the dimension of input is wrong!')
            end
            xu = zeros(T,obj.nInputS);
            for i = 1:T
                xu(i,:) = (x(i,:) - obj.xlbS)./obj.xrgS;
            end
        end
        
        function xf = xextend(obj,x)
            % extent the screened para to the original full para list
            [T,~] = size(x);
            xf = zeros(T, obj.nInput); 
            for i = 1:T
                xf(i,:) = obj.xdf;
                xf(i,obj.inputidx) = x(i,:);
            end
        end
        
        function [y, f] = run(obj, x)
            % run the model with original input parameters
            [T,ndim] = size(x);
            if ndim ~= obj.nInputS
                error('ERROR: the dimension of input is wrong!')
            end
            
            f  = zeros(T, obj.nOutput);  % raw outputs
            y  = zeros(T, obj.nOutputS); % returned outputs
            xf = zeros(T, obj.nInput);   % full input paras
            
            for i = 1:T
%                xf(i,:) = obj.xdf;
                xf(i,obj.inputidx+1) = x(i,:);
                xf(i,1) = i;
            end
            
            pcall = obj.icall;
            if obj.parallel
                parfor i = 1:T
                    f(i,:) = ModelEval(obj, xf(i,:), pcall+i);
                end
            else
                for i = 1:T
                    f(i,:) = ModelEval(obj, xf(i,:), pcall+i);
                end
            end
            
            if obj.outputidx == 0
                % return all objectives
                y = f;
            elseif obj.outputidx == -1
                % return weighting function
                for i = 1:obj.nOutput
                    y = y + obj.outputWeights(i) * f(:,i);
                end
                y = y/sum(obj.outputWeights);
            elseif obj.outputidx == -2
                % return the distance to the origin
                for i = 1:T
                    y(i) = sqrt(sum(f(i,:).^2));
                end
            else
                % return single objective
                y = f(:,obj.outputidx);
            end
            
        end
        
        function [y, f] = rununit(obj, xu)
            % run the model with normalized parameters (x has been normalized to [0,1])
            x = fromunit(obj, xu);
            [y, f] = run(obj, x);
        end
        
        function f = ModelEval(obj, xf, pcall)
            % model caller for different kinds of exe file
            f = feval(obj.modelName, xf);
            disp(['Run model ', num2str(pcall), ': ', num2str([xf,f],'%e ')]);
        end
        
    end
    
end