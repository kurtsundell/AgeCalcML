function [a] = pdp5(m, s, min, max, step)

m = m;
s = s;

aa = min;
bb = max;
cc = step;

x = aa:cc:bb;

n = length(m);

f = zeros(n,length(x));

for i = 1:n;

f(i,:) = (1./ (s(i)*sqrt(2*pi)) .* exp (  (-((x-m(i)).^2)) ./ (2*((s(i)).^2))  ).*cc);

end

a = (sum(f))/n;

