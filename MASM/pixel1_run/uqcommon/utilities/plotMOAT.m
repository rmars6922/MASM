function h = plotMOAT(uqdata,i)
u = uqdata.sensitivity.result.u(i,:);
s = uqdata.sensitivity.result.s(i,:);

h = plot(u,s,'.','MarkerSize',10);
for k = 1:length(u)
    text(u(k),s(k)+max(s)*0.015,int2str(k));
end
xlabel('\mu*');
ylabel('\sigma');