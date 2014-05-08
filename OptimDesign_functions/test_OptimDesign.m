%% Test VBA on METACODDEM (with chance level)

clear all; close all

% Set the chancelevel used within the sigmoid:
chancelevel = 0.5; % 0 0.5 1/24
sigmoid_binomial_nogradients(chancelevel);
DATA.Fit.Psychometric.Func = @sigmoid_binomial_nogradients; %(u,Phi) sigm(u,struct('G0',1,'S0',0,'beta',1,'INV',0),Phi); @sigplus; %(u,Phi) sigm(u,struct('G0',1,'S0',0,'beta',1,'INV',0),Phi);
DATA.Fit.Psychometric.Estimated = [log(10);0.5];
DATA.Fit.Psychometric.EstimatedVariance = diag([log(10),10]); %1e2*eye(2);
DATA.Fit.Psychometric.GridU = 0.1:0.01:1; %10.^[-5:0.1:0];

% Initialize the bayesian gas factory
DATA.Fit.Psychometric.Init = OptimDesign('initialize', ...
    DATA.Fit.Psychometric.Func, ...
    DATA.Fit.Psychometric.Estimated, ...
    DATA.Fit.Psychometric.EstimatedVariance, ...
    DATA.Fit.Psychometric.GridU);

% Define target theoretical parameters
phi_target = [log(30);.2392]; [log(20*rand+5);.4*rand+.1];
fprintf('Theoretical: %g, %g\n', phi_target);

% Create our pseudo-subject
pseudo_subject = @(phi,c) ...
    sampleFromArbitraryP([DATA.Fit.Psychometric.Func([],phi,c),1-DATA.Fit.Psychometric.Func([],phi,c)]',[1,0]',1);
% Another way to put it
pseudo_subject = @(phi,c) rand(size(c)) <= DATA.Fit.Psychometric.Func([],phi,c);
% This is our Pseudo subject
% proba(t)  = DATA.Fit.Psychometric.Func([],phi_target,DATA.Paradigm.Phasis1.Coherences(Trial_number),[]);
% Response by this pseudo subject
% [y(t)] = sampleFromArbitraryP([proba(t),1-proba(t)]',[1,0]',1);

% Prepare the graph window
x = min(DATA.Fit.Psychometric.GridU):0.001:max(DATA.Fit.Psychometric.GridU);
y_target = DATA.Fit.Psychometric.Func([], phi_target, x); % sigmf(x, phi, chancelevel);
fig = figure;
plot(x, y_target, 'r-.');
hold on
plot(x, chancelevel, 'r:');
hold on
axis([min(DATA.Fit.Psychometric.GridU), max(DATA.Fit.Psychometric.GridU), 0, 1]);

% First, give some constraints to the model
Nbrutal = 100;
DATA.Paradigm.Phasis1.Coherences = [repmat(0.01, Nbrutal, 1); repmat(0.02, Nbrutal, 1); repmat(0.5, Nbrutal, 1)];
DATA.Answers.Correction = [zeros(Nbrutal, 1); zeros(Nbrutal, 1); ones(Nbrutal, 1)];
fprintf('Give some constraints to the model: %g points times %g levels of coherence\n', Nbrutal, size(DATA.Paradigm.Phasis1.Coherences,1)/Nbrutal);

% Then screen the
Window = [0.01,0.4];
Frequency = 2;
Grid_init = (round(linspace(Window(1), Window(2) , Frequency)*100))/100;
PreviousTrials = size(DATA.Paradigm.Phasis1.Coherences, 1);
N_init = numel(Grid_init);
a = 1;
for i = (PreviousTrials + 1):(PreviousTrials + N_init)
    y(a) = pseudo_subject(DATA.Fit.Psychometric.Estimated,Grid_init(a));
    DATA.Paradigm.Phasis1.Coherences(i) = Grid_init(a);
    DATA.Answers.Correction(i,1) = y(a);
    OptimDesign('register',DATA.Answers.Correction(i),DATA.Paradigm.Phasis1.Coherences(i),i);
    a = a+1;
end

% Then, launch bayesian optimization and update it at each trial
PreviousTrials = size(DATA.Paradigm.Phasis1.Coherences, 1);
NTrials = 100;
NTrialsmax = 2000;
MinEfficiency = -0.05;
efficiency = -Inf*ones(NTrials,1);
Trial_number = 1;
while Trial_number < NTrials % NTrialsmax %%&& efficiency(Trial_number) < MinEfficiency
    fprintf('Trial %d\n', Trial_number);
    
    % Ask the optimizater the most informative coherence level it could find (and its relative efficiency)
    [DATA.Paradigm.Phasis1.Coherences(PreviousTrials + Trial_number), efficiency(Trial_number)] = OptimDesign('nexttrial');
    
    % Ask the pseudo-subject his answer
    DATA.Answers.Correction(PreviousTrials + Trial_number,1) = ...
        pseudo_subject(phi_target, DATA.Paradigm.Phasis1.Coherences(PreviousTrials + Trial_number));
    
    % Register
    OptimDesign('register',DATA.Answers.Correction(PreviousTrials + Trial_number,1));
    
    % Monitor
    [DATA.Fit.Psychometric.Parameters(:,Trial_number)] = OptimDesign('results');
    fprintf(' Behavior: %g, %g\n', DATA.Paradigm.Phasis1.Coherences(PreviousTrials + Trial_number), DATA.Answers.Correction(PreviousTrials + Trial_number,1));
    fprintf(' Fit: %g, %g\n',DATA.Fit.Psychometric.Parameters(:, Trial_number));
    
    Phi = DATA.Fit.Psychometric.Parameters(:, Trial_number);
    
    y_arrow = DATA.Fit.Psychometric.Func([], Phi, x); % sigmf(x, [beta;th], chancelevel);
    
    % s = 1/(1-chancelevel);
    % th = Phi(2);
    % beta = exp(Phi(1));
    % beta_min = atan((chancelevel+1)/(2*th));
    % beta = s.*(beta_min + beta);
    
    % Display the bayesian guess
    try
        clear bayesian_guess
    catch
    end
    BINS = [0.0:.05:.95 1];
    
    [hc{1,1},hc{1,2}]= histc(DATA.Paradigm.Phasis1.Coherences      ,BINS);
    [hc{2,1},hc{2,2}]= histc(DATA.Paradigm.Phasis1.Coherences(y==1),BINS);
    
    bayesian_guess(2) = bar(BINS,hc{1,1}/100);
    bayesian_guess(3) = bar(BINS,hc{2,1}/100,'FaceColor','g');
    bayesian_guess(4) = bar(.95, 1+efficiency(Trial_number), .05, 'FaceColor','m');
    for i=1:numel(BINS)
        bayesian_guess(end+1) = plot(BINS(i),hc{2,1}(i)./hc{1,1}(i),'ko');
        bayesian_guess(end+1) = plot(BINS(i),hc{2,1}(i)./hc{1,1}(i),'k.', 'MarkerSize',4+round(log(hc{1}(i)+1)));
        set(bayesian_guess(end),'Color',[1 1 1].*.9.*max(0,(30-hc{1}(i))/30));
    end
    if Trial_number>20
        fit = OptimDesign('state');
        for t=DATA.Fit.Psychometric.GridU(1:10:end)
            for i=1:100
                s(i) = DATA.Fit.Psychometric.Func([],[ ...
                    fit.posterior(end).muPhi(1)+randn*(fit.posterior(end).SigmaPhi(1));...
                    fit.posterior(end).muPhi(2)+randn*(fit.posterior(end).SigmaPhi(4))],t);
            end
            % bayesian_guess = [bayesian_guess ploterr(t, mean(s), std(s),'Color',[1 1 1]*.9)];
        end
    end
    
    bayesian_guess(1) = plot(x, y_arrow, 'b-');
    
    drawnow
    Trial_number = Trial_number + 1; %(N_init+1):NTrials
    
    %     options.priors = fit.posterior(end);
    %     dim = DATA.Fit.Psychometric.Init.dim;
    %     dim.p = length(DATA.Fit.Psychometric.GridU);
    %     [gx,vy] = VBA_getLaplace(DATA.Fit.Psychometric.GridU(:),[],DATA.Fit.Psychometric.Func,dim,options);
    %     gxhat = g_sigm_binomial([],posterior.muPhi,sort(u),[]);
    %     vy = diag(vy);
    %     plotUncertainTimeSeries(gx(:)',vy(:)',DATA.Fit.Psychometric.GridU(:)',ha0);
    %
    %     bayesian_guess(4) = plot([DATA.Paradigm.Phasis1.Coherences(y==1)],.2+rand(sum(y==1),1)/10,'og');
    %     bayesian_guess(4) = plot([DATA.Paradigm.Phasis1.Coherences(y==0)],.1+rand(sum(y==0),1)/10,'or');
end

[DATA.Fit.Psychometric.muPhi,DATA.Fit.Psychometric.SigmaPhi] = OptimDesign('results');

DATA.Fit.Psychometric.Quality = [abs(DATA.Fit.Psychometric.muPhi(1) - phi_target(1));abs(DATA.Fit.Psychometric.muPhi(2) - phi_target(2))];
fprintf('Error: %g, %g\n', DATA.Fit.Psychometric.Quality);
