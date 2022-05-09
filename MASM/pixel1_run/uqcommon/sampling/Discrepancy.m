function D = Discrepancy(X,option)
% compute 4 kinds of L2-discrepancy
% [Hickernell, 1998], [Fang et.al., 2000]
% 1: MD2 
% 2: CD2
% 3: SD2
% 4: WD2
% n: number of points
% s: number of dimensions
if nargin == 1; option = 'CD2'; end;
switch option
    case 'MD2'
        D = MD2(X);
    case 'CD2'
        D = CD2(X);
    case 'SD2'
        D = SD2(X);
    case 'WD2'
        D = WD2(X);
    otherwise
        D = CD2(X);
end

%%
function D = MD2(X)
[n,s] = size(X);
D1 = (4/3)^s;

D2 = 0;
for k = 1:n
    DD2 = 1;
    for j = 1:s
        DD2 = DD2 * (3 - X(k,j)^2);
    end
    D2 = D2 + DD2;
end

D3 = 0;
for k = 1:n
    for j = 1:n
        DD3 = 1;
        for i = 1:s
            DD3 = DD3 * (2 - max(X(k,i),X(j,i)));
        end
        D3 = D3 + DD3;
    end
end

D = sqrt(D1 + D2*(-2^(1-s)/n) + D3/(n^2));

%%
function D = CD2(X)
[n,s] = size(X);

D1 = (13/12)^s;

D2 = 0;
for k = 1:n
    DD2 = 1;
    for j = 1:s
        DD2 = DD2 * (1 + 0.5*abs(X(k,j)-0.5) - 0.5*abs(X(k,j)-0.5)^2 );
    end
    D2 = D2 + DD2;
end

D3 = 0;
for k = 1:n
    for j = 1:n
        DD3 = 1;
        for i = 1:s
            DD3 = DD3 * (1 + 0.5*abs(X(k,i)-0.5) + 0.5*abs(X(j,i)-0.5) - 0.5*abs(X(k,i)-X(j,i)) );
        end
        D3 = D3 + DD3;
    end
end

D = sqrt(D1 + D2*(-2/n) + D3/(n^2));
    
%%
function D = SD2(X)
[n,s] = size(X);
D1 = (4/3)^s;

D2 = 0;
for k = 1:n
    DD2 = 1;
    for j = 1:s
        DD2 = DD2 * (1 + 2*X(k,j) - 2*X(k,j)^2);
    end
    D2 = D2 + DD2;
end

D3 = 0;
for k = 1:n
    for j = 1:n
        DD3 = 1;
        for i = 1:s
            DD3 = DD3 * (1 - abs(X(k,i)-X(j,i)));
        end
        D3 = D3 + DD3;
    end
end

D = sqrt(D1 + D2*(-2/n) + D3*((2^s)/(n^2)));

%%
function D = WD2(X)
[n,s] = size(X);
D1 = -(4/3)^s;

D3 = 0;
for k = 1:n
    for j = 1:n
        DD3 = 1;
        for i = 1:s
            DD3 = DD3 * (3/2 - abs(X(k,i)-X(j,i)) * (1 - abs(X(k,i)-X(j,i))));
        end
        D3 = D3 + DD3;
    end
end

D = sqrt(D1 + D3/(n^2));