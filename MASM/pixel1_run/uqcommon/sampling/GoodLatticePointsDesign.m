function X = GoodLatticePointsDesign(n,s,maxiter)
% Good Lattice Points Design
% 方开泰 马长兴 正交与均匀试验设计 2001 p146 eq 3.41
% n: number of samples
% s: number of dimensions

    m = EulerFunction(n);
    if m/n < 0.9
        % GLP is best if r(n) = fai(n)/n = 1
        % use extend GLP if r(n) = fai(n)/n is too small
        if m < 20 && s < 4
        % type 1 GLP design, if the combination of C(s,m) is small
            m = EulerFunction(n+1);
            h = GenVector1(n+1);
            u = glp(n+1,h);
            u = u(1:n,:);
            cc = combnk(1:m,s);
            D = 1e32;
            for i = 1:size(cc,1)
                x = u(:,cc(i,:));
                x = (x + 0.5)/(n+1);
                d = Discrepancy(x);
                if d < D; D = d; X = x; end
            end
        else
        % type 2 GLP design, if the combination of C(s,m) is large
            h = GenVector2(n+1,s);
            D = 1e32;
            for i = 1:size(h,1)
                x = glp(n+1,h(i,:));
                x = x(1:n,:);
                x = (x + 0.5)/(n+1);
                d = Discrepancy(x);
                if d < D; D = d; X = x; end
            end
        end
    else
        if m < 20 && s < 4
        % type 1 GLP design, if the combination of C(s,m) is small
            h = GenVector1(n);
            u = glp(n,h);
            cc = combnk(1:m,s);
            D = 1e32;
            for i = 1:size(cc,1)
                x = u(:,cc(i,:));
                x = (x + 0.5)/n;
                d = Discrepancy(x);
                if d < D; D = d; X = x; end
            end
        else
        % type 2 GLP design, if the combination of C(s,m) is large
            h = GenVector2(n,s);
            D = 1e32;
            for i = 1:size(h,1)
                x = glp(n,h(i,:));
                x = (x + 0.5)/n;
                d = Discrepancy(x);
                if d < D; D = d; X = x; end
            end
        end
    end

    if nargin == 2
        maxiter = 5;
    end

    for iter = 2:maxiter
        X = RGSdecorr(X,n,s);
    end
end

%%
function fai = EulerFunction(n)
    p = factor(n);
    fai = n*(1-1/p(1));
    for i = 2:length(p)
        if p(i) ~= p(i-1)
            fai = fai*(1-1/p(i));
        end
    end
    fai = round(fai);   
end

%% 
function h = GenVector1(n)
    % type 1 generation vector
    g = gcd(1:n,n);
    h = find(g==1);
end

%% 
function h = GenVector2(n,s)
    % type 2 generation vector
    g = gcd(1:n,n);
    a = find(g==1);

    c = 1;
    for i = 1:length(a) %1:min(length(a),20)
        t = 1;
        m(t) = mod(a(i)^t,n);
        while m(t) ~= 1
            t = t + 1;
            m(t) = mod(a(i)^t,n);
            if t >= s; break; end;
        end
        rep = false;
        for j = 2:length(m)
            if m(j) == m(j-1)
                rep = true;
            end
        end
        if rep == false && t >= s
            aa(c) = a(i); tt(c) = t-1; c = c + 1;
        end
    end

    for i = 1:c-1
        hh = aa(i).^(0:s-1);
        hh = mod(hh,n);
        h(i,:) = hh;
    end
end
%%
function u = glp(n,h)
    % generate GLP using generation vector h
    m = length(h);
    u = zeros(n,m);
    for i = 1:n
        for j = 1:m
            u(i,j) = mod(i*h(j),n);
        end
    end
end