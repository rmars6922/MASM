function plotOpt(uqdata,model)
% plot the result of optimization
switch uqdata.optimization.method    
    case 'GA'
        % Genetic Algorithm
        plotSOO(uqdata,model);
    case 'NSGA-II'
        % Nondominated Sorting Genetic Algorithm II
        plotMOO(uqdata,model);
    case 'WNSGA'
        % Weighted - Nondominated Sorting Genetic Algorithm II
        plotMOOref(uqdata,model);
    case 'SCE-UA'
        % Shuffled Complex Envolution
        plotSOO(uqdata,model);
    case 'MOSCEM-UA'
        % MULTI OBJECTIVE SHUFFLED COMPLEX EVOLUTION METROPOLIS 
        plotMOO(uqdata,model);
    case 'ASMO'
        % Adaptive surrogate model based optimization
        plotSOO(uqdata,model);
    case 'MO-ASMO'
        %  Multi-Objective Adaptive Surrogate Model Optimization
        plotMOO(uqdata,model);
    case 'WMO-ASMO'
        %  Weighted Multi-Objective Adaptive Surrogate Model Optimization
        plotMOOref(uqdata,model);
    case 'MH'
        % Metropolis-Hastings
        plotMCMC(uqdata,model);
    case 'AM'
        % Adaptive Metropolis
        plotMCMC(uqdata,model);
    case 'DRAM'
        % Delayed Rejection Adaptive Metropolis
        plotMCMC(uqdata,model);
    case 'ASMO-PODE'
        % Adaptive Surrogate Model based Optimization - 
        % Parameter Optimization and Distribution Estimation
        plotMCMC(uqdata,model);
end

end