function XB = boundtransfer(X,UB,LB)
% original X ~ [0,1]
% transfered XB ~ [LB,UB]
[nSample,nInput] = size(X);
XB = zeros(nSample,nInput);
for i = 1:nInput
    XB(:,i) = LB(i) + X(:,i).*(UB(i)-LB(i));
end
