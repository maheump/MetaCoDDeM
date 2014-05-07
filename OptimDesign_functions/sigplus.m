function gx = sigplus(x,P,u,in)
% Jean Daunizeau's function

%s = sig(P(1));
s = .4;
b = exp(P(1));
t = P(2);

gx = s + (1-s)./(1+exp(-b.*(u-t)));
end