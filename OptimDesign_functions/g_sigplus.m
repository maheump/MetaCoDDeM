function gx = g_sigplus(x,P,u,in)

s = sig(P(1));
b = exp(P(2));
t = P(3);

gx = s + (1-s)./(1+exp(-b.*(u-t)));