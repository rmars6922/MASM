classdef SurrogateModel < ScreenedModel
    % for statistical surrogate models
    properties
        smtype % type of surrogate model = uqdata.surrogate.smtype
        config % configration of surrogate model
        xt % input paras, training set (xt ~ [0,1])
        yt % output objs, training set (yt are weighted obj for Multi-Obj)
        sm % trained surrogate models
        % for multiple objectives, sm can be a cell array
    end
    
    methods
        function obj = SurrogateModel(mat, xt, yt)
            % constructor of SurrogateModel
            obj = obj@ScreenedModel(mat);
            obj.smtype = mat.smtype;
            obj.xt     = xt;
            obj.yt     = yt;
            
            % train surrogate model
            
            % check the size of training set
            [Tx,dx] = size(xt);
            [Ty,dy] = size(yt);
            if dx ~= obj.nInputS
                error('ERROR: the dimension of xt and nInputS missmatch!');
            elseif dy ~= obj.nOutputS
                error('ERROR: the dimension of yt and nOutputS missmatch!');
            elseif Tx ~= Ty
                error('ERROR: the dimension of xt and yt missmatch!');
            end
            
            switch obj.smtype
                case 'MARS'
                    % Multivariate Adaptive Regression Splines
                    % use ARESLab
                    if ~isfield(mat,'config')
                        obj.config = aresparams(71, [], [], [], [], 3);
                    else
                        obj.config = mat.config;
                    end
                    for i = 1:obj.nOutputS
                        obj.sm{i} = aresbuild(xt,yt(:,i),obj.config);
                    end
                case 'GPR'
                    % Gaussian Processes Regression
                    % use GPtools
                    if ~isfield(mat,'config')
                        obj.config.CovFunc = 'CovMatern5';
                        obj.config.hypini  = [1,1];
                        obj.config.noise   = 0.001;
                        obj.config.mean    = 0;
                    else
                        obj.config = mat.config;
                    end
                    for i = 1:obj.nOutputS
                        GPmodel = GPtrain(xt,yt(:,i),obj.config.CovFunc,...
                            obj.config.hypini,obj.config.noise,obj.config.mean);
                        GPmodel = GPopthyp(GPmodel);
                        obj.sm{i} = GPmodel;
                    end
                case 'RF'
                    % Random Forests
                    for i = 1:obj.nOutputS
                        obj.sm{i} = regRF_train(xt, yt(:,i));
                    end
                case 'SVM'
                    % Support Vector Machine
                    if ~isfield(mat,'config')
                        obj.config.c = 500;
                        obj.config.g = 0.05;
                        obj.config.p = 0.001;
                    else
                        obj.config = mat.config;
                    end
                    optionstr = ['-s 3 -t 2 -c ',num2str(obj.config.c),...
                        ' -g ',num2str(obj.config.g),...
                        ' -p ',num2str(obj.config.p)];
                    for i = 1:obj.nOutputS
                        obj.sm{i} = svmtrain(yt(:,i), xt, optionstr);
                    end
                case 'ANN'
                    % Artificial Neural Network
                    for i = 1:obj.nOutputS
                        net = feedforwardnet;
                        net = configure(net,xt',yt(:,i)');
                        net.trainParam.showWindow = 0;
                        [net,~] = train(net,xt',yt(:,i)');
                        obj.sm{i} = net;
                    end
                case 'SPGP'
                    % Sparse Gaussian Processes using Pseudo-inputs
                    if ~isfield(mat,'config')
                        obj.config.niter   = 200;
                        obj.config.npseudo = 100;
                    else
                        obj.config = mat.config;
                    end
                    for i = 1:obj.nOutputS                     
                        GPmodel = spgp_train(xt,yt(:,i),obj.config.niter,...
                            obj.config.npseudo);
                        obj.sm{i} = GPmodel;
                    end    
                otherwise
                    disp('ERROR: undefined surrogate model!');
            end
        end
        
        function y = run(obj, x)
            % run the model with original input parameters
            xu = tounit(obj, x);
            y  = rununit(obj, xu);
        end
        
        function y = rununit(obj, xu)
            % run the model with normalized parameters (x has been normalized to [0,1])
            [T,ndim] = size(xu);
            if ndim ~= obj.nInputS
                error('ERROR: the dimension of input is wrong!')
            end
            
            y  = zeros(T, obj.nOutputS); % returned outputs
            
            pcall  = 1:T;
            if obj.parallel
                parfor i = 1:T
                    y(i,:) = ModelEval(obj, xu(i,:), pcall(i));
                end
            else
                y = ModelEval(obj, xu, pcall);
            end
        end
        
        function y = ModelEval(obj, xu, pcall_array)
            % model caller for surrogate model
            y = zeros(length(pcall_array),obj.nOutputS);
            for i = 1:obj.nOutputS
                switch obj.smtype
                    case 'MARS'
                        y(:,i) = arespredict(obj.sm{i}, xu);
                    case 'GPR'
                        y(:,i) = GPpredict(obj.sm{i},xu);
                    case 'RF'
                        y(:,i) = regRF_predict(xu,obj.sm{i});
                    case 'SVM'
                        y(:,i) = svmpredict(y(:,i), xu, obj.sm{i});
                    case 'ANN'
                        y(:,i) = sim(obj.sm{i},xu');
                    case 'SPGP'
                        y(:,i) = spgp_predict(obj.sm{i},xu);
                end
            end
        end
        
        function reinforcement(obj,xtr,ytr)
            % reinforcement learning
            % add new data to the trained surrogate model
            obj.xt = [obj.xt; xtr];
            obj.yt = [obj.yt; ytr];
            switch obj.smtype
                case 'MARS'
                    % Multivariate Adaptive Regression Splines
                    % use ARESLab
                    for i = 1:obj.nOutputS
                        obj.sm{i} = aresbuild(obj.xt,obj.yt(:,i),obj.config);
                    end
                case 'GPR'
                    % Gaussian Processes Regression
                    % use GPtools
                    for i = 1:obj.nOutputS
                        obj.sm{i} = GPtrain_r(xtr,ytr(:,i),obj.sm{i});
                    end
                case 'RF'
                    % Random Forests
                    for i = 1:obj.nOutputS
                        obj.sm{i} = regRF_train(obj.xt, obj.yt(:,i));
                    end
                case 'SVM'
                    % Support Vector Machine
                    optionstr = ['-s 3 -t 2 -c ',num2str(obj.config.c),...
                        ' -g ',num2str(obj.config.g),...
                        ' -p ',num2str(obj.config.p)];
                    for i = 1:obj.nOutputS
                        obj.sm{i} = svmtrain(obj.yt(:,i), obj.xt, optionstr);
                    end
                case 'ANN'
                    % Artificial Neural Network
                    for i = 1:obj.nOutputS
                        net = feedforwardnet;
                        net = configure(net,obj.xt',obj.yt(:,i)');
                        net.trainParam.showWindow = 0;
                        [net,~] = train(net,obj.xt',obj.yt(:,i)');
                        obj.sm{i} = net;
                    end
                case 'SPGP'
                    % Sparse Gaussian Processes using Pseudo-inputs
                    for i = 1:obj.nOutputS                     
                        GPmodel = spgp_train(obj.xt,obj.yt(:,i),obj.config.niter,...
                            obj.config.npseudo);
                        obj.sm{i} = GPmodel;
                    end        
                otherwise
                    disp('ERROR: undefined surrogate model!');
            end
        end
        
    end
    
end