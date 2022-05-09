function h = myPlotMatrix2(x1,x2,UB,LB,paraname)
% a revised version of plotmatrix
[T1,d] = size(x1);
[T2,~] = size(x2);

mksize1 = autosize(T1);
mksize2 = autosize(T2);

x1 = invboundtransfer(x1,UB,LB);
x2 = invboundtransfer(x2,UB,LB);

for i = 1:d; line([0,d],[i,i],'Color',[0 0 0]); hold on; end;
for j = 1:d; line([j,j],[0 d],'Color',[0 0 0]); hold on; end;

for i = 1:d
    for j = 1:d
        if i ~= j
            plot(x1(:,i)+(i-1),x1(:,j)+(d-j),'b.','MarkerSize',mksize1);hold on;
            plot(x2(:,i)+(i-1),x2(:,j)+(d-j),'r.','MarkerSize',mksize2);hold on;
        end
    end
end

t = 0:0.01:1;
for i = 1:d
    h1 = 1.06*std(x1(:,i))*length(x1(:,i))^(-1/5);
    h2 = 1.06*std(x2(:,i))*length(x2(:,i))^(-1/5);
    f1 = kernelpdf1d(x1(:,i),h1,t);
    f2 = kernelpdf1d(x2(:,i),h2,t);
    fmax = max([f1,f2]);
    f1 = f1/fmax; f2 = f2/fmax;
    plot(t+(i-1),f1+(d-i),'b-');hold on;
    plot(t+(i-1),f2+(d-i),'r-');hold on;
end

% for i = 1:d
%     L = 10;
%     S = 1/L;
%     lb = 0:S:(1-S);
%     ub = S:S:1;
%     
%     nelements1 = zeros(1,L);
%     for k = 1:T1
%         for ib = 1:L
%             if x1(k,i) >= lb(ib) && x1(k,i) < ub(ib)
%                 nelements1(ib) = nelements1(ib) + 1;
%             end
%         end
%     end
%     B1 = nelements1/T1;
% %     B1 = max(B1/max(B1),0.001);
%     B1 = max(B1,0.001);
%     for j = 1:L
%         rectangle('Position',[(i-1)+(j-1)*S,d-i,0.5*S,B1(j)],'FaceColor','b');hold on;
%     end
%     
%     nelements2 = zeros(1,L);
%     for k = 1:T2
%         for ib = 1:L
%             if x2(k,i) >= lb(ib) && x2(k,i) < ub(ib)
%                 nelements2(ib) = nelements2(ib) + 1;
%             end
%         end
%     end
%     B2 = nelements2/T2;
% %     B2 = max(B2/max(B2),0.001);
%     B2 = max(B2,0.001);
%     for j = 1:L
%         rectangle('Position',[(i-1)+(j-1+0.5)*S,d-i,0.5*S,B2(j)],'FaceColor','r');hold on;
%     end
% end

hold off;

set(gca,'XTick',(1:d)-0.5);
set(gca,'XTickLabel',paraname);
set(gca,'YTick',(1:d)-0.5);
set(gca,'YTickLabel',paraname(end:-1:1));

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