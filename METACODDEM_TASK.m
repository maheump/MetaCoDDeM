% MetaCoDDeM project

%%% ------------------------------------------------------------------------------------- %%%
%%% ------------------------------------------------------------------------------------- %%%
%%% -------------------------- SCRIPT OF THE METACODDEM PROJECT ------------------------- %%%
%%% --------------- ("METAcognitive COntrol During DEcision-Making" task) --------------- %%%
%%% ------------------------------------------------------------------------------------- %%%
%%% ------------------------------------------------------------------------------------- %%%

%%% Author: Maxime Maheu
%%% Copyright (C) 2014

%%% * M1 Cogmaster
%%% * Behavior, Emotion and Basal Ganglia team
%%% * Brain and Spine Institute

%%% This program was written to study the computational and behavioral determinants of
%%% metacognitive control during perceptual decision making (with multi-sampling)

%%% ------------------------------------------------------------------------------------- %%% 

%% Clear the workspace, set the diary and the recording file

% Clear the workspace and the command window, then set the diary
clc;
clear all;

% Define in which context the task will be displayed (1: Individual testing, 2: LEEP testing, 3: Script test)
DATA.Subject.Context = 2;

% Add functions folders to Matlab path
addpath('Draw_functions');
addpath('OptimDesign_functions');
addpath('PTB_functions');
addpath('VBA');
addpath('VBA\subfunctions');
addpath('VBA\stats&plots');
addpath('VBA\classification');

% Save on which computer the subject performed the task
PsychJavaTrouble();
DATA.Subject.Computer = java.net.InetAddress.getLocalHost;
DATA.Subject.IP = char(DATA.Subject.Computer.getHostAddress);

% If we are in an individual testing condition
if (DATA.Subject.Context == 1)
    % Manually enter subject information ...
    DATA.Subject.Number = randi(1000,1,1);
    DATA.Subject.Date = datestr(now);
    DATA.Subject.Group = upper(input('Subject group (HS/OCD/DLGG)? ', 's'));
    DATA.Subject.Age = str2double(input('Subject age? ', 's'));
    DATA.Subject.Initials = upper(input('Subject initials? ', 's'));
    DATA.Subject.Handedness = upper(input('Subject handedness (L/R)? ', 's'));
    DATA.Subject.Gender = upper(input('Subject gender (M/F)? ', 's'));
    % ... and design information
    DATA.Subject.Design = input('Design (1 for 2AFC and 2 for clockFC)? ');
    DATA.Subject.Optimization = input('Design optimization (1 for Yes and 0 for No)? ');
    DATA.Subject.Phasis = 123; % input('Phasis (123/12/13/23/3)? ');
    DATA.Subject.Phasis_list = char(num2str(sort(DATA.Subject.Phasis))) - 48;
    % If the phasis 1 is skipped then provide psychometric parameters
    if (any(DATA.Subject.Phasis_list == 1))
        DATA.Fit.Psychometric.SigFit(1) = str2double(input('Mu? '));
        DATA.Fit.Psychometric.SigFit(2) = str2double(input('Sigma? '));
    end
    DATA.Files.Name = ['MetaCoDDeM_' num2str(DATA.Subject.Group) '_' DATA.Subject.Initials '_' num2str(DATA.Subject.Number)];
    
% If the testings are made at the LEEP
elseif (DATA.Subject.Context == 2)
    % Save the last two digits of the IP address
    DATA.Subject.Number = DATA.Subject.IP(length(DATA.Subject.IP) - 1:length(DATA.Subject.IP));
    DATA.Subject.Date = datestr(now);
    % Do not record any information about the subject (already provide by the initial questionnaire
    DATA.Subject.Group = 'HS';
    DATA.Subject.Age = NaN;
    DATA.Subject.Initials = 'LEEP';
    DATA.Subject.Handedness = 'NaN';
    DATA.Subject.Gender = 'NaN';
    % Display the 2AFC design with bayesian optimisation
    DATA.Subject.Design = 1;
    DATA.Subject.Optimization = 1;
    DATA.Subject.Phasis = 123;
    DATA.Subject.Phasis_list = char(num2str(sort(DATA.Subject.Phasis))) - 48;
    DATA.Files.Name = 'Data';
    
% If it is a test of the script
elseif (DATA.Subject.Context == 3)
    % Set a diary
    diary 'MetaCoDDeM_diary.txt';
    % Do not record any information about the subject
    DATA.Subject.Number = DATA.Subject.IP(length(DATA.Subject.IP) - 1:length(DATA.Subject.IP)); % Get IP adress and save the last two digits
    DATA.Subject.Date = datestr(now);
    DATA.Subject.Group = 'TEST';
    DATA.Subject.Age = NaN;
    DATA.Subject.Initials = 'TEST';
    DATA.Subject.Handedness = 'NaN';
    DATA.Subject.Gender = 'NaN';
    % Display the 2AFC design without bayesian optimisation
    DATA.Subject.Design = 1;
    DATA.Subject.Optimization = 0;
    DATA.Subject.Phasis = 123;
    DATA.Subject.Phasis_list = char(num2str(sort(DATA.Subject.Phasis))) - 48;
    DATA.Files.Name = 'Data';
end

mkdir(DATA.Files.Name);

%% Define task parameters

% Set frequently used colors
colors.black = [0, 0, 0];
colors.white = [255, 255, 255];
colors.gray = [128, 128, 128];
colors.red = [255, 0, 0];

% Set frequently used keys
KbName('UnifyKeyNames');
keys.up = KbName('UpArrow');
keys.down = KbName('DownArrow');
keys.right = KbName('RightArrow');
keys.left = KbName('LeftArrow');
keys.space = KbName('space');

% Set display parameters
display.screenNum = max(Screen('Screens'));
display.bkColor = colors.black;
display.dist = 60; % cm
display.width = 30; % cm
display.skipChecks = 1; % Avoid Screen's timing checks and verbosity
display.text.font = 'Arial'; % Define font

% Set paradigm parameters
if (DATA.Subject.Design == 1)
    % Margin between the 2 alternative fored-choice
    DATA.Paradigm.Step = 180;
elseif (DATA.Subject.Design == 2)
    % Margin between dots orientation and between clock ticks
    DATA.Paradigm.Step = 15;
end
display.scale = 10;
display.tick = display.scale/2;
display.rect = display.scale;

% Set a correponding table between dots angle (classic) and line angle (trigonometric)
% If it is a 2AFC design
if (DATA.Subject.Design == 1)
    display.table = [270, 90];
% If it is a "clock" design
elseif (DATA.Subject.Design == 2)
    display.table_a = 0:DATA.Paradigm.Step:359;
    display.table_b = 90:-DATA.Paradigm.Step:0;
    display.table_c = 360:-DATA.Paradigm.Step:91;
    display.table_c(:,1) = [];
    display.table = [display.table_a; display.table_b, display.table_c];
end
DATA.Fit.Psychometric.Chance = 1/length(display.table);

% Define dot parameters
dots.nDots = round(1.5*(2*pi*((display.scale/2)^2))); % Compute the number of dots based on the aperture size
dots.speed = 5;
dots.lifetime = 12;
dots.apertureSize = [display.scale display.scale];
dots.center = [0, 0];
dots.color = colors.white;
dots.size = 5;
dots.duration = 0.750; % miliseconds

%% Define phasis parameters

% For phasis 1 (calibration phasis),

% Temporary define a certain number of trials (the bayesian optimization will reduce it later)
DATA.Paradigm.Phasis1.Trials = 70;
% If the bayesian optimization is not activate, then screen the possible coherence levels window
if (DATA.Subject.Optimization == 0)
    % Define the step
    DATA.Paradigm.Phasis1.Coherences_margin = 0.1;
    % Define all the coherences level to display
    DATA.Paradigm.Phasis1.Coherences_level = 0.1:DATA.Paradigm.Phasis1.Coherences_margin:(1 - DATA.Paradigm.Phasis1.Coherences_margin);
    % Transform it into a column
    DATA.Paradigm.Phasis1.Coherences_level = transpose(DATA.Paradigm.Phasis1.Coherences_level);
    % Set a number of trials per coherence level
    if (DATA.Subject.Context ~= 3)
        DATA.Paradigm.Phasis1.Coherences_number = 15;
    % If we are in the test context, display only one trial per coherence level
    elseif (DATA.Subject.Context == 3)
        DATA.Paradigm.Phasis1.Coherences_number = 1;
    end
    % Repeat each coherence level a certain number of time (the number of trials per coherence level basically)
    DATA.Paradigm.Phasis1.Coherences = repmat(DATA.Paradigm.Phasis1.Coherences_level, DATA.Paradigm.Phasis1.Coherences_number, 1);
    % Randomly shuffle it
    DATA.Paradigm.Phasis1.Coherences = DATA.Paradigm.Phasis1.Coherences(randperm(length(DATA.Paradigm.Phasis1.Coherences)), 1);
    % Get the total number of trials in the first phasis
    DATA.Paradigm.Phasis1.Trials = size(DATA.Paradigm.Phasis1.Coherences, 1);
elseif (DATA.Subject.Optimization == 1)
    % Define the psychometric function
    DATA.Fit.Psychometric.SigFunc = @g_sigm_binomial;
    DATA.Fit.Psychometric.Estimated = [0;0];
    DATA.Fit.Psychometric.EstimatedVariance = DATA.Paradigm.Phasis1.Trials*eye(2);
    DATA.Fit.Psychometric.GridU = 0.01:0.01:1 ;
end

% For phasis 2 (evidence accumulation phasis),

% Define the maximum number of time a RDK will be displayed
DATA.Paradigm.Phasis2.Viewing_number = 2;
% Define the increasing facility indexes
DATA.Paradigm.Phasis2.Facility_levels = [-1, 0, 0.05, 0.10, 0.15];
% Define the number of trials per accuracy level
DATA.Paradigm.Phasis2.Accuracies_number = 10;
% If we are in the test context, display only one trial per accuracy level
if (DATA.Subject.Context == 3)
    DATA.Paradigm.Phasis2.Accuracies_number = 1;
end
% Define the initial wanted performance (before increasing facility index) for one set of increasing difficulty indes
DATA.Paradigm.Phasis2.Accuracies_levels = DATA.Fit.Psychometric.Chance:(((1-((DATA.Paradigm.Phasis2.Viewing_number-1)*max(DATA.Paradigm.Phasis2.Facility_levels))-0.01)-(DATA.Fit.Psychometric.Chance))/15):(1-((DATA.Paradigm.Phasis2.Viewing_number-1)*max(DATA.Paradigm.Phasis2.Facility_levels))-0.01);
DATA.Paradigm.Phasis2.Accuracies_levels = (round(DATA.Paradigm.Phasis2.Accuracies_levels*100))/100;
DATA.Paradigm.Phasis2.Accuracies_levels = [DATA.Paradigm.Phasis2.Accuracies_levels(1), DATA.Paradigm.Phasis2.Accuracies_levels(round(median(1:length(DATA.Paradigm.Phasis2.Accuracies_levels)))), DATA.Paradigm.Phasis2.Accuracies_levels(length(DATA.Paradigm.Phasis2.Accuracies_levels))];
% Define the initial wanted performance (before increasing facility index) for the total number of trials
DATA.Paradigm.Phasis2.Accuracies = repmat(DATA.Paradigm.Phasis2.Accuracies_levels, 1, size(DATA.Paradigm.Phasis2.Facility_levels, 2)*DATA.Paradigm.Phasis2.Accuracies_number);
% Transform it into a column
DATA.Paradigm.Phasis2.Accuracies = transpose(DATA.Paradigm.Phasis2.Accuracies);
% Randomly shuffle it
DATA.Paradigm.Phasis2.Accuracies = DATA.Paradigm.Phasis2.Accuracies(randperm(length(DATA.Paradigm.Phasis2.Accuracies)), 1);
% Define all the increasing facility index (for each trial)
DATA.Paradigm.Phasis2.Facilities = repmat(DATA.Paradigm.Phasis2.Facility_levels, 1, size(DATA.Paradigm.Phasis2.Accuracies_levels, 2)*DATA.Paradigm.Phasis2.Accuracies_number);
% Transform it into a column
DATA.Paradigm.Phasis2.Facilities = transpose(DATA.Paradigm.Phasis2.Facilities);
% Randomly shuffle it
DATA.Paradigm.Phasis2.Facilities = DATA.Paradigm.Phasis2.Facilities(randperm(length(DATA.Paradigm.Phasis2.Facilities)), 1);
% Make a table of (i) basal performance level, (ii) increasing facility index, and (iii) final performance
for i = 1:1:size(DATA.Paradigm.Phasis2.Accuracies)
    DATA.Paradigm.Phasis2.Performances(i,1) = DATA.Paradigm.Phasis2.Accuracies(i);
    DATA.Paradigm.Phasis2.Performances(i,2) = DATA.Paradigm.Phasis2.Facilities(i);
    if (DATA.Paradigm.Phasis2.Facilities(i) ~= -1)
        DATA.Paradigm.Phasis2.Performances(i,3) = DATA.Paradigm.Phasis2.Accuracies(i) + DATA.Paradigm.Phasis2.Facilities(i);
    elseif (DATA.Paradigm.Phasis2.Facilities(i) == -1)
        DATA.Paradigm.Phasis2.Performances(i,3) = DATA.Paradigm.Phasis2.Accuracies(i);
    end
end
% Get the total number of trials in the second phasis
DATA.Paradigm.Phasis2.Trials = size(DATA.Paradigm.Phasis2.Performances, 1);

% For phasis 3 (information seeking phasis)
% Define the number of trials per accuracy level
DATA.Paradigm.Phasis3.Accuracies_number = 10;
% If we are in the test context, display only one trial per accuracy level
if (DATA.Subject.Context == 3)
    DATA.Paradigm.Phasis3.Accuracies_number = 1;
end
% Define the accuracy levels we want to test
DATA.Paradigm.Phasis3.Accuracies_levels = DATA.Fit.Psychometric.Chance:(((1-((DATA.Paradigm.Phasis2.Viewing_number-1)*max(DATA.Paradigm.Phasis2.Facility_levels))-0.01)-(DATA.Fit.Psychometric.Chance))/15):(1-((DATA.Paradigm.Phasis2.Viewing_number-1)*max(DATA.Paradigm.Phasis2.Facility_levels))-0.01);
DATA.Paradigm.Phasis3.Accuracies_levels = (round(DATA.Paradigm.Phasis3.Accuracies_levels*100))/100;
% Replicate it by the total number of trials
DATA.Paradigm.Phasis3.Accuracies = repmat(DATA.Paradigm.Phasis3.Accuracies_levels, 1, DATA.Paradigm.Phasis3.Accuracies_number);
% Transform it into a column
DATA.Paradigm.Phasis3.Accuracies = transpose(DATA.Paradigm.Phasis3.Accuracies);
% Randomly shuffle it
DATA.Paradigm.Phasis3.Performances = DATA.Paradigm.Phasis3.Accuracies(randperm(length(DATA.Paradigm.Phasis3.Accuracies)), 1);
% Get the total number of trials in the third phasis
DATA.Paradigm.Phasis3.Trials = size(DATA.Paradigm.Phasis3.Performances, 1);

% Get the total number of trials
DATA.Paradigm.Trials = DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials + DATA.Paradigm.Phasis3.Trials;
DATA.Paradigm.Trainings = 10;

% Choose a random stimulus direction for each trial among the possible ones
for i = 1:1:DATA.Paradigm.Trials
    DATA.Paradigm.Directions(i, 1) = display.table(1, randi(size(display.table, 2)));
end

% Define gains modalities (left column for wrong answers and right column for correct answers)
DATA.Points.Initial = 5000; % Define the initial gain
DATA.Points.Matrix.Phasis1 = [-20, 20]; % Define the gain matrix for phasis 1
DATA.Points.Matrix.Phasis2 = [-50, 50]; % Define the gain matrix for phasis 2
DATA.Points.Matrix.Phasis3 = [-190, 130; -110, 110; -90, 90; -70, 70; -50, 50]; % Define the gain matrix for phasis 3
DATA.Points.Matrix.Confidence = [-100, 50]; % Define the gain matrix for condidence steps

% Compute the maximum amount of points a subject can win
DATA.Points.Maximum = DATA.Points.Initial + ...
    (max(DATA.Points.Matrix.Phasis1)*DATA.Paradigm.Phasis1.Trials) + ...
    (max(DATA.Points.Matrix.Phasis2)*DATA.Paradigm.Phasis2.Trials) + ...
    (max(max(DATA.Points.Matrix.Phasis3(1,:)))*DATA.Paradigm.Phasis3.Trials) + ...
    (max(DATA.Points.Matrix.Confidence)*(DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials));

%% Start the trial
try    
    % Open a window, set the display matrix and get the center of the screen
    display = OpenWindow(display);
    display.center = display.resolution/2;
      
    % Set the first phasis
    Phasis_number = 1;
    Trial_number = 1;
    Training_trial = 1;
    
    % For each trial
    while (Training_trial <= DATA.Paradigm.Trainings) || (Trial_number <= DATA.Paradigm.Trials)

        % Get the direction of the stimulus
        dots.direction = DATA.Paradigm.Directions(Trial_number, 1);

        % If it is the first trial of the phasis, display instructions
        if (Training_trial == 1) || (Trial_number == DATA.Paradigm.Phasis1.Trials + 1) || (Trial_number == DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials + 1)
            drawInstructions(display, Phasis_number);
            % Wait for key press
            while KbCheck; end
            KbWait;
        end

        % Display the information that it is a new stimulus
        if (Phasis_number ~= 1) 
            drawText_MxM(display, [0, (display.scale/5)], 'Nouveau stimulus', colors.white, display.scale*4);
            drawText_MxM(display, [0, -(display.scale/5)], '(Appuyez sur n''importe quelle touche pour commencer)', colors.white, display.scale*2);
            Screen('Flip',display.windowPtr);
            % Wait for key press
            while KbCheck; end
            KbWait;
        end

        %% Display the stimulus 

        % For phasis 1
        if (Phasis_number == 1)
            % If the bayesian optimization is activate
            if (DATA.Subject.Optimization == 1)
                    if (Trial_number == 1)
                        % Initialize the Bayesian Optimizer
                        OptimDesign('initialize', DATA.Fit.Psychometric.SigFunc, DATA.Fit.Psychometric.Estimated, DATA.Fit.Psychometric.EstimatedVariance, DATA.Fit.Psychometric.GridU);
                    end
                    % If we reach the threshold, end the first phasis
%                     if (z < 0.05) && (x < 0.05)
%                         DATA.Paradigm.Phasis1.Trials = Trial_number;
%                         % Mettre à jour les variables de la Phase 1 en supprimant les lignes
%                         % DATA.Paradigm.Phasis1.Coherences(DATA.Paradigm.Phasis1.Trials:length(DATA.Paradigm.Phasis1.Coherences)) = [];
%                         % define the most informative dots motion coherence
%                     end
                % Find the most informative coherence level
                [DATA.Paradigm.Phasis1.Coherences(Trial_number)] = OptimDesign('nexttrial');
            end
            dots.coherence = DATA.Paradigm.Phasis1.Coherences(Trial_number);

        % For phasis 2,
        elseif (Phasis_number == 2)
            % Get a coherence level according to a given performance
            DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = ...
                solveSig(DATA.Fit.Psychometric.SigFit(1), DATA.Fit.Psychometric.SigFit(2), DATA.Paradigm.Phasis2.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials, 1));
            if (DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) > 1)
                DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = 1;
            elseif (DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) < 0)
                DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = 0;
            end
            dots.coherence = DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 1);

        % For phasis 3,
        elseif (Phasis_number == 3)
            % Get a coherence level according to a given performance
            DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) = ...
                solveSig(DATA.Fit.Psychometric.SigFit(1), DATA.Fit.Psychometric.SigFit(2), DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1));
            if (DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) > 1)
                DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) = 1;
            elseif (DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) < 0)
                DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) = 0;
            end
            dots.coherence = DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1);
        end

        % Draw fixation cross during 1 second
        display = drawFixationCross(display);
        waitTill(1);
        
        % Randomly choose a coherence level and a direction for training trials
        if (Training_trial <= DATA.Paradigm.Trainings)
            dots.coherence = randi([10,100])/100;
            dots.direction = display.table(1, randi(size(display.table, 2)));
        end

        % Show the stimulus
        movingDots_MxM(display, dots, dots.duration, DATA.Paradigm.Step, DATA.Subject.Design);

        % Black screen during 200 miliseconds
        drawBlackScreen(display);
        waitTill(0.2);

        % For each review
        for Review = 2:1:DATA.Paradigm.Phasis2.Viewing_number

            % If we have to display a second sample of stimulus
            if (Phasis_number == 2) && (isnan(DATA.Paradigm.Phasis2.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials, 2)) == 0)

                % Get again a coherence level according to a given performance
                DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 3) = ...
                    solveSig(DATA.Fit.Psychometric.SigFit(1), DATA.Fit.Psychometric.SigFit(2), DATA.Paradigm.Phasis2.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials, 3));
                if (DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 3) > 1)
                    DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 3) = 1;
                end
                dots.coherence = DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 3);

                % Save the difference between the first sample coherence and the second sample one
                DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 2) ...
                    = DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 3) - DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 1);                

                % Draw fixation cross during 1 second
                display = drawFixationCross(display);
                waitTill(1);

                % Show the stimulus
                movingDots_MxM(display, dots, dots.duration, DATA.Paradigm.Step, DATA.Subject.Design);

                % Black screen during 200 miliseconds
                drawBlackScreen(display);
                waitTill(0.2);

            % If we did not have to display a second sample of stimulus, update the coherences lists
            elseif (Phasis_number == 2) && (isnan(DATA.Paradigm.Phasis2.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials, 2)) == 1)
                DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 2) = NaN;
                DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 3) = DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 1);
            end
        end

        %% Type II answer (control)

        % For phasis 3
        if (Phasis_number == 3)
            display.control = 1;
            startTime = GetSecs;
            while true
                [keyIsDown, timeSecs, keyCode] = KbCheck;

                % Display proactive information seeking window
                drawT3Info(display, display.control, DATA.Points.Matrix.Phasis3);

                % Check the keys press
                if keyIsDown

                    % If subject needs additional information, get the easiness increasing level he choose
                    if keyCode(keys.left)
                        display.control = display.control - 1;
                    elseif keyCode(keys.right)
                        display.control = display.control + 1;
                    end

                    % Define some precautions about the cursor
                    if (display.control < 1)
                        display.control = 1;
                    elseif (display.control > 5)
                        display.control = 5;
                    end

                    % Get the information seeking level (easiness increasing)
                    if keyCode(keys.space)

                        % Get the metacognitive control reaction time
                        DATA.Answers.RT3brut(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) = (timeSecs - startTime)*1000;

                        % If the subject has choosen not to see a new stimulus sample
                        if (display.control == 1)
                            % Update the targetted performance level
                            DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2) = -1;
                            DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3) = DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1);

                            % If the subject has choosen to see a new stimulus sample
                        elseif (display.control == 2 || 3 || 4 || 5)
                            % Update the targetted performance level lists
                            DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2) = DATA.Paradigm.Phasis2.Facility_levels(display.control);
                            DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3) ...
                                = DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) + DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2);
                        end

                        waitTill(0.2);
                        break;
                    end
                waitTill(0.05);
                end
            end

            % If control answer is not different from the initial position of the cursor, do not correct the reaction time
            if (display.control == 1)
                DATA.Answers.RT3corr(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) = DATA.Answers.RT3brut(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1);
            % Otherwise, correct it based on its distance from the initial position of the cursor
            elseif (display.control ~= 1)
                DATA.Answers.RT3corr(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) = DATA.Answers.RT3brut(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1)/abs(1 - display.control);
            end

            % If the subject has choosen not to see a new stimulus sample
            if (DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2) == -1)
                % Update the level of coherence
                DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2) = -1;
                DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3) = DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1);

            % If the subject has choosen to see a new stimulus sample
            elseif (any(DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2) == DATA.Paradigm.Phasis2.Facility_levels(2:length(DATA.Paradigm.Phasis2.Facility_levels))) == 1)

                % Get a coherence level according to the performance we have to reach given the easiness increasing the subject chose                
                DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3) = ...
                    solveSig(DATA.Fit.Psychometric.SigFit(1), DATA.Fit.Psychometric.SigFit(2), DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3));
                if (DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3) > 1)
                    DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3) = 1;
                end
                dots.coherence = DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3);

                % Save the difference between the first sample coherence and the second sample one
                DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2) ...
                    = DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3) - DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1);

                % Draw fixation cross during 1 second
                display = drawFixationCross(display);
                waitTill(1);

                % Show the stimulus
                movingDots_MxM(display, dots, dots.duration, DATA.Paradigm.Step, DATA.Subject.Design);
            end

            % Black screen during 200 miliseconds
            drawBlackScreen(display);
            waitTill(0.2);
        end

        %% Type I answer

        % For 2AFC design
        if (DATA.Subject.Design == 1)
            % At the beginning, do not show any cursor
            display.index = 0;
            DATA.Answers.Initial_Direction(Trial_number, 1) = 0;
        % For "clock" design
        elseif (DATA.Subject.Design == 2)
            % At the beginning, set the array at 0°
            display.index = 1; % Column number
            display.line = display.table(2, display.index); % Correspondant
            DATA.Answers.Initial_Direction(Trial_number, 1) = display.line;
        end

        startTime = GetSecs;
        while true
            [keyIsDown, timeSecs, keyCode] = KbCheck;

            % For 2AFC design
            if (DATA.Subject.Design == 1)
                % Update the cursor according to key press
                drawT1Binary(display, Phasis_number, DATA.Points.Matrix.Phasis1, DATA.Points.Matrix.Phasis2, DATA.Points.Matrix.Phasis3);
            % For "clock" design
            elseif (DATA.Subject.Design == 2)
                % Update the arrow according to key press
                drawT1Clock(display, DATA.Paradigm.Step, Phasis_number, DATA.Points.Matrix.Phasis1, DATA.Points.Matrix.Phasis2, DATA.Points.Matrix.Phasis3);
            end

            % Check the keys press
            if keyIsDown

              % If the right arrow is pressed
              if keyCode(keys.right)
                  % For 2AFC design,
                    if (DATA.Subject.Design == 1)
                        % Choose right answer
                        display.index = 2;
                    % For "clock" design
                    elseif (DATA.Subject.Design == 2)
                        % Increase angle with 1 step
                        display.index = display.index + 1;
                        if (display.index > size(display.table, 2))
                            display.index = 1;
                        end
                        display.line = display.table(2, display.index); 
                    end

                % If the left arrow is pressed
                elseif keyCode(keys.left)
                    % For 2AFC design
                    if (DATA.Subject.Design == 1)
                        % Choose left answer
                        display.index = 1;
                    % For "clock" design,
                    elseif (DATA.Subject.Design == 2)
                        % Decrease angle with minus 1 step
                        display.index = display.index - 1;
                        if display.index == 0
                            display.index = size(display.table, 2);
                        end
                        display.line = display.table(2, display.index); 
                    end

                % If space key is pressed
                elseif keyCode(keys.space)
                    if (display.index ~= 0)
                        % Get the perceptual reaction time
                        DATA.Answers.RT1brut(Trial_number, 1) = (timeSecs - startTime)*1000;
                        % Save the subject answer
                        DATA.Answers.Direction(Trial_number, 1) = display.table(1, display.index);
                        waitTill(0.2);
                        break;
                    end
              end

              waitTill(0.05);  
            end
        end

        % If perceptual answer is not different from the initial position of the cursor, do not correct the reaction time
        if DATA.Answers.Initial_Direction(Trial_number, 1) == DATA.Answers.Direction(Trial_number, 1)
            DATA.Answers.RT1corr(Trial_number, 1) = DATA.Answers.RT1brut(Trial_number, 1);
        % If perceptual answer is different from the initial position of the cursor
        elseif DATA.Answers.Initial_Direction(Trial_number, 1) ~= DATA.Answers.Direction(Trial_number, 1)
            % For 2AFC design
            if (DATA.Subject.Design == 1)
                % Do not correct the reaction time
                DATA.Answers.RT1corr(Trial_number, 1) = DATA.Answers.RT1brut(Trial_number, 1);
            % For "clock" design
            elseif (DATA.Subject.Design == 2)
                % Correct the reaction time based on its distance from the initial position of the arrow
                DATA.Answers.RT1corr(Trial_number, 1) = DATA.Answers.RT1brut(Trial_number, 1)/abs(DATA.Answers.Initial_Direction(Trial_number, 1) - DATA.Answers.Direction(Trial_number, 1));
            end
        end

        % For 2AFC design, compute perceptual performance and classify the answer according to signal detection theory
        if (DATA.Subject.Design == 1)
            % If it was a leftward moving stimulus and the subject give a correct answer (left)
            if (DATA.Paradigm.Directions(Trial_number, 1) == 270) && (DATA.Answers.Direction(Trial_number, 1) == 270)
                DATA.Answers.Correction(Trial_number, 1) = 1; % Correct answer
                DATA.Answers.Label(Trial_number, 1) = 1; % Hit
            end
            % If it was a leftward moving stimulus and the subject give a wrong answer (right)
            if (DATA.Paradigm.Directions(Trial_number, 1) == 270) && (DATA.Answers.Direction(Trial_number, 1) == 90)
                DATA.Answers.Correction(Trial_number, 1) = 0; % Wrong answer
                DATA.Answers.Label(Trial_number, 1) = 2; % False alarm
            end
            % If it was a rightward moving stimulus and the subject give a wrong answer (left)
            if (DATA.Paradigm.Directions(Trial_number, 1) == 90) && (DATA.Answers.Direction(Trial_number, 1) == 270)
                DATA.Answers.Correction(Trial_number, 1) = 0; % Wrong answer
                DATA.Answers.Label(Trial_number, 1) = 3; % Miss
            end
            % If it was a rightward moving stimulus and the subject give a correct answer (right)
            if (DATA.Paradigm.Directions(Trial_number, 1) == 90) && (DATA.Answers.Direction(Trial_number, 1) == 90)
                DATA.Answers.Correction(Trial_number, 1) = 1; % Correct answer
                DATA.Answers.Label(Trial_number, 1) = 4; % Correct rejection
            end

        % For "clock" design, simply compute perceptual performance
        elseif (DATA.Subject.Design == 2)
            % If the answer is equal to the actual direction, save 1
            if DATA.Paradigm.Directions(Trial_number, 1) == DATA.Answers.Direction(Trial_number, 1)
                DATA.Answers.Correction(Trial_number, 1) = 1;
            % If it is not, save 0
            elseif DATA.Paradigm.Directions(Trial_number, 1) ~= DATA.Answers.Direction(Trial_number, 1)
                DATA.Answers.Correction(Trial_number, 1) = 0;
            end
        end
        
        % During the first phasis, if optimization option is enabled
        if (Phasis_number == 1) && (DATA.Subject.Optimization == 1)
            % Register the response made by the subject
            OptimDesign('register', DATA.Answers.Correction(Trial_number, 1));
            %DATA.Paradigm.Phasis1.Coherences(Trial_number) = coh;
        end

        % Get the amount of "perceptual" gain
        if (Phasis_number == 1)
            % Find the gain in the phasis 1 gain matrix, thanks to correction
            DATA.Points.Counter.Type_I(Trial_number, 1) = DATA.Points.Matrix.Phasis1(DATA.Answers.Correction(Trial_number, 1) + 1);
        elseif (Phasis_number == 2)
            % Find the gain in the phasis 2 gain matrix, thanks to correction
            DATA.Points.Counter.Type_I(Trial_number, 1) = DATA.Points.Matrix.Phasis2(DATA.Answers.Correction(Trial_number, 1) + 1);
        elseif (Phasis_number == 3)
            % Find the gain in the phasis 3 gain matrix, thanks to correction and easiness level
            DATA.Points.Counter.Type_I(Trial_number, 1) = DATA.Points.Matrix.Phasis3(display.control, DATA.Answers.Correction(Trial_number, 1) + 1);
        end
                        
        % Black screen during 200 miliseconds
        drawBlackScreen(display);
        waitTill(0.2);

        %% Type II answer (monitoring)

        % If phasis 2 or 3 is displayed
        if (Phasis_number ~= 1) 

            % Set the initial position to the center of the scale
            display.rect = 0;
            DATA.Answers.Initial_Confidence(Trial_number, 1) = round(((display.rect + display.scale)/(2*display.scale))*100);

            startTime = GetSecs;
            while true
                [keyIsDown, timeSecs, keyCode] = KbCheck;

                % Update the red rectangle according to key press
                drawT2Rect(display, DATA.Points.Matrix.Confidence);

                % Check the keys press
                if keyIsDown

                        % If the right arrow is pressed
                        if keyCode(keys.right)
                            % Increase confidence score with +1%
                            display.rect = display.rect + ((2*display.scale)/100);
                            if display.rect > display.scale
                                display.rect = display.scale;
                            end

                        % If the left arrow is pressed
                        elseif keyCode(keys.left)
                            % Decrease confidence score with -1%
                            display.rect = display.rect - ((2*display.scale)/100);
                            if display.rect < -display.scale
                                display.rect = -display.scale;
                            end

                         % If space key is pressed
                         elseif keyCode(keys.space)
                            % Get the metacognitive monitoring reaction time
                            DATA.Answers.RT2brut(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = (timeSecs - startTime)*1000;
                            % Get the confidence score on a 100 scale
                            DATA.Answers.Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = round(((display.rect + display.scale) / (2 * display.scale)) * 100);
                            waitTill(0.2);
                            break;
                        end
                end
            end

            % If confidence answer is not different from the initial position of the cursor, do not correct reaction time
            if (DATA.Answers.Initial_Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) == DATA.Answers.Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1))
                DATA.Answers.RT2corr(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = DATA.Answers.RT2brut(Trial_number - DATA.Paradigm.Phasis1.Trials, 1);
            % If confidence answer is different from the initial position of the cursor, correct reaction time based on its distance from the initial position of the cursor
            elseif (DATA.Answers.Initial_Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) ~= DATA.Answers.Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1))
                DATA.Answers.RT2corr(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) ...
                    = DATA.Answers.RT2brut(Trial_number - DATA.Paradigm.Phasis1.Trials, 1)/abs(DATA.Answers.Initial_Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) - DATA.Answers.Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1));
            end

            % Get the amount of "confidence" gains

            % Get a first ticket (between 40 and 100)
            DATA.Points.Tickets.First(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = randi([40, 100]);
            % Get a second ticket (between 1 and 100)
            DATA.Points.Tickets.Second(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = randi([1, 100]);
            % If confidence is bigger than the first random ticket
            if (DATA.Answers.Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) >= DATA.Points.Tickets.First(Trial_number - DATA.Paradigm.Phasis1.Trials, 1))
                % The lottery ticket is the subject confidence
                DATA.Points.Tickets.Lottery(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = DATA.Answers.Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1);
            % If confidence is smaller than the first random ticket
            elseif (DATA.Answers.Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) < DATA.Points.Tickets.First(Trial_number - DATA.Paradigm.Phasis1.Trials, 1))
                % The lottery ticket is the first random ticket
                DATA.Points.Tickets.Lottery(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = DATA.Points.Tickets.First(Trial_number - DATA.Paradigm.Phasis1.Trials, 1);
            end
            % If the ticket lottery is bigger than the second random ticket
            if (DATA.Points.Tickets.Lottery(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) >= DATA.Points.Tickets.Second(Trial_number - DATA.Paradigm.Phasis1.Trials, 1))
                % Choose points at random
                DATA.Points.Counter.Type_II(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = DATA.Points.Matrix.Confidence(randi([1,2]));
            % If the ticket lottery is smaller than the second random ticket
            elseif (DATA.Points.Tickets.Lottery(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) < DATA.Points.Tickets.Second(Trial_number - DATA.Paradigm.Phasis1.Trials, 1))
                % Choose points given the subject performance
                DATA.Points.Counter.Type_II(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = DATA.Points.Matrix.Confidence(DATA.Answers.Correction(Trial_number, 1) + 1);
            end
        end

        %% Display a break screen

        % If we are in the middle of phasis 2 or phasis 3
        if ((Trial_number - DATA.Paradigm.Phasis1.Trials) == round(DATA.Paradigm.Phasis2.Trials/2)) || ((Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials) == round(DATA.Paradigm.Phasis3.Trials/2))
            % Display the break screen
            drawText_MxM(display, [0, (display.scale/5)], 'Faîtes une pause d''une ou deux minutes', colors.white, (display.scale*4));
            drawText_MxM(display, [0, -(display.scale/5)], '(Appuyez sur n''importe quelle touche pour continuer)', colors.white, (display.scale*2));
            Screen('Flip',display.windowPtr);
            % Wait for key press
            while KbCheck; end
            KbWait;
        end

        %% Psychometric fit

        if (Phasis_number == 1) && (Trial_number == DATA.Paradigm.Phasis1.Trials)

            % Black screen during 200 miliseconds
            drawBlackScreen(display);
            waitTill(0.2);

            % Make the subject waits while fitting the psychometric curve
            drawText_MxM(display, [0, 0], 'Veuillez patienter quelques secondes', colors.white, display.scale*4);
            Screen('Flip',display.windowPtr);

            % Make a coherence x performance table
            DATA.Fit.Psychometric.Coherence = unique(DATA.Paradigm.Phasis1.Coherences);
            DATA.Fit.Psychometric.Performance = grpstats(DATA.Answers.Correction, DATA.Paradigm.Phasis1.Coherences(1:DATA.Paradigm.Phasis1.Trials));
            DATA.Fit.Psychometric.Coherence = [0, DATA.Fit.Psychometric.Coherence];
            DATA.Fit.Psychometric.Performance = [DATA.Fit.Psychometric.Chance; DATA.Fit.Psychometric.Performance];
            %DATA.Fit.Psychometric.Coherence = [DATA.Fit.Psychometric.Coherence, 1];
            %DATA.Fit.Psychometric.Performance = [DATA.Fit.Psychometric.Performance, 1];

            % If the bayesian optimization is not activate
            if (DATA.Subject.Optimization == 0)
                % Define the psychometric function
                DATA.Fit.Psychometric.SigFunc = @(F, x)(1./(1 + exp(-F(1)*(x-F(2)))));
                if (DATA.Subject.Context ~= 3)
                    % Fit the psychometric function
                    DATA.Fit.Psychometric.SigFit = nlinfit(DATA.Fit.Psychometric.Coherence, DATA.Fit.Psychometric.Performance, DATA.Fit.Psychometric.SigFunc, [1, 1]);
                elseif (DATA.Subject.Context == 3)
                    % Define some default psychometric parameters
                    DATA.Fit.Psychometric.SigFit(1) = 10;
                    DATA.Fit.Psychometric.SigFit(2) = 0.5;
                end
                
            % If the bayesian optimization is activate
            elseif (DATA.Subject.Optimization == 1)
                % Define the psychometric function
                DATA.Fit.Psychometric.SigFunc = @(F, x)(1./(1 + exp(-F(1)*(x-F(2)))));
                % Get the psychometric parameters
                [DATA.Fit.Psychometric.muPhi, DATA.Fit.Psychometric.SigmaPhi] = OptimDesign('results');                
                DATA.Fit.Psychometric.SigFit(1) = DATA.Fit.Psychometric.muPhi(1);
                DATA.Fit.Psychometric.SigFit(2) = DATA.Fit.Psychometric.muPhi(2);
            end

            % Define the plot
            fig = figure(1);
            % Plot empirical points
            plot(DATA.Fit.Psychometric.Coherence, DATA.Fit.Psychometric.Performance, '*');
            hold on
            % Plot the sigmoid function
            plot(DATA.Fit.Psychometric.Coherence, DATA.Fit.Psychometric.SigFunc(DATA.Fit.Psychometric.SigFit, DATA.Fit.Psychometric.Coherence), 'g');
            hold on
            % Draw theoretic curve based on fit
            DATA.Fit.Psychometric.Theoretical_x = 0:0.001:1;
            DATA.Fit.Psychometric.Theoretical_y = sigmf(DATA.Fit.Psychometric.Theoretical_x, DATA.Fit.Psychometric.SigFit);
            plot(DATA.Fit.Psychometric.Theoretical_x, DATA.Fit.Psychometric.Theoretical_y, 'r-.');
            hold on
            % Draw chance level
            plot(DATA.Fit.Psychometric.Theoretical_x, DATA.Fit.Psychometric.Chance, 'c');
            % Write down the sigmoid parameters on the graph
            text(0.8, 0.2, strcat('Mu = ', num2str((round(DATA.Fit.Psychometric.SigFit(1)*100)/100))));
            text(0.8, 0.1, strcat('Sigma = ', num2str((round(DATA.Fit.Psychometric.SigFit(2)*100)/100))));
            % Set legend, axis and labels
            legend('Human data', 'Fit', 'Model data', 'Chance', 'location', 'northwest');
            axis([0, 1, 0, 1]);
            xlabel('Motion coherence'); 
            ylabel('Perceptual performance');

            % Get a coherence level according to a given performance
            DATA.Fit.Psychometric.C50 = solveSig(DATA.Fit.Psychometric.SigFit(1), DATA.Fit.Psychometric.SigFit(2), 0.5);
        end

        %% Display some variables in the command window during

        if (DATA.Subject.Context ~= 2) % Except for LEEP sessions
            if (Phasis_number == 1)
                if (Training_trial > DATA.Paradigm.Trainings)
                    disp([num2str(Phasis_number), '  ', ... % Phasis number
                          num2str(Trial_number), '  ', ... % Trial number
                          num2str(round(DATA.Paradigm.Phasis1.Coherences(Trial_number, 1)*100)/100), '  ', ... % Coherence level
                          num2str(DATA.Answers.Correction(Trial_number, 1))]); % Correction
                elseif (Training_trial <= DATA.Paradigm.Trainings)
                    disp([num2str(Phasis_number), '  ', ... % Phasis number
                          'T', num2str(Training_trial), '  ', ... % Trial number
                          num2str(round(dots.coherence*100)/100), '  ', ... % Coherence level
                          num2str(DATA.Answers.Correction(Trial_number, 1))]); % Correction
                end
            elseif (Phasis_number == 2)
                disp([num2str(Phasis_number), '  ', ... % Phasis number
                      num2str(Trial_number), '  ', ... % Trial number
                      num2str(round(DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 3)*100)/100), '  ', ... % Coherence level
                      num2str(DATA.Answers.Correction(Trial_number, 1)), '  ', ... % Correction
                      num2str(DATA.Answers.Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1))]); % Confidence
            elseif (Phasis_number == 3)
                disp([num2str(Phasis_number), '  ', ... % Phasis number
                      num2str(Trial_number), '  ', ... % Trial number
                      num2str(round(DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3)*100)/100), '  ', ... % Coherence level
                      num2str(DATA.Answers.Correction(Trial_number, 1)), '  ', ... % Correction
                      num2str(DATA.Answers.Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1)), '  ', ... % Confidence
                      num2str(DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2))]); % Information seeking
            end
        end

        %% Switch between phasis

        % Switch to phasis 2 when all the phasis 1 trials have been displayed
        if (Trial_number == DATA.Paradigm.Phasis1.Trials)
            Phasis_number = 2;
        end

        % Switch to phasis 3 when all the phasis 2 trials have been displayed
        if (Trial_number == DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials)
            Phasis_number = 3;
        end

        % Black screen during 200 miliseconds
        drawBlackScreen(display);
        waitTill(0.2);

        %% Switch between trials

        % Display the next training trial
        Training_trial = Training_trial + 1;

        % If the training has been completly made, then display the next testing trial
        if (Training_trial > DATA.Paradigm.Trainings + 1)
            Trial_number = Trial_number + 1;
        end
        
    save(DATA.Files.Name, 'DATA'); % à SUPPRIMER
    
    end
    
    %% Get the compensation payment and display it

    % Set a precaution if only first phasis has been displayed (without confidence recordings)
    if (any(DATA.Subject.Phasis_list == 2) == 0) && (any(DATA.Subject.Phasis_list == 3) == 0)
        DATA.Points.Counter.Type_II = 0;
    end
    
    % Regroup points in few categories
    DATA.Points.Perceptual.Phasis1 = sum(DATA.Points.Counter.Type_I(1:DATA.Paradigm.Phasis1.Trials));
    DATA.Points.Perceptual.Phasis2 = sum(DATA.Points.Counter.Type_I((DATA.Paradigm.Phasis1.Trials + 1):(DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials)));
    DATA.Points.Confidence.Phasis2 = sum(DATA.Points.Counter.Type_II(1:DATA.Paradigm.Phasis2.Trials));
    DATA.Points.Perceptual.Phasis3 = sum(DATA.Points.Counter.Type_I((DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials + 1):DATA.Paradigm.Trials));
    DATA.Points.Confidence.Phasis3 = sum(DATA.Points.Counter.Type_II((DATA.Paradigm.Phasis2.Trials + 1):(DATA.Paradigm.Phasis2.Trials + DATA.Paradigm.Phasis3.Trials)));

    % Convert points in money
    DATA.Points.Total = (DATA.Points.Initial + sum(DATA.Points.Counter.Type_I) + sum(DATA.Points.Counter.Type_II));
    DATA.Points.Money = (DATA.Points.Total/DATA.Points.Maximum)*20;

%     % If the points sum is negative
%     if (((DATA.Points.Initial + sum(DATA.Points.Counter.Type_I) + sum(DATA.Points.Counter.Type_II))/1000) <= 0)
%         % Reset it at its initial level
%         DATA.Points.Money = round(DATA.Points.Initial/1000);
%     % If the points sum is negative
%     elseif (((DATA.Points.Initial + sum(DATA.Points.Counter.Type_I) + sum(DATA.Points.Counter.Type_II))/1000) > 0)
%         % Convert it in money
%         DATA.Points.Money = round((DATA.Points.Initial + sum(DATA.Points.Counter.Type_I) + sum(DATA.Points.Counter.Type_II))/1000);
%     end

    % Born the amount of money a subject can win
    if (DATA.Points.Money < 5) % 5 euros minimum
        DATA.Points.Money = round(DATA.Points.Initial/1000);
    elseif (DATA.Points.Money > 20) % 20 euros maximum
        DATA.Points.Money = round(4*(DATA.Points.Initial/1000));
    end

    % Display end screen
    if (DATA.Subject.Context == 2)
        drawText_MxM(display, [0, -(display.scale/5)], strcat('Merci d''avoir participé. Vous avez gagné  ', num2str(DATA.Points.Money), ' euros.'), colors.white, display.scale*4);
        drawText_MxM(display, [0, (display.scale/5)], 'Vous pouvez maintenant venir chercher vos gains en salle de contrôle.', colors.white, display.scale*4);
        Screen('Flip', display.windowPtr);
    end
    
    %% Save a table for further import in DMAT

    % For phasis 1

    % Make a list of all possible coherence levels
    DATA.Paradigm.Phasis1.Conditions = sort(unique(DATA.Paradigm.Phasis1.Coherences));
    % Attribute a condition to each of these coherence levels
    for i = 1:1:size(DATA.Paradigm.Phasis1.Conditions)
        DATA.Paradigm.Phasis1.Conditions(i,2) = i;
    end
    % For each phasis 1 trial, get its associated condition based on its coherence level
    for i = 1:1:size(DATA.Paradigm.Phasis1.Coherences,1)
        DATA.Fit.DMAT.Phasis1.Input(i,1) = find(DATA.Paradigm.Phasis1.Conditions(:,1) == DATA.Paradigm.Phasis1.Coherences(i));
    end
    % For each phasis 1 trial, get its associated correction
    DATA.Fit.DMAT.Phasis1.Input(:,2) = DATA.Answers.Correction(1:DATA.Paradigm.Phasis1.Trials);
    % For each phasis 1 trial, get its associated RT
    DATA.Fit.DMAT.Phasis1.Input(:,3) = DATA.Answers.RT1corr(1:DATA.Paradigm.Phasis1.Trials);
    DMAT1 = DATA.Fit.DMAT.Phasis1.Input;

    % For phasis 2

    % Make a list of all possible performance levels ...
    DATA.Paradigm.Phasis2.Conditions(:,1) = repmat(unique(DATA.Paradigm.Phasis2.Performances(:,1)), size(DATA.Paradigm.Phasis2.Facility_levels, 2), 1);
    % ... and all possible increasing facility indexes
    DATA.Paradigm.Phasis2.Conditions(:,2) = sort(repmat(transpose(DATA.Paradigm.Phasis2.Facility_levels), size(DATA.Paradigm.Phasis2.Accuracies_levels, 2), 1));
    % Attribute a condition to each of these performance levels
    for i = 1:1:size(DATA.Paradigm.Phasis2.Conditions, 1)
        DATA.Paradigm.Phasis2.Conditions(i,3) = i;
    end
    for i = 1:1:size(DATA.Paradigm.Phasis2.Performances,1)
        DATA.Fit.DMAT.Phasis2.Input(i,1) = intersect(find(DATA.Paradigm.Phasis2.Conditions(:,1) == DATA.Paradigm.Phasis2.Performances(i,1)), find(DATA.Paradigm.Phasis2.Conditions(:,2) == DATA.Paradigm.Phasis2.Performances(i,2)));
    end
    % For each phasis 2 trial, get its associated correction
    DATA.Fit.DMAT.Phasis2.Input(:,2) = DATA.Answers.Correction(DATA.Paradigm.Phasis1.Trials + 1 : DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials);
    % For each phasis 2 trial, get its associated RT
    DATA.Fit.DMAT.Phasis2.Input(:,3) = DATA.Answers.RT1corr(DATA.Paradigm.Phasis1.Trials + 1 : DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials);
    DMAT2 = DATA.Fit.DMAT.Phasis2.Input;

    % For phasis 3
    
    % Make a list of all possible coherence levels
    DATA.Paradigm.Phasis3.Conditions = sort(unique(DATA.Paradigm.Phasis3.Performances(:,1)));
    % Attribute a condition to each of these coherence levels
    for i = 1:1:size(DATA.Paradigm.Phasis3.Conditions)
        DATA.Paradigm.Phasis3.Conditions(i,2) = i;
    end
    % For each phasis 1 trial, get its associated condition based on its coherence level
    for i = 1:1:size(DATA.Paradigm.Phasis3.Performances,1)
        DATA.Fit.DMAT.Phasis3.Input(i,1) = find(DATA.Paradigm.Phasis3.Conditions(:,1) == DATA.Paradigm.Phasis3.Performances(i));
    end
    % For each phasis 3 trial, get its associated correction
    DATA.Fit.DMAT.Phasis3.Input(:,2) = DATA.Answers.Correction(DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials + 1 : DATA.Paradigm.Trials);
    % For each phasis 3 trial, get its associated RT
    DATA.Fit.DMAT.Phasis3.Input(:,3) = DATA.Answers.RT1corr(DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials + 1 : DATA.Paradigm.Trials);
    DMAT3 = DATA.Fit.DMAT.Phasis3.Input;

    %% Save a table for further import in R

    % Define the table
    Headers = {'Number', 'Date', 'Group', 'Age', 'Gender', 'Design', 'Optimization', 'Sig_Mu', 'Sig_Sig', ... % Subject information
        'Trials', 'Phasis', 'A_perf', 'A_coh', 'Condition', 'Inc_perf', 'Inc_coh', 'B_perf', 'B_coh', 'Direction', ... % Independant variables
        'Answer', 'Accuracy', 'RT1_brut', 'RT1_corr', 'Confidence', 'RT2_brut', 'RT2_corr', 'Seek', 'RT3_brut', 'RT3_corr', 'Percept_points', 'Conf_points'}; % Dependant variables
    Rtable = cell(DATA.Paradigm.Trials+1,length(Headers));

    Rtable(1,:) = Headers;
    for i = 1:1:DATA.Paradigm.Trials
        Rtable{i+1,1} = strcat('#', num2str(DATA.Subject.Number)); % Number
        Rtable{i+1,2} = DATA.Subject.Date; % Date
        Rtable{i+1,3} = DATA.Subject.Group; % Group
        Rtable{i+1,4} = DATA.Subject.Age; % Age
        Rtable{i+1,5} = DATA.Subject.Gender; % Gender
        Rtable{i+1,6} = DATA.Subject.Design; % 2AFC or 24AFC
        Rtable{i+1,7} = DATA.Subject.Optimization; % With or without bayesian design optimizations
        Rtable{i+1,8} = DATA.Fit.Psychometric.SigFit(1); % Mu
        Rtable{i+1,9} = DATA.Fit.Psychometric.SigFit(2); % Sigma
        Rtable{i+1,10} = i; % Trials
        Rtable{i+1,19} = DATA.Paradigm.Directions(i); % Directions
        Rtable{i+1,20} = DATA.Answers.Direction(i); % Type I answers
        Rtable{i+1,21} = DATA.Answers.Correction(i); % Correction
        Rtable{i+1,22} = DATA.Answers.RT1brut(i); % Type I RT (brut)
        Rtable{i+1,23} = DATA.Answers.RT1corr(i); % Type I RT (corrected)
        Rtable{i+1,30} = DATA.Points.Counter.Type_I(i); % Perceptual points
    end
    % For phasis 1
    for i = 1:1:DATA.Paradigm.Phasis1.Trials
        Rtable{i+1,11} = 1; % Phasis
        Rtable{i+1,12} = NaN; % Performances 'A'
        Rtable{i+1,13} = DATA.Paradigm.Phasis1.Coherences(i); % Coherences 'A'
        Rtable{i+1,14} = DATA.Fit.DMAT.Phasis1.Input(i,1); % Conditions
        Rtable{i+1,15} = NaN; % Increasing performances
        Rtable{i+1,16} = NaN; % Increasing coherences
        Rtable{i+1,17} = NaN; % Performances 'B'
        Rtable{i+1,18} = NaN; % Coherences 'B'
        Rtable{i+1,24} = DATA.Answers.Confidence(i); % Type II (monitoring) answers
        Rtable{i+1,25} = DATA.Answers.RT2brut(i); % Type II (monitoring) RT (brut)
        Rtable{i+1,26} = DATA.Answers.RT2corr(i); % Type II (monitoring) RT (corrected)
        Rtable{i+1,27} = NaN; % Type II (control) answers
        Rtable{i+1,28} = NaN; % Type II (control) RT (brut)
        Rtable{i+1,29} = NaN; % Type II (control) RT (corrected)
        Rtable{i+1,31} = NaN; % Confidence points
    end
    % For phasis 2
    for i = 1:1:DATA.Paradigm.Phasis2.Trials
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,11} = 2; % Phasis
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,12} = DATA.Paradigm.Phasis2.Performances(i,1); % Performances 'A'
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,13} = DATA.Paradigm.Phasis2.Coherences(i,1); % Coherences 'A'
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,14} = DATA.Fit.DMAT.Phasis2.Input(i,1); % Conditions
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,15} = DATA.Paradigm.Phasis2.Performances(i,2); % Increasing performances
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,16} = DATA.Paradigm.Phasis2.Coherences(i,2); % Increasing coherences
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,17} = DATA.Paradigm.Phasis2.Performances(i,3); % Performances 'B'
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,18} = DATA.Paradigm.Phasis2.Coherences(i,3); % Coherences 'B'
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,24} = DATA.Answers.Confidence(i); % Type II (monitoring) answers
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,25} = DATA.Answers.RT2brut(i); % Type II (monitoring) RT (brut)
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,26} = DATA.Answers.RT2corr(i); % Type II (monitoring) RT (corrected)
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,27} = NaN; % Type II (control) answers
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,28} = NaN; % Type II (control) RT (brut)
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,29} = NaN; % Type II (control) RT (corrected)
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,31} = DATA.Points.Counter.Type_II(i); % Confidence points
    end
    % For phasis 3
    for i = 1:1:DATA.Paradigm.Phasis3.Trials
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,11} = 3; % Phasis
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,12} = DATA.Paradigm.Phasis3.Performances(i,1); % Performances 'A'
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,13} = DATA.Paradigm.Phasis3.Coherences(i,1); % Coherences 'A'
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,14} = DATA.Fit.DMAT.Phasis3.Input(i,1); % Conditions
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,15} = DATA.Paradigm.Phasis3.Performances(i,2); % Increasing performances
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,16} = DATA.Paradigm.Phasis3.Coherences(i,2); % Increasing coherences
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,17} = DATA.Paradigm.Phasis3.Performances(i,3); % Performances 'B'
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,18} = DATA.Paradigm.Phasis3.Coherences(i,3); % Coherences 'B'
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,24} = DATA.Answers.Confidence(i+DATA.Paradigm.Phasis2.Trials); % Type II (monitoring) answers
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,25} = DATA.Answers.RT2brut(i+DATA.Paradigm.Phasis2.Trials); % Type II (monitoring) RT (brut)
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,26} = DATA.Answers.RT2corr(i+DATA.Paradigm.Phasis2.Trials); % Type II (monitoring) RT (corrected)
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,27} = DATA.Paradigm.Phasis3.Performances(i,2); % Type II (control) answers
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,28} = DATA.Answers.RT3brut(i,1); % Type II (control) RT (brut)
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,29} = DATA.Answers.RT3corr(i,1); % Type II (control) RT (corrected)
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,31} = DATA.Points.Counter.Type_II(i+DATA.Paradigm.Phasis2.Trials); % Confidence points
    end

% In case of error
catch error_message
Screen('CloseAll');
rethrow(error_message);
end

%% Save files

% Go to the subject directory
cd(DATA.Files.Name);

% Save data for further import in Dift Diffusion Model or Linear Ballistic Accumulator model
save(strcat(DATA.Files.Name, '_DDM-LBA-1'), 'DMAT1');
save(strcat(DATA.Files.Name, '_DDM-LBA-2'), 'DMAT2');
save(strcat(DATA.Files.Name, '_DDM-LBA-3'), 'DMAT3');

% Save data
DATA.Paradigm.Stimulus = dots;
DATA.Paradigm.SetUp = display;
save(DATA.Files.Name, 'DATA');

% Save R table
cd ..
cell2csv(strcat(DATA.Files.Name, '/', DATA.Files.Name, '.csv'), Rtable);
cd(DATA.Files.Name);

% Save fit graph
saveas(fig, DATA.Files.Name, 'fig');

%% Close all

% Return to the task directory
cd ..

% Save final gain
dlmwrite('Gain.txt', [DATA.Points.Perceptual.Phasis1, DATA.Points.Perceptual.Phasis2, DATA.Points.Confidence.Phasis2, DATA.Points.Perceptual.Phasis3, DATA.Points.Confidence.Phasis3, DATA.Points.Money]);

% Wait 1 minute
if (DATA.Subject.Context == 2)
    waitTill(60);
end

% Close the diary
if (DATA.Subject.Context == 3)
    diary off;
end

% Then close the experiment
Screen('CloseAll');

% Clear all and quit
clear all;
if (DATA.Subject.Context == 2)
    exit;
end