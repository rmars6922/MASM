function X = invboundtransfer(XB,UB,LB)
% original XB ~ [LB,UB]
% transfered X ~ [0,1]
[nSample,nInput] = size(XB);
X = zeros(nSample,nInput);
for i = 1:nInput
    X(:,i) = (XB(:,i)-LB(i))./(UB(i)-LB(i));
end