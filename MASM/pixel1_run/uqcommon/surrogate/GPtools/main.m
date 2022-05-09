% main program of GP test
X = (-10:1:10)';
y = X.^2;

% CovFunc = 'CovSEnoisefree';
% hyp = 0.05;
% CovFunc = 'CovMatern3';
% % hyp = [0.25,0.1];
% hyp = [150,890];

CovFunc = 'CovMatern3';
hyp = [100,100];

noise = 0.001;
mean = 100;

GPmodel = GPtrain(X,y,CovFunc,hyp,noise,mean);
GPmodel = GPopthyp(GPmodel);

Xstar = (-10:0.01:10)';
[f, pv] = GPpredict(GPmodel,Xstar);
figure;
plot(X,y,'.'); hold on;
plot(Xstar,f,Xstar,f+pv,Xstar,f-pv);

%%
X2 = (11:1:20)';
y2 = X2.^2;

GPmodel = GPtrain_r(X2,y2,GPmodel);

GPmodel = GPopthyp(GPmodel);

% Xstar = (-10:0.01:20)';
Xstar = (-10000:0.01:200)';
[f,pv] = GPpredict(GPmodel,Xstar);

figure;
plot([X;X2],[y;y2],'.'); hold on;
plot(Xstar,f,Xstar,f+pv,Xstar,f-pv);
