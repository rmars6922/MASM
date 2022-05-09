function y = logsumexp(x)
% return y = log(exp(x1)+exp(x2)+exp(x3)+...)
a = max(x);
y = a + log(sum(exp(x-a)));
end