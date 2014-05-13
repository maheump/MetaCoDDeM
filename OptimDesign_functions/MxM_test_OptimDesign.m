%%%% Test VBA on METACODDEM (with chance level) %%%%

clearvars -except Loop Loops Fit_quality; close all; clc

%% Set some parameters (chance, grid, etc.)

fprintf('INITIALIZING\n');

DATA.Fit.Psychometric.Chance = 0.5; % 0 0.5 1/24

sigmoid_binomial_nogradients(DATA.Fit.Psychometric.Chance);
DATA.Fit.Psychometric.Function = @sigmoid_binomial_nogradients;
fprintf(' Adjusting for chance level: %g%%.\n', DATA.Fit.Psychometric.Chance*100);

DATA.Fit.Psychometric.Estimated = [log(10);0.25];
fprintf(' Setting priors: beta = %g, theta = %g.\n', DATA.Fit.Psychometric.Estimated(1), DATA.Fit.Psychometric.Estimated(2));

DATA.Fit.Psychometric.Estimated_variance = diag([log(10),10]);
DATA.Fit.Psychometric.Grid = 0.01:0.01:1;

%% Initialize the bayesian gas factory

DATA.Fit.Psychometric.Init = OptimDesign('initialize', ...
    DATA.Fit.Psychometric.Function, ...
    DATA.Fit.Psychometric.Estimated, ...
    DATA.Fit.Psychometric.Estimated_variance, ...
    DATA.Fit.Psychometric.Grid);

%% Define the targetted theoretical parameters

Theroretical_parameters = [log(30), 0.3]; %[log(randi([20, 100])); randi([1, 30])/100];
fprintf(' Setting theoretical curve parameters: beta = %g, theta = %g.\n', Theroretical_parameters);

%% Create our pseudo-subject

%Pseudo_subject = @(phi, c) ...
    %sampleFromArbitraryP([DATA.Fit.Psychometric.Function([], phi, c), 1 - DATA.Fit.Psychometric.Function([], phi, c)]', [1, 0]', 1);
Pseudo_subject = @(phi, c) rand(size(c)) <= DATA.Fit.Psychometric.Function([], phi, c);

%% Prepare the graph window

x = min(DATA.Fit.Psychometric.Grid)-0.05:0.001:max(DATA.Fit.Psychometric.Grid) + 0.05;
y_target = DATA.Fit.Psychometric.Function([], Theroretical_parameters, x);

fig = figure;
set(gcf,'color','w');

BINS = [0.0:0.025:0.95, 1];

subplot(2,1,1);

    plot(x, y_target, 'b--');
    hold on
    
    axis([min(DATA.Fit.Psychometric.Grid) - 0.05, max(DATA.Fit.Psychometric.Grid) + 0.05, 0, 1]);
    xlabel('Coherence levels');
    ylabel('Performance');
    
%% First, give some constraints to the model

fprintf('\nCONSTRAINTS\n');

Forced_levels = [0.01, 0.6];
Forced_performance = [DATA.Fit.Psychometric.Chance, 1];
Forced_trials = 100;

DATA.Paradigm.Phasis1.Coherences = [];
DATA.Answers.Correction = [];

for Forced_level = 1:size(Forced_levels, 2)
    for Forced_trial = 1:Forced_trials
        DATA.Paradigm.Phasis1.Coherences(end + 1) = Forced_levels(Forced_level);
    end
    for Forced_trial = 1:round(Forced_trials*Forced_performance(Forced_level))
        DATA.Answers.Correction(end + 1, :) = 1;
    end
    for Forced_trial = 1:round(Forced_trials*(1 - Forced_performance(Forced_level)))
        DATA.Answers.Correction(end + 1, :) = 0;
    end
end % vérifier dans le script de la tâche comment les cohérences et les réponses sont enregistrées (colonnes ou lignes)

Forced_table = double(grpstats(set(mat2dataset([transpose(DATA.Paradigm.Phasis1.Coherences),(DATA.Answers.Correction)]), ...
    'VarNames', {'Coherence','Correction'}), 'Coherence'));
for Forced_level = 1:size(Forced_table, 1)
    fprintf(' %g trials forced to evoked %g%% performance for a coherence level at %g%%.\n', Forced_table(Forced_level, 2), ...
        Forced_table(Forced_level, 3)*100, Forced_table(Forced_level, 1)*100);
end

%% Then display some training trials

fprintf('\nPHASE 1: TRAINING\n');

Training_window = [0.2, 0.8];
Training_trials = 10;
Training_levels = Shuffle((round(linspace(Training_window(1), Training_window(2), Training_trials)*100))/100);

Correction = zeros(1, Training_trials);

for Trial_number = 1:Training_trials    
    Correction(Trial_number) = Pseudo_subject(DATA.Fit.Psychometric.Estimated, Training_levels(Trial_number));
    fprintf(' Trial %d: Training with %g coherence evokes %g.\n', Trial_number, Training_levels(Trial_number), Correction(Trial_number));
end

%% Then screen the grid to provide some help to the bayesian optimization system

fprintf('\nPHASE 2: SCREENING\n');

Previous_trials = size(DATA.Paradigm.Phasis1.Coherences, 2);
Screening_window = [0.01, 0.6];
Screning_interval = 20;
Screening_levels = Shuffle((round(linspace(Screening_window(1), Screening_window(2), Screning_interval)*100))/100);
Screening_trials = size(Screening_levels, 2);

if (Screning_interval > 1)
    for Trial_number = (1 + Training_trials):(Screening_trials + Training_trials)
        
        DATA.Paradigm.Phasis1.Coherences(Previous_trials + Trial_number - Training_trials) = Screening_levels(Trial_number - Training_trials);
        DATA.Answers.Correction(Previous_trials + Trial_number - Training_trials) = ...
            Pseudo_subject(DATA.Fit.Psychometric.Estimated, Screening_levels(Trial_number - Training_trials));
        
        OptimDesign('register', DATA.Answers.Correction(Previous_trials + Trial_number - Training_trials), ...
            DATA.Paradigm.Phasis1.Coherences(Previous_trials + Trial_number - Training_trials), (Previous_trials + Trial_number - Training_trials));
        
        fprintf(' Trial %d: Screening with %g coherence evokes %g.\n', Trial_number, DATA.Paradigm.Phasis1.Coherences(Previous_trials + Trial_number - Training_trials), ...
            DATA.Answers.Correction(Previous_trials + Trial_number - Training_trials));
    end
    
elseif (Screning_interval < 2)
    fprintf(' No screening trials defined.\n');
end

%% Then, launch bayesian optimization and update it at each trial

fprintf('\nPHASE 3: OPTIMIZING\n');

% Optimizing_trials_max = 200;
% Optimizing_minimum_efficiency = -0.05;

Previous_trials = size(DATA.Paradigm.Phasis1.Coherences, 2);
Optimizing_trials = 90;
DATA.Fit.Psychometric.Efficiency = -Inf*ones(Optimizing_trials, 1);

for Trial_number = (1 + Training_trials + Screening_trials):(Training_trials + Screening_trials + Optimizing_trials)
    
    % Ask the optimizater the most informative coherence Forced_level it could find (and its relative efficiency)
    [DATA.Paradigm.Phasis1.Coherences(Previous_trials + Trial_number - Training_trials - Screening_trials), ...
        DATA.Fit.Psychometric.Efficiency(Trial_number - Training_trials - Screening_trials)] = OptimDesign('nexttrial');
    
    % Mettre une précaution s'il demande plus de 5 fois de suite le même
    % niveau de cohérence !
    
    % Ask the pseudo-subject his answer
    DATA.Answers.Correction(Previous_trials + Trial_number - Training_trials - Screening_trials, 1) = ...
        Pseudo_subject(Theroretical_parameters, DATA.Paradigm.Phasis1.Coherences(Previous_trials + Trial_number - Training_trials - Screening_trials));
    fprintf(' Trial %d: Optimizing with %g coherence evokes %g.\n', Trial_number, ...
        DATA.Paradigm.Phasis1.Coherences(Previous_trials + Trial_number - Training_trials - Screening_trials), ...
        DATA.Answers.Correction(Previous_trials + Trial_number - Training_trials - Screening_trials, 1));
    
    % Register
    OptimDesign('register', DATA.Answers.Correction(Previous_trials + Trial_number - Training_trials - Screening_trials, 1));
    
    % Monitor
    [DATA.Fit.Psychometric.Parameters(:, Trial_number - Training_trials - Screening_trials)] = OptimDesign('results');
    
    % Compute the quality of fit
    Fit = (abs(Theroretical_parameters(1) - DATA.Fit.Psychometric.Parameters(1, Trial_number - Training_trials - Screening_trials)) + ...
        abs(Theroretical_parameters(2) - DATA.Fit.Psychometric.Parameters(2, Trial_number - Training_trials - Screening_trials)));
    
    % Display the bayesian guess
    if Trial_number ~= (1 + Training_trials + Screening_trials)
        delete(Bayesian_guess);
    end
            
    subplot(2,1,1);
        
        y_arrow = DATA.Fit.Psychometric.Function([], DATA.Fit.Psychometric.Parameters(:, Trial_number - Training_trials - Screening_trials), x);
        Bayesian_guess(1) = plot(x, y_arrow, 'r-');
        hold on
        
        Bayesian_guess(2) = bar(0.95, 1 + DATA.Fit.Psychometric.Efficiency(Trial_number - Training_trials - Screening_trials), 0.025, 'FaceColor', 'm');
        hold on
        
        Bayesian_guess(3) = bar(0.925, Fit, 0.025, 'FaceColor', 'c');
        hold on
        
        [hc{1,1}, hc{1,2}] = histc(DATA.Paradigm.Phasis1.Coherences, BINS);
        [hc{2,1}, hc{2,2}] = histc(DATA.Paradigm.Phasis1.Coherences(DATA.Answers.Correction == 1), BINS);
        for BIN = 1:numel(BINS)
            Bayesian_guess(4) = plot(BINS(BIN), hc{2,1}(BIN)./hc{1,1}(BIN), 'k.');
            %Bayesian_guess(4) = plot(BINS(BIN), hc{2,1}(BIN)./hc{1,1}(BIN), 'k.', 'MarkerSize', 4+round(log(hc{1}(BIN)+1)));
            set(Bayesian_guess(4), 'Color', [1, 1, 1].*0.9.*max(0,(30-hc{1}(BIN))/30));
        end
        
        axis([min(DATA.Fit.Psychometric.Grid) - 0.05, max(DATA.Fit.Psychometric.Grid) + 0.05, 0, 1])
    
    subplot(2,1,2);
    
        Bayesian_guess(5) = bar(BINS, hc{1,1}, 'FaceColor', 'r');
        hold on
        
        Bayesian_guess(6) = bar(BINS, hc{2,1}, 'FaceColor', 'g');
        hold on
        
        axis([min(DATA.Fit.Psychometric.Grid) - 0.05, max(DATA.Fit.Psychometric.Grid) + 0.05, 0, max([hc{1,1},hc{2,1}])]);
        xlabel('Coherence levels');
        ylabel('Number of trials');
        
    drawnow

    % Save the state of the bayesian optimizer
    fit = OptimDesign('state');
    for t = DATA.Fit.Psychometric.Grid(1:10:end)
        s = ones(100);
        for i = 1:100
            s(i) = DATA.Fit.Psychometric.Function([],[ ...
            fit.posterior(end).muPhi(1)+randn*(fit.posterior(end).SigmaPhi(1)); ...
            fit.posterior(end).muPhi(2)+randn*(fit.posterior(end).SigmaPhi(4))], t);
        end
        %Bayesian_guess(7) = [Bayesian_guess ploterr(t, mean(s), std(s),'Color',[1 1 1]*.9)];
    end
end

%% Call the results
[DATA.Fit.Psychometric.muPhi,DATA.Fit.Psychometric.SigmaPhi] = OptimDesign('results');

%% Save the error
Error = [abs(DATA.Fit.Psychometric.muPhi(1) - Theroretical_parameters(1)); abs(DATA.Fit.Psychometric.muPhi(2) - Theroretical_parameters(2))];
fprintf('\nError: on beta = %g, on theta = %g.\n', Error);