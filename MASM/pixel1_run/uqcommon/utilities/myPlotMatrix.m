function h = myPlotMatrix(x,UB,LB,paraname)
% a revised version of plotmatrix
[T,d] = size(x);
mksize = autosize(T);

x = invboundtransfer(x,UB,LB);

for i = 1:d; line([0,d],[i,i],'Color',[0 0 0]); hold on; end;
for j = 1:d; line([j,j],[0 d],'Color',[0 0 0]); hold on; end;

for i = 1:d
    for j = 1:d
        if i ~= j
            plot(x(:,i)+(i-1),x(:,j)+(d-j),'b.','MarkerSize',mksize);hold on;
        end
    end
end

t = 0:0.01:1;
for i = 1:d
    h1 = 1.06*std(x(:,i))*length(x(:,i))^(-1/5);
    f1 = kernelpdf1d(x(:,i),h1,t);
    fmax = max(f1);
    f1 = f1/fmax;
    plot(t+(i-1),f1+(d-i),'b-');hold on;
end

% for i = 1:d
%     L = 10;
%     S = 1/L;
%     lb = 0:S:(1-S);
%     ub = S:S:1;
%     nelements = zeros(1,L);
%     for k = 1:T
%         for ib = 1:L
%             if x(k,i) >= lb(ib) && x(k,i) < ub(ib)
%                 nelements(ib) = nelements(ib) + 1;
%             end
%         end
%     end
%     B = nelements/T;
%     B = max(B/max(B),0.001);
%     for j = 1:L
%         rectangle('Position',[(i-1)+(j-1)*S,d-i,S,B(j)],'FaceColor','b');hold on;
%     end
% end

hold off;

set(gca,'XTick',(1:d)-0.5);
set(gca,'XTickLabel',paraname);
set(gca,'YTick',(1:d)-0.5);
set(gca,'YTickLabel',paraname(end:-1:1));
% title(['Centered L_2-discrepancy = ',num2str(Discrepancy(x)),...
%     '; Correlation score = ',num2str(corrscore(x))]);

end

function f = kernelpdf1d(x,h,t)
% compute the probability density of x
n = length(x); T = length(t);
f = zeros(1,T);
for idx = 1:T
    nx = (t(idx)-x)./h;
    f(idx) = sum(1/(sqrt(2*pi)).*exp(-0.5*nx.^2));
end
f = f/(n*h);
end

function mksize = autosize(T)
    if T > 5000; mksize = 1;
    elseif T > 2000; mksize = 2;    
    elseif T > 1000; mksize = 5;    
    elseif T > 500; mksize = 10;
    else mksize = 10;
    end
end