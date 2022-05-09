function h = plotMCMC(uqdata,model)
% plot the density of posterior probability given by MCMC

% %% use bincounting, plot in grid
% d = model.nInputS;
% h = figure;
% x = uqdata.optimization.result.xp;
% 
% if model.nInput == 2
%     name1 = model.inputNames(1); name2 = model.inputNames(2);
%     x1 = x(:,1); x2 = x(:,2);
%     plot2dpdf(x1,x2,name1,name2);
% else
%     for i = 1:d
%         for j = 1:d
%             subplot(d,d,(i-1)*d+j);
%             if i == j
%                 name = model.inputNames(i);
%                 xi = x(:,i);
%                 plot1dpdf(xi,name);
%             else
%                 name1 = model.inputNames(j); name2 = model.inputNames(i);
%                 x1 = x(:,j); x2 = x(:,i);
%                 plot2dpdf(x1,x2,name1,name2);
%             end
%         end
%     end
% end
% 
% end
% 
% function plot2dpdf(x1,x2,name1,name2)
%     [~,~,f,~,~] = bin2d([x1,x2]);
%     colormap jet;
%     contour(f);
%     xlabel(name1);
%     ylabel(name2);
% end
% 
% function plot1dpdf(x,name)
%     [t, f, ~] = bin1d(x);
%     plot(t,f);
%     xlabel(name);
%     ylabel('PDF');
% end


%% use kernelpdf, plot in grid
% nbins = 101; % number of bins
% d = model.nInputS;
% h = figure;
% x = uqdata.optimization.result.xp;
% 
% if model.nInput == 2
%     lb1 = model.xlbS(1); lb2 = model.xlbS(2);
%     ub1 = model.xubS(1); ub2 = model.xubS(2);
%     n1 = nbins; n2 = nbins;
%     name1 = model.inputNames(1); name2 = model.inputNames(2);
%     x1 = x(:,1); x2 = x(:,2);
%     plot2dpdf(lb1,lb2,ub1,ub2,n1,n2,x1,x2,name1,name2);
% else
%     for i = 1:d
%         for j = 1:d
%             subplot(d,d,(i-1)*d+j);
%             if i == j
%                 lb = model.xlbS(i);
%                 ub = model.xubS(i); 
%                 n = nbins;
%                 name = model.inputNames(i);
%                 xi = x(:,i);
%                 plot1dpdf(lb,ub,n,xi,name);
%             else
%                 lb1 = model.xlbS(j); lb2 = model.xlbS(i);
%                 ub1 = model.xubS(j); ub2 = model.xubS(i);
%                 n1 = nbins; n2 = nbins;
%                 name1 = model.inputNames(j); name2 = model.inputNames(i);
%                 x1 = x(:,j); x2 = x(:,i);
%                 plot2dpdf(lb1,lb2,ub1,ub2,n1,n2,x1,x2,name1,name2);
%             end
%         end
%     end
% end
% 
% end
% 
% function plot2dpdf(lb1,lb2,ub1,ub2,n1,n2,x1,x2,name1,name2)
%     [p1, p2] = meshgrid(linspace(lb1,ub1,n1),linspace(lb2,ub2,n2));
%     p = [reshape(p1,[],1),reshape(p2,[],1)];
%     f = kernelpdf([x1,x2], p);
%     f = reshape(f,n2,n1);
%     colormap jet;
%     contour(f);
%     xlabel(name1);
%     ylabel(name2);
% end
% 
% function plot1dpdf(lb,ub,n,x,name)
%     p = linspace(lb,ub,n)';
%     f = kernelpdf(x,p);
%     plot(p,f);
%     xlabel(name);
%     ylabel('PDF');
% end

%% use kernelpdf, plot smoothly
x = uqdata.optimization.result.xp;
inputNames = model.inputNames;

[T,d] = size(x);
h = figure;
a = 25;
c = linspace(1,10,T);
colormap jet;

if d == 2
    x1 = x(:,1); x2 = x(:,2);
    f = kernelpdf(x);
    [~,idx] = sort(f);
    x1 = x1(idx); x2 = x2(idx);
    scatter(x1,x2,a,c,'filled');
    xlabel(inputNames(1));
    ylabel(inputNames(2));
else
    for i = 1:d
        for j = 1:d
            if i == j
                xtmp = x(:,i);
                f = kernelpdf(xtmp);
                [xtmp,idx] = sort(xtmp);
                f = f(idx);
                subplot(d,d,(i-1)*d+j);
                plot(xtmp,f);
                xlabel(inputNames(i));
                xlabel('Probability Density Function');
            elseif i > j
                x1 = x(:,i); x2 = x(:,j);
                f = kernelpdf([x1,x2]);
                [~,idx] = sort(f);
                x1 = x1(idx); x2 = x2(idx);
                subplot(d,d,(i-1)*d+j);
                scatter(x1,x2,a,c,'filled');
                xlabel(inputNames(i));
                ylabel(inputNames(j));
            end
        end
    end
end
