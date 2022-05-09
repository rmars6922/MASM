classdef DynamicModel < ScreenedModel
    % for large complex dynamic models
    % add model driver support for python script, and running diary log
    properties
        savediary % save diary or not (input and output of each model evaluation)
    end
    methods
        function obj = DynamicModel(mat)
            % constructor of DynamicModel
            obj = obj@ScreenedModel(mat);
            obj.savediary = mat.savediary;
            if obj.savediary
                diary([obj.modelPath,'/modelrun_',...
                    num2str(fix(clock),'%04d_%02d_%02d_%02d_%02d_%02d'),'.log']);
                diary off;
            end
        end
        
        function [y, f] = run(obj, x)
            % run the model with original input parameters
            if obj.savediary; diary on; end;
            [T,~] = size(x);
            [y, f] = run@ScreenedModel(obj, x);
            obj.icall = obj.icall + T;
            if obj.savediary; diary off; end;
        end
        
        function f = ModelEval(obj, xf, pcall)
            % model caller for different kinds of exe file
            Path   = obj.modelPath;
            Name   = obj.modelName;
            nInput = obj.nInput;
            NameCell = regexp(Name,'\.','split');
            NameExt  = NameCell{end};
            if strcmp(NameExt,'py')
                % python driver
                pyInput = [Path,'/','pyInput.',num2str(pcall)];
                pyOutput = [Path,'/','pyOutput.',num2str(pcall)];
                fid1 = fopen(pyInput,'w+');
                fprintf(fid1,'%d\n',nInput);
                for i = 1:nInput
                    fprintf(fid1,'%20e\n',xf(i));
                end
                fclose(fid1);

                [status,~] = system(['python ',Path,'/',Name,' ',pyInput,' ',pyOutput]);
                if status ~= 0;
                    disp(['Run model: ',num2str(pcall), ' ERROR']);
                end

                fid2 = fopen(pyOutput,'r');
                f = fscanf(fid2,'%e\n');
                f = f';
                fclose(fid2);
                delete(pyInput); delete(pyOutput);
            else
                % m driver
                f = feval(Name, xf); % into ibis.m
            end
%             if obj.savediary
%                 disp(['Run model ', num2str(pcall), ': ', num2str([xf,f],'%e ')]);
%             end
        end
        
    end
    
end
