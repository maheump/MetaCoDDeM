clear

% DATA.Fit.Psychometric.SigFunc = @(F, x)(1./(1 + exp(-F(1)*(x-F(2)))));
% Set the chancelevel used within the sigmoid:
chancelevel = 0;%1/16;%.5;
sigmoid_binomial(chancelevel);
DATA.Fit.Psychometric.Func = @sigmoid_binomial;%(u,Phi) sigm(u,struct('G0',1,'S0',0,'beta',1,'INV',0),Phi);

DATA.Fit.Psychometric.Func = @g_sigm_binomial


DATA.Fit.Psychometric.Estimated = [0;0];
DATA.Fit.Psychometric.EstimatedVariance = 1e2*eye(2);

DATA.Fit.Psychometric.GridU = -1:2e-2:1;

OptimDesign('initialize', ...
    DATA.Fit.Psychometric.Func, ...
    DATA.Fit.Psychometric.Estimated, ...
    DATA.Fit.Psychometric.EstimatedVariance, ...
    DATA.Fit.Psychometric.GridU);

phi = [2.5 ; -.25];

NTrials = 100;
efficiency = zeros(NTrials,1);

for Trial_number=1:NTrials
    [DATA.Paradigm.Phasis1.Coherences(Trial_number),efficiency(Trial_number)] = OptimDesign('nexttrial');
    
    t = Trial_number;
    % This is our Pseudo subject
    proba(t)  = DATA.Fit.Psychometric.Func([],phi,DATA.Paradigm.Phasis1.Coherences(Trial_number),[]);
    % Response by this pseudo subject
    [y(t)] = sampleFromArbitraryP([proba(t),1-proba(t)]',[1,0]',1);
    
    DATA.Answers.Correction(Trial_number,1) = y(t);
    
    % Register
    OptimDesign('register',DATA.Answers.Correction(Trial_number,1));
    
    % monitor
    [m(:,Trial_number)]=OptimDesign('results');
    
end                    

[DATA.Fit.Psychometric.muPhi,DATA.Fit.Psychometric.SigmaPhi] = OptimDesign('results');

