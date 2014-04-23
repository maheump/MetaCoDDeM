clear

% DATA.Fit.Psychometric.SigFunc = @(F, x)(1./(1 + exp(-F(1)*(x-F(2)))));
DATA.Fit.Psychometric.Func = @g_sigm_binomial;
DATA.Fit.Psychometric.Estimated = [0;0];
DATA.Fit.Psychometric.EstimatedVariance = 1e2*eye(2);
DATA.Fit.Psychometric.GridU = 0:.01:1 ;

OptimDesign('initialize',...
    DATA.Fit.Psychometric.Func,...
    DATA.Fit.Psychometric.Estimated,...
    DATA.Fit.Psychometric.EstimatedVariance,...
    DATA.Fit.Psychometric.GridU);

phi = [3 ; .1];

for Trial_number=1:100
    [DATA.Paradigm.Phasis1.Coherences(Trial_number),efficiency(Trial_number)] = OptimDesign('nexttrial');

    
    % This is our Pseudo subject
    t = Trial_number
    proba(t)  = g_sigm_binomial([],phi,DATA.Paradigm.Phasis1.Coherences(Trial_number),[]);
    % pseudo r�ponse du sujet
    [y(t)] = sampleFromArbitraryP([proba(t),1-proba(t)]',[1,0]',1);
    
    DATA.Answers.Correction(Trial_number,1) = y(t);
    
    % Register
    OptimDesign('register',DATA.Answers.Correction(Trial_number,1));
end                    
[DATA.Fit.Psychometric.muPhi,DATA.Fit.Psychometric.SigmaPhi] = OptimDesign('results');

