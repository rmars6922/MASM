function f = ibis(x)
expcase = 1;
% pars for LAI: vmaxub,p5,p14,p15,p17,p18,p20
%   parub = [7.0e-05,0.1,0.7,0.1,500,70,365];
% 	parlb = [2.0e-5,1.0e-04,0.2,1.0e-04,100,40,200];
% 	pardf = [3.0e-05,0.06,0.48,0.09,300,60,270];

% pars for LAI+GPP: alpha3,theta3,beta3,vmaxub,p5,p14,p15,p17,p18,p20
%   parub = [0.1,0.996,0.996,7.0e-05,0.1,0.7,0.1,500,70,365];
% 	parlb = [0.05,0.6,0.6,2.0e-5,1.0e-04,0.2,1.0e-04,100,40,200];
% 	pardf = [0.06,0.97,0.99,3.0e-05,0.06,0.48,0.09,300,60,270];

% pars for GPP: alpha3,theta3,beta3,vmaxub,p5,p14,p20
%   parub = [0.1,0.996,0.996,7.0e-05,0.1,0.7,365];
% 	parlb = [0.05,0.6,0.6,2.0e-5,1.0e-04,0.2,200];
% 	pardf = [0.06,0.97,0.99,3.0e-05,0.06,0.48,270];

%   modify pars.csv
    pars = importdata('pars.csv');
    disp(x(1));
    pars(1,1) = x(2); % alpha3
    pars(2,1) = x(3); % theta3
    pars(3,1) = x(4); % beta3
    pars(16,1) = x(5); % vmaxub 
    pars(44,1) = x(6); % p5
    pars(53,1) = x(7); % p14
    pars(59,1) = x(8); % p20 
     
    csvwrite('./pars.csv',pars);  
%   run IBIS model:2001-2009 for calibration; 2010-2015/2017 for validation
    %disp('run ibis');
    cmd = 'AmeriDBF2.exe';
    system(cmd);    
%   read ptsID (parameter first line)
    parameter = importdata('parameter.txt');
    ptsID = parameter(:,1);
    LAI_model_8d_total = [];
    GPP_model_8d_total = [];
    gla_lai_total = [];
    gla_gpp_total = [];
    for i = 1:length(ptsID)
        outnum =  num2str(ptsID(i,1));
        data_model = importdata(strcat('output/',outnum,'_dd.txt'));
        LAI_model = data_model(:,4);       
        GPP_model = data_model(:,5);
        % convert daily to 8daily
        LAI_model_8d = eightd_lai(expcase,LAI_model);
        GPP_model_8d = eightd_gpp(expcase,GPP_model);
        LAI_model_8d_total = [LAI_model_8d_total;LAI_model_8d];
        GPP_model_8d_total = [GPP_model_8d_total;GPP_model_8d];
        % read GLASS product
        gla_gpp = importdata(strcat('obs_8day/',outnum,'_GPP.txt'));
        gla_lai = importdata(strcat('obs_8day/',outnum,'_LAI.txt'));
        if expcase == 1
            gla_gpp2 = [gla_gpp(:,1);gla_gpp(:,2);gla_gpp(:,3);gla_gpp(:,4);gla_gpp(:,5);gla_gpp(:,6);gla_gpp(:,7);gla_gpp(:,8);gla_gpp(:,9)];
            gla_lai2 = [gla_lai(:,1);gla_lai(:,2);gla_lai(:,3);gla_lai(:,4);gla_lai(:,5);gla_lai(:,6);gla_lai(:,7);gla_lai(:,8);gla_lai(:,9)];
        end
        if expcase == 2
            gla_gpp2 = [gla_gpp(:,10);gla_gpp(:,11);gla_gpp(:,12);gla_gpp(:,13);gla_gpp(:,14);gla_gpp(:,15)];
            gla_lai2 = [gla_lai(:,10);gla_lai(:,11);gla_lai(:,12);gla_lai(:,13);gla_lai(:,14);gla_lai(:,15);gla_lai(:,16);gla_lai(:,17)];      
        end      
        if expcase == 3
            gla_gpp2 = [gla_gpp(:,1);gla_gpp(:,2);gla_gpp(:,3);gla_gpp(:,4);gla_gpp(:,5);gla_gpp(:,6);gla_gpp(:,7);gla_gpp(:,8);gla_gpp(:,9);...
                gla_gpp(:,10);gla_gpp(:,11);gla_gpp(:,12);gla_gpp(:,13);gla_gpp(:,14);gla_gpp(:,15)];
            gla_lai2 = [gla_lai(:,1);gla_lai(:,2);gla_lai(:,3);gla_lai(:,4);gla_lai(:,5);gla_lai(:,6);gla_lai(:,7);gla_lai(:,8);gla_lai(:,9);...
                gla_lai(:,10);gla_lai(:,11);gla_lai(:,12);gla_lai(:,13);gla_lai(:,14);gla_lai(:,15);gla_lai(:,16);gla_lai(:,17)];
        end
        
        gla_gpp_total = [gla_gpp_total;gla_gpp2];
        gla_lai_total = [gla_lai_total;gla_lai2];
        % gla_laiqc = importdata(strcat('obs_8day/',outnum,'_LAIqc.txt'));               
    end
% calculate likelihood
    y_sim = GPP_model_8d_total; 
    y_obs = gla_gpp_total;    
    f_1 = (norm(y_sim-y_obs))^2;
    var1 = var(y_obs);
    f1 = f_1/var1;
   
    f = f1;
    fclose('all');  
end 
