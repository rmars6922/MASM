function h = plotMOAT1d(uqdata,model,i)
SAmeas = getfield(uqdata.sensitivity.result.SAmeas,model.outputNames{i});

for r = 1:uqdata.sampling.config.r
    AbsMuArray(:,r) = sum(abs(SAmeas(:,1:r)),2)/r;
end

h = plot(AbsMuArray');
legend(model.inputNames);

xlabel('Number of replications (r)');
ylabel('\mu*');