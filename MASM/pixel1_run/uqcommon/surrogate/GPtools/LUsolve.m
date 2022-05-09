% solve linear equation Ax=b, in which A=LU
% L is lower triangle
% U is upper triangle
function x = LUsolve(b,L,U)
n = length(b);
if nargin == 2
    U = L';
end

% forward iteration
% Ly = b
% y is stored in b
for j = 1:n-1;
    b(j) = b(j)/L(j,j);
    for i = j+1:n
        b(i) = b(i) - L(i,j)*b(j);
    end
end
b(n) = b(n)/L(n,n);

% backward iteration
% Ux = y
for j = n:-1:2
    b(j) = b(j)/U(j,j);
    for i = j-1:-1:1
        b(i) = b(i) - U(i,j)*b(j);
    end
end
b(1) = b(1)/U(1,1);
    
x = b;