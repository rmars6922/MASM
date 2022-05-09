% main program of UQML
function uqdata = UQ(JSONname)
    % load config file, or previous data file
    uqdata = readJSONfile(JSONname);
    %model = UQModel(readJSONfile(uqdata.modelJSON));
    modelmat = readJSONfile(uqdata.modelJSON);
    
    if isfield(uqdata,'savediary')
        modelmat.savediary = uqdata.savediary;
    else
        modelmat.savediary = 1;
    end
    model = DynamicModel(modelmat);
    
    if ~isfield(uqdata,'doplot'); uqdata.doplot = 0; end;
    if ~isfield(uqdata,'savejson'); uqdata.savejson = 0; end;
    if ~isfield(uqdata,'savemat'); uqdata.savemat = 1; end;
    
    if model.parallel; parpool; end;
    
    if isfield(uqdata,'sampling')
        if ~isfield(uqdata.sampling,'result')
            uqdata = RunSampling(uqdata,model);
            if uqdata.doplot; plotSampling(uqdata,model); end;
        end
    end
       disp('end of sampling')
    % sensitivity analysis
    if isfield(uqdata,'sensitivity') 
        if ~isfield(uqdata.sensitivity,'result')
            uqdata = RunSensitivity(uqdata,model);
            if uqdata.doplot; plotSA(uqdata,model); end;
        end
    end   
    
    % optimization
    if isfield(uqdata,'optimization')
        if ~isfield(uqdata.optimization,'result')
            uqdata = RunOptimization(uqdata,model);
            if uqdata.doplot; plotOpt(uqdata,model); end;
        end
    end
    
    %t = toc; disp(['Running time: ',num2str(t)]);
    
    % save result
    if uqdata.savejson
        writeJSONfile(uqdata, [model.modelPath,'/uqdata_',...
            num2str(fix(clock),'%04d_%02d_%02d_%02d_%02d_%02d'),'.json']);
    end
    if uqdata.savemat
        save([model.modelPath,'/uqdata_',...
            num2str(fix(clock),'%04d_%02d_%02d_%02d_%02d_%02d'),'.mat']);
    end
    
    if model.parallel; delete(gcp); end;
    
end
