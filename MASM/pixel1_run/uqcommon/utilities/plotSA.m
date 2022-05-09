function plotSA(uqdata,model)
% plot the result of sensitivity analysis

switch uqdata.sensitivity.method
    case 'DeltaTest'
        % Delta Test
        for i = 1:model.nOutput
            figure;
            bar(uqdata.sensitivity.result.delta(i,:)); xlabel('Parameter'); ylabel('Delta score');
            title(['Delta score of ',model.outputNames{i}]);
        end
    case 'Sum_Of_Trees'
        % Sum of Trees
        for i = 1:model.nOutput
            figure;
            bar(uqdata.sensitivity.result.score(i,:)); xlabel('Parameter'); ylabel('SOT score');
            title(['SOT score of ',model.outputNames{i}]);
        end
    case 'MARS'
        % Multivariate Adaptive Regression Splines
        % use ARESLab
        for i = 1:model.nOutput
            anova = getfield(uqdata.sensitivity.result,model.outputNames{i});
            figure; bar(anova.gcv); 
            set(gca,'XTickLabel',anova.para);
            xlabel('Parameter'); ylabel('MARS GCV score');
            title(['MARS GCV score of ',model.outputNames{i}]);
        end
    case 'MOAT'
        % Morris One At a Time
        for i = 1:model.nOutput
            figure;
            plotMOAT(uqdata,i);
            title(['Morris-One-At-a-Time result of ',model.outputNames{i}]);
        end
    case 'SobolSAboot'
        % Sobol' sensitivity analysis with bootstrap
        for i = 1:model.nOutput
            result = getfield(uqdata.sensitivity.result,model.outputNames{i});
            figure; boxplot(result.Sb);xlabel('Parameter'); ylabel('Main Effect');
            title(['Main effect of ',model.outputNames{i}]);
            figure; boxplot(result.STb);xlabel('Parameter'); ylabel('Total Effect');
            title(['Total effect of ',model.outputNames{i}]);
            figure; bar3(result.STij);zlabel('Interaction');
            title(['Interaction of ',model.outputNames{i}]);
        end
    case 'RSMSobol'
        % bootstrapped Sobol' sensitivity analysis with surrogate model
        for i = 1:model.nOutput
            result = getfield(uqdata.sensitivity.result,model.outputNames{i});
            figure; boxplot(result.Sb);xlabel('Parameter'); ylabel('Main Effect');
            title(['Main effect of ',model.outputNames{i}]);
            figure; boxplot(result.STb);xlabel('Parameter'); ylabel('Total Effect');
            title(['Total effect of ',model.outputNames{i}]);
            figure; bar3(result.STij);zlabel('Interaction');
            title(['Interaction of ',model.outputNames{i}]);
        end     
    otherwise
        % by default use SOT
        % Sum of Trees
        for i = 1:model.nOutput
            figure;
            bar(uqdata.sensitivity.result.score(i,:)); xlabel('Parameter'); ylabel('SOT score');
            title(['SOT score of ',model.outputNames{i}]);
        end
end

end

