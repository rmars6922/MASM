function plotSOO(uqdata,model)
% plot the result of Single-objective optimization

figure;
plot(uqdata.optimization.result.icall_array,uqdata.optimization.result.bestf_array,'o-');
xlabel('Number of model runs');
ylabel('Output');
title('Optimization procedure');

figure;
plot(1:model.nInputS,model.tounit(uqdata.optimization.result.bestx),'ro-');
xlabel('parameter name'); ylabel('parameter value');
set(gca,'XTick',1:model.nInputS);
set(gca,'XTickLabel',{model.inputNames{model.inputidx}});
axis([1,model.nInputS,0,1]);
title('Optimal parameters');

end

