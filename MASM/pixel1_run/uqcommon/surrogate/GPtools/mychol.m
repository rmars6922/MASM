% my Cholesky decomposition
function L2 = mychol(A,L1)
% Cholesky decomposition for reinforcement learning
% n2-n1: dimension of reinforcement
n2 = size(A,1);  % dimension of updated matrix (needs decomposition)
L2 = zeros(n2);
if nargin == 2
    n1 = size(L1,1); % dimension of original matrix (has been decomposed)
    L2(1:n1,1:n1) = L1;
else
    n1 = 0;
end

for j = 1:n1
    for i = n1+1:n2
        S = 0;
        for k = 1:j-1; S = S + L2(i,k)*L2(j,k); end;
        L2(i,j) = (A(i,j) - S) / L2(j,j);
    end
end

for j = n1+1:n2
    S = 0;
    for k = 1:j-1; S = S + L2(j,k)^2; end;
    L2(j,j) = sqrt(A(j,j) - S);
    for i = j+1:n2
        S = 0;
        for k = 1:j-1; S = S + L2(i,k)*L2(j,k); end;
        L2(i,j) = (A(i,j) - S) / L2(j,j);
    end
end
