function [coherence] = solveSig(mu, sigma, perf)

eval(['sigmoid = @(x) 1./(1 + exp(-' mat2str(mu) '*(x-' mat2str(sigma) ')))' ' - ' mat2str(perf) ';']);
coherence = fzero(sigmoid, 0.5);

end