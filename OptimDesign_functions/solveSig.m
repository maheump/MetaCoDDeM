function [coherence] = solveSig(mu, sigma, perf, chancelevel)

if nargin<4
    chancelevel = 0;
end
eval(['sigmoid = @(x) chancelevel+(1-chancelevel)./(1 + exp(-' mat2str(mu) '*(x-' mat2str(sigma) ')))' ' - ' mat2str(perf) ';']);
coherence = fzero(sigmoid, 0.5);

end