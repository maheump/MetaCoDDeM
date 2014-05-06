clear all; close all

% Set the chancelevel used within the sigmoid:
chancelevel = 0.5; % 0 0.5 1/24
sigmoid_binomial_nogradients(chancelevel);

DATA.Fit.Psychometric.Func = @sigmoid_binomial_nogradients; %(u,Phi) sigm(u,struct('G0',1,'S0',0,'beta',1,'INV',0),Phi);

DATA.Fit.Psychometric.Estimated = [log(30);0.5];
DATA.Fit.Psychometric.EstimatedVariance = 1e2*eye(2);

DATA.Fit.Psychometric.GridU = 0.1:1e-2:2;

% Initialize the bayesian gas factory
OptimDesign('initialize', ...
    DATA.Fit.Psychometric.Func, ...
    DATA.Fit.Psychometric.Estimated, ...
    DATA.Fit.Psychometric.EstimatedVariance, ...
    DATA.Fit.Psychometric.GridU);

phi = [8;0.25];

NTrials = 100;
efficiency = zeros(NTrials,1);

initial_grid = [];

% Prepare the graph window
x = min(DATA.Fit.Psychometric.GridU):0.001:max(DATA.Fit.Psychometric.GridU);
y_target = sigmf(x, phi, chancelevel);
fig = figure(1);
plot(x, y_target, 'r-.');
hold on
plot(x, chancelevel, 'r');
hold on
axis([min(DATA.Fit.Psychometric.GridU), max(DATA.Fit.Psychometric.GridU), 0, 1]);

% At each trial
for Trial_number = 1:NTrials
    
    if (size(initial_grid, 1) ~= 0)
        % update MBB-VBA with it befor starting optimization
    end
    
    [DATA.Paradigm.Phasis1.Coherences(Trial_number),efficiency(Trial_number)] = OptimDesign('nexttrial');
    
    fprintf('Trial %d\n',Trial_number);
    t = Trial_number;
    
    % This is our Pseudo subject
    proba(t)  = DATA.Fit.Psychometric.Func([],phi,DATA.Paradigm.Phasis1.Coherences(Trial_number),[]);
    % Response by this pseudo subject
    [y(t)] = sampleFromArbitraryP([proba(t),1-proba(t)]',[1,0]',1);
    DATA.Answers.Correction(Trial_number,1) = y(t);
    
    % Register
    OptimDesign('register',DATA.Answers.Correction(Trial_number,1));
    
    % Monitor
    [DATA.Fit.Psychometric.Parameters(:,Trial_number)] = OptimDesign('results');
    DATA.Fit.Psychometric.Parameters(:,Trial_number)
    
    % Display the bayesian guess
    if (Trial_number ~= 1)
        delete(bayesian_guess);
    end
    y_arrow = sigmf(x, DATA.Fit.Psychometric.Parameters(:,Trial_number), chancelevel);
    bayesian_guess = plot(x, y_arrow, 'b-');
    drawnow
end                    

[DATA.Fit.Psychometric.muPhi,DATA.Fit.Psychometric.SigmaPhi] = OptimDesign('results');

DATA.Fit.Psychometric.Quality = [abs(DATA.Fit.Psychometric.muPhi(1) - phi(1));abs(DATA.Fit.Psychometric.muPhi(2) - phi(2))];
DATA.Fit.Psychometric.Quality