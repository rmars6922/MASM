function pfdi = CalcPFDI(f1,f2)
% calculate Pareto Frontier Diversity Index, [Deb et al., 2002]
% calculate the diversity of Pareto optimal set f1, comparing to the true
% Pareto set f2

[n1,d1] = size(f1);
[n2,d2] = size(f2);

[~,idx]=sort(f1(:,1));f1 = f1(idx,:);
[~,idx]=sort(f2(:,1));f2 = f2(idx,:);

if d1 ~= d2; disp('warning! data dimension mismatch!'); pfdi = 9999; return; end;
d = d1;

UB = max(max(f1),max(f2));
LB = min(min(f1),min(f2));
uf1 = invboundtransfer(f1,UB,LB);
uf2 = invboundtransfer(f2,UB,LB);

dist = zeros(1,n1-1);

for i = 1:n1-1
    dist(i) = sqrt(sum((uf1(i,:) - uf1(i+1,:)).^2)/d);
end

df = sqrt(sum((uf1(1,:) - uf2(1,:)).^2)/d);
dl = sqrt(sum((uf1(n1,:) - uf2(n2,:)).^2)/d);

md = mean(dist);

pfdi = (df+dl+sum(abs(dist-md)))/(df+dl+(n1-1)*md);

end