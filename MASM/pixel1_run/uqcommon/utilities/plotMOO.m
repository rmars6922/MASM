function plotMOO(uqdata,model)
% plot the result of Multi-objective optimization

% scatterplot of optimal input parameters
x = uqdata.optimization.result.bestx;
figure;
% myPlotMatrix(x,ones(1,model.nInputS),zeros(1,model.nInputS),model.inputNames(model.inputidx));
myPlotMatrix(x,model.xubS,model.xlbS,model.inputNames(model.inputidx));
title('Scatterplot of optimal input parameters');

% scatterplot of optimal output functions
y  = uqdata.optimization.result.y;
yb = uqdata.optimization.result.bestf;
figure;
if size(y,2) > 2
    myPlotMatrix2(y,yb,max(y),min(y),model.outputNames);
else
    plot(y(:,1),y(:,2),'b.'); hold on;
    plot(yb(:,1),yb(:,2),'ro');
end
title('Scatterplot of optimal output functions');
end

