function plotMOOref(uqdata,model)
% plot the result of Multi-objective optimization with reference point

% scatterplot of optimal input parameters
x = uqdata.optimization.result.bestx;
figure;
myPlotMatrix(x,model.xubS,model.xlbS,model.inputNames(model.inputidx));
title('Scatterplot of optimal input parameters');

% scatterplot of optimal output functions
y  = uqdata.optimization.result.y;
yb = uqdata.optimization.result.bestf;
yr = uqdata.optimization.config.ref;
figure;
if size(y,2) > 2
    myPlotMatrix3(y,yb,yr,max(y),min(y),model.outputNames);
else
    plot(y(:,1),y(:,2),'b.'); hold on;
    plot(yb(:,1),yb(:,2),'r.','MarkerSize',10); hold on;
    plot(yr(:,1),yr(:,2),'g.','MarkerSize',20);
    line([min(y(:,1)),max(y(:,1))],[1,1]*yr(2),'Color',[0 1 0],'LineStyle','-','LineWidth',1); hold on;
    line([1,1]*yr(1),[min(y(:,2)),max(y(:,2))],'Color',[0 1 0],'LineStyle','-','LineWidth',1); hold off;
end
title('Scatterplot of optimal output functions');
end

