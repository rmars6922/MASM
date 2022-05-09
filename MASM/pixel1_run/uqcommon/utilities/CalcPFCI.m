function pfci = CalcPFCI(f1,f2)
% calculate Pareto Frontier Convergence Index, [Deb et al., 2002]
% find the nearest distance from f1 to f2
% f1: Pareto optimal set
% f2: the true Pareto set

[n1,d1] = size(f1);
[n2,d2] = size(f2);

if d1 ~= d2; disp('warning! data dimension mismatch!'); pfci = 9999; return; end;
d = d1;

UB = max(max(f1),max(f2));
LB = min(min(f1),min(f2));
uf1 = invboundtransfer(f1,UB,LB);
uf2 = invboundtransfer(f2,UB,LB);

dist = zeros(n2,n1);

for i = 1:n1
    for j = 1:n2
        dist(j,i) = sqrt(sum((uf1(i,:) - uf2(j,:)).^2)/d);        
    end
end

% pfci = sum(min(dist,[],1))/n1 + sum(min(dist,[],2))/n2;
pfci = sum(min(dist,[],1))/n1;

end

