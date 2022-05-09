function plotSampling(uqdata,model)
% plot the distribution of sampling

x  = uqdata.sampling.result.xu;
figure;
myPlotMatrix(x,ones(1,model.nInputS),zeros(1,model.nInputS),model.inputNames(model.inputidx));
title('Scatterplot of input parameters');

end


