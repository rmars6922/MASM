function X = RGSdecorr(X,q,s)
% Ranked Gram-Schmidt de-correlation
% n: number of samples
% s: number of dimensions
% q: number of levels (has been set to q=n)

% Forward Ranked Gram-Schmidt step:
for j=2:s
    for k=1:j-1
        z = rmtrend(X(:,j),X(:,k));
        X(:,k) = (rand2rank(z) - 0.5) / q;
    end
end
% Backward ranked Gram-Schmidt step:
for j=s-1:-1:1
    for k=s:-1:j+1
        z = rmtrend(X(:,j),X(:,k));
        X(:,k) = (rand2rank(z) - 0.5) / q;
    end
end

end
%%
function x = rand2rank(r)
% transfer random number in [0,1] to integer number
[~,idx] = sort(r);
x(idx) = 1:length(r);
end
%%
function z = rmtrend(x,y)
% remove the trend between x and y from y
xm = x - mean(x);
ym = y - mean(y);
b = (xm-mean(xm))\(ym-mean(ym));
z = y - b*xm;
end