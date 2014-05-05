function gx = sigplus(x,P,u,in)
% Jean Daunizeau's function

s = sig(P(1));
b = exp(P(2));
t = P(3);

gx = s + (1-s)./(1+exp(-b.*(u-t)));
end