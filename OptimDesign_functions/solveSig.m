function [coherence] = solveSig(mu, sigma, perf, chancelevel)

if nargin<4
    chancelevel = 0;
end
eval(['sigmoid = @(x) ' num2str(chancelevel) '+(1-' num2str(chancelevel) ').*(1./(1 + exp(-' mat2str(mu) '*(x-' mat2str(sigma) '))))' ' - ' mat2str(perf) ';']);
sigmoid
plot(sigmoid(0:.01:1))
coherence = fzero(sigmoid, 0.5);

end
