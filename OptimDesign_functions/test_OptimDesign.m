clear all; close all

% Set the chancelevel used within the sigmoid:
chancelevel = 0.5; % 0 0.5 1/24
sigmoid_binomial_nogradients(chancelevel);
DATA.Fit.Psychometric.Func = @sigmoid_binomial_nogradients; %(u,Phi) sigm(u,struct('G0',1,'S0',0,'beta',1,'INV',0),Phi);

DATA.Fit.Psychometric.Func = @sigplus; %(u,Phi) sigm(u,struct('G0',1,'S0',0,'beta',1,'INV',0),Phi);

DATA.Fit.Psychometric.Estimated = [log(10);0.5];
DATA.Fit.Psychometric.EstimatedVariance = diag([log(10),10])%1e2*eye(2);

DATA.Fit.Psychometric.GridU = 0:1e-2:1;
gridu=DATA.Fit.Psychometric.GridU;
%DATA.Fit.Psychometric.GridU = 10.^[-5:.1:0]

% Initialize the bayesian gas factory
DATA.Fit.Psychometric.Init = OptimDesign('initialize', ...
    DATA.Fit.Psychometric.Func, ...
    DATA.Fit.Psychometric.Estimated, ...
    DATA.Fit.Psychometric.EstimatedVariance, ...
    DATA.Fit.Psychometric.GridU);

%phi_target = [log(20*rand+5);.4*rand+.1];
phi_target = [log(30);.2392];

NTrials = 100;
NTrialsmax = 2000;
MinEfficiency = -.05
efficiency = -Inf*ones(NTrials,1);



% Prepare the graph window
x = min(DATA.Fit.Psychometric.GridU):0.001:max(DATA.Fit.Psychometric.GridU);
%y_target = sigmf(x, phi, chancelevel);
y_target = DATA.Fit.Psychometric.Func([],phi_target,x);
fig = figure;
plot(x, y_target, 'r-.');
hold on
plot(x, chancelevel, 'r:');
hold on
axis([min(DATA.Fit.Psychometric.GridU), max(DATA.Fit.Psychometric.GridU), 0, 1]);

pseudo_subject = @(phi,c) ...
    sampleFromArbitraryP([DATA.Fit.Psychometric.Func([],phi,c),1-DATA.Fit.Psychometric.Func([],phi,c)]',[1,0]',1);

pseudo_subject = @(phi,c) rand(size(c))<=DATA.Fit.Psychometric.Func([],phi,c)

% This is our Pseudo subject
%proba(t)  = DATA.Fit.Psychometric.Func([],phi_target,DATA.Paradigm.Phasis1.Coherences(Trial_number),[]);
% Response by this pseudo subject
%[y(t)] = sampleFromArbitraryP([proba(t),1-proba(t)]',[1,0]',1);

% First: N trials
Grid_init = repmat(.1:.1:.5,1,2);
N_init = numel(Grid_init);
for i=1:N_init
    y(i) = pseudo_subject(DATA.Fit.Psychometric.Estimated,Grid_init(i));
    DATA.Paradigm.Phasis1.Coherences(i) = Grid_init(i);
    DATA.Answers.Correction(i,1) = y(i);
    OptimDesign('register',DATA.Answers.Correction(i),DATA.Paradigm.Phasis1.Coherences(i),i);
end

Trial_number = N_init;

% At each trial
while Trial_number < NTrialsmax && efficiency(Trial_number)<MinEfficiency
    Trial_number = Trial_number +1 ; %(N_init+1):NTrials
    
    
    [DATA.Paradigm.Phasis1.Coherences(Trial_number),efficiency(Trial_number)] = OptimDesign('nexttrial');
    
    fprintf('Trial %d\n',Trial_number);
    t = Trial_number;
    
    y(t) = pseudo_subject(phi_target,DATA.Paradigm.Phasis1.Coherences(Trial_number));
    DATA.Answers.Correction(Trial_number,1) = y(t);
    
    % Register
    OptimDesign('register',DATA.Answers.Correction(Trial_number,1));
    
    % Monitor
    [DATA.Fit.Psychometric.Parameters(:,Trial_number)] = OptimDesign('results');
    fprintf('Trial %g %g\n',DATA.Fit.Psychometric.Parameters(:,Trial_number));
    
    Phi = DATA.Fit.Psychometric.Parameters(:,Trial_number);
    
    %s = 1/(1-chancelevel);
    %th = Phi(2);
    %beta = exp(Phi(1));
    %beta_min = atan((chancelevel+1)/(2*th));
    %beta = s.*(beta_min + beta);
    
    %y_arrow = sigmf(x, [beta;th], chancelevel);
    y_arrow = DATA.Fit.Psychometric.Func([],Phi,x);
    
    % Display the bayesian guess
    
    try
        delete(bayesian_guess);
    end
    bayesian_guess = plot(x, y_arrow, 'b-');
    bayesian_guess(2) = bar(0.05:.05:1,histc([DATA.Paradigm.Phasis1.Coherences],[0.05:.05:.95 1])/100);
    bayesian_guess(3) = bar(0.05:.05:1,histc([DATA.Paradigm.Phasis1.Coherences(y==1)],[0.05:.05:.95 1])/100,'FaceColor','g');
    
    bayesian_guess(4) = plot(0.05:.05:1,...
        histc([DATA.Paradigm.Phasis1.Coherences(y==1)],[0.05:.05:.95 1])./...
        histc([DATA.Paradigm.Phasis1.Coherences      ],[0.05:.05:.95 1]),'ko');
    
    bayesian_guess(5) = bar(.95, 1+efficiency(Trial_number),.05, 'FaceColor','m');
    
    fit=OptimDesign('state');
    
    for t=DATA.Fit.Psychometric.GridU(1:10:end)
        for i=1:100
            s(i) = DATA.Fit.Psychometric.Func([],[ ...
            fit.posterior(end).muPhi(1)+randn*(fit.posterior(end).SigmaPhi(1));...
            fit.posterior(end).muPhi(2)+randn*(fit.posterior(end).SigmaPhi(4))],t);
        end
        bayesian_guess = [ bayesian_guess ploterr(t, mean(s), std(s),'Color',[1 1 1]*.9)];
    end
    
    
    
    %     options.priors = fit.posterior(end);
    %     dim = DATA.Fit.Psychometric.Init.dim;
    %     dim.p = length(DATA.Fit.Psychometric.GridU);
    %     [gx,vy] = VBA_getLaplace(DATA.Fit.Psychometric.GridU(:),[],DATA.Fit.Psychometric.Func,dim,options);
    %     gxhat = g_sigm_binomial([],posterior.muPhi,sort(u),[]);
    %     vy = diag(vy);
    %     plotUncertainTimeSeries(gx(:)',vy(:)',gridu(:)',ha0);
    
    %bayesian_guess(4) = plot([DATA.Paradigm.Phasis1.Coherences(y==1)],.2+rand(sum(y==1),1)/10,'og')
    %bayesian_guess(4) = plot([DATA.Paradigm.Phasis1.Coherences(y==0)],.1+rand(sum(y==0),1)/10,'or')
    drawnow
    
    %fit=OptimDesign('state');
    
    
end

[DATA.Fit.Psychometric.muPhi,DATA.Fit.Psychometric.SigmaPhi] = OptimDesign('results');

DATA.Fit.Psychometric.Quality = [abs(DATA.Fit.Psychometric.muPhi(1) - phi_target(1));abs(DATA.Fit.Psychometric.muPhi(2) - phi_target(2))];
DATA.Fit.Psychometric.Quality