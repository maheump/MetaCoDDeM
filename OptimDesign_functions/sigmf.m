function y = sigmf(x, params, chancelevel)
%SIGMF Sigmoid curve membership function.
%   SIGMF(X, PARAMS) returns a matrix which is the sigmoid
%   membership function evaluated at X. PARAMS is a 2-element vector
%   that determines the shape and position of this membership function.
%   Specifically, the formula for this membership function is:
%
%   SIGMF(X, [A, C]) = 1./(1 + EXP(-A*(X-C)))
%
%   For example:
%
%       x = (0:0.2:10)';
%       y1 = sigmf(x, [-1 5]);
%       y2 = sigmf(x, [-3 5]);
%       y3 = sigmf(x, [4 5]);
%       y4 = sigmf(x, [8 5]);
%       subplot(211); plot(x, [y1 y2 y3 y4]);
%       y1 = sigmf(x, [5 2]);
%       y2 = sigmf(x, [5 4]);
%       y3 = sigmf(x, [5 6]);
%       y4 = sigmf(x, [5 8]);
%       subplot(212); plot(x, [y1 y2 y3 y4]);
%       set(gcf, 'name', 'sigmf', 'numbertitle', 'off');
%
%   See also DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, PSIGMF, SMF,
%   TRAPMF, TRIMF, ZMF.

%       Roger Jang, 6-29-93, 4-17-93.
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.18 $  $Date: 2002/04/14 22:20:56 $

if nargin == 1
    error('At least two arguments are required by the sigmoidal MF.');
end
if nargin<3
    chancelevel = 0;
end

a = params(1); c = params(2);
y = chancelevel+(1-chancelevel)./(1 + exp(-a*(x-c)));
