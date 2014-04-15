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

DATA.Subject.Context = 3;

DATA.Subject.Computer = java.net.InetAddress.getLocalHost;
DATA.Subject.IP = char(DATA.Subject.Computer.getHostAddress);

if (DATA.Subject.Context == 1) % Indivudal testing
    DATA.Subject.Number = randi(1000,1,1);
    DATA.Subject.Date = datestr(now);
    DATA.Subject.Group = upper(input('Subject group (HS/OCD/DLGG)? ', 's'));
    DATA.Subject.Age = str2double(input('Subject age? ', 's'));
    DATA.Subject.Initials = upper(input('Subject initials? ', 's'));
    DATA.Subject.Handedness = upper(input('Subject handedness (L/R)? ', 's'));
    DATA.Subject.Gender = upper(input('Subject gender (M/F)? ', 's'));
    
    DATA.Subject.Design = input('Design (1 for 2AFC and 2 for clockFC)? ');
    DATA.Subject.Optimization = input('Design optimization (1 for Yes and 0 for No)? ');
    DATA.Subject.Phasis = 123; % input('Phasis (123/12/13/23/3)? ');
    DATA.Subject.Phasis_list = char(num2str(sort(DATA.Subject.Phasis))) - 48;
    if (any(DATA.Subject.Phasis_list == 1) == 0) % If the phasis 1 is skipped then provide psychometric parameters
        DATA.Fit.Psychometric.SigFit(1) = str2double(input('Mu? '));
        DATA.Fit.Psychometric.SigFit(2) = str2double(input('Sigma? '));
    end
    
elseif (DATA.Subject.Context == 2) % LEEP testings
    DATA.Subject.Number = DATA.Subject.IP(length(DATA.Subject.IP) - 1:length(DATA.Subject.IP)); % Get IP adress and save the last two digits
    DATA.Subject.Date = datestr(now);
    DATA.Subject.Group = 'HS';
    DATA.Subject.Age = NaN;
    DATA.Subject.Initials = 'LEEP';
    DATA.Subject.Handedness = 'NaN';
    DATA.Subject.Gender = 'NaN';

    DATA.Subject.Design = 1;
    DATA.Subject.Optimization = 1;
    DATA.Subject.Phasis = 123;
    DATA.Subject.Phasis_list = char(num2str(sort(DATA.Subject.Phasis))) - 48;
    
elseif (DATA.Subject.Context == 3) % Test
    diary 'MetaCoDDeM_diary.txt';
    
    DATA.Subject.Number = DATA.Subject.IP(length(DATA.Subject.IP) - 1:length(DATA.Subject.IP)); % Get IP adress and save the last two digits
    DATA.Subject.Date = datestr(now);
    DATA.Subject.Group  = 'TEST';
    DATA.Subject.Age = NaN;
    DATA.Subject.Initials = 'TEST';
    DATA.Subject.Handedness = 'NaN';
    DATA.Subject.Gender = 'NaN';

    DATA.Subject.Design = 1;
    DATA.Subject.Optimization = 0;
    DATA.Subject.Phasis = 123;
    DATA.Subject.Phasis_list = char(num2str(sort(DATA.Subject.Phasis))) - 48;
end

if (DATA.Subject.Context ~= 3)
    DATA.Files.Name = ['MetaCoDDeM_' num2str(DATA.Subject.Group) '_' DATA.Subject.Initials '_' num2str(DATA.Subject.Number)];
    mkdir(DATA.Files.Name); % Create the subject folder
end

%% Define task parameters

% Set frequently used colors
colors.black = [0, 0, 0];
colors.white = [255, 255, 255];
colors.gray = [128, 128, 128];
colors.red = [255, 0, 0];

% Set frequently used keys
keys.up = KbName('UpArrow');
keys.down = KbName('DownArrow');
keys.right = KbName('RightArrow');
keys.left = KbName('LeftArrow');
keys.space = KbName('space');

% Set paradigm parameters 
DATA.Paradigm.Step = 15; % Margin between dots orientation and so between clock ticks  
display.scale = 10;

% Set display parameters
display.screenNum = max(Screen('Screens'));
display.bkColor = colors.black;
display.dist = 60; % cm
display.width = 30; % cm
display.skipChecks = 1; % Avoid Screen's timing checks and verbosity

% Set up dot parameters
dots.nDots = round(1.5*(2*pi*((display.scale/2)^2))); % Calculate the number of dots based on the aperture size
dots.speed = 5;
dots.lifetime = 12;
dots.apertureSize = [display.scale display.scale];
dots.center = [0, 0];
dots.color = colors.white;
dots.size = 5;
dots.duration = 0.750; % miliseconds

% Set a correponding table between dots angle (classic) and line angle (trigonometric)
if (DATA.Subject.Design == 1) % If it is a 2AFC design
    display.T1.line.table = [270, 90];
elseif (DATA.Subject.Design == 2) % If it is a "clock" design
    display.T1.line.table_a = 0:DATA.Paradigm.Step:359;
    display.T1.line.table_b = 90:-DATA.Paradigm.Step:0;
    display.T1.line.table_c = 360:-DATA.Paradigm.Step:91;
    display.T1.line.table_c(:, 1) = [];
    display.T1.line.table = [display.T1.line.table_a; display.T1.line.table_b, display.T1.line.table_c];
end

% Set type I forms parameters
display.T1.tick = display.scale/2;
display.T1.circle.size = display.scale;
display.T1.circle.color = colors.white;
display.T1.line.size = display.scale;
if (DATA.Subject.Design == 1)
    display.T1.line.color = colors.white;
    display.T1.triangle.color = colors.white;
elseif (DATA.Subject.Design == 2)
    display.T1.line.color = colors.red;
    display.T1.triangle.color = colors.red;
end
display.T1.triangle.size = display.scale;
 
% Set type II forms parameters
display.T2.tick = display.scale/2;
display.T2.rect1.size = display.scale;
display.T2.rect1.color = colors.white;
display.T2.rect2.color = colors.red;

% Set the parameters for the phasis 1 (calibration phasis)
DATA.Paradigm.Phasis1.Trials = 100; % Temporary define a certain number of trials (the bayesian optimization will reduce it later)
if (DATA.Subject.Optimization == 0) % If the bayesian optimization is not activate, then screen the possible coherence levels window
    DATA.Paradigm.Phasis1.Coherences_margin = 0.1;
    DATA.Paradigm.Phasis1.Coherences_level = 0.1:DATA.Paradigm.Phasis1.Coherences_margin:(1 - DATA.Paradigm.Phasis1.Coherences_margin); % Define the list of coherence levels
    DATA.Paradigm.Phasis1.Coherences_level = transpose(DATA.Paradigm.Phasis1.Coherences_level); % Transform it into a column
    DATA.Paradigm.Phasis1.Coherences_number = 15; % Number of trials per coherence level
    if (DATA.Subject.Context == 3)
        DATA.Paradigm.Phasis1.Coherences_number = 1;
    end
    DATA.Paradigm.Phasis1.Coherences = repmat(DATA.Paradigm.Phasis1.Coherences_level, DATA.Paradigm.Phasis1.Coherences_number, 1); % Repeat each coherence level a certain number of time
    DATA.Paradigm.Phasis1.Coherences = DATA.Paradigm.Phasis1.Coherences(randperm(length(DATA.Paradigm.Phasis1.Coherences)), 1); % Randomly shuffle it
    DATA.Paradigm.Phasis1.Trials = size(DATA.Paradigm.Phasis1.Coherences, 1); % The phasis 1 total number of trials is the size of this coherence list
end

% Set the parameters for the phasis 2 (evidence accumulation phasis)
DATA.Paradigm.Phasis2.Viewing_number = 2; % Define the maximum number of time a RDK will be displayed
DATA.Paradigm.Phasis2.Facility_levels = [NaN, 0, 0.05, 0.10, 0.15]; % Define the increasing facility indexes
DATA.Paradigm.Phasis2.Accuracies_number = 10; % Define the number of trials per accuracy level
if (DATA.Subject.Context == 3)
    DATA.Paradigm.Phasis2.Accuracies_number = 1;
end
% Faire avec 3 des niveaux de performance testés en phase 3
DATA.Paradigm.Phasis2.Accuracies_levels = [0.10, 0.425, 0.75]; % Define the initial wanted performance (before increasing facility index) for one set of increasing difficulty indes
DATA.Paradigm.Phasis2.Accuracies = repmat(DATA.Paradigm.Phasis2.Accuracies_levels, 1, size(DATA.Paradigm.Phasis2.Facility_levels, 2)*DATA.Paradigm.Phasis2.Accuracies_number); % Define the initial wanted performance (before increasing facility index) for the total number of trials
DATA.Paradigm.Phasis2.Accuracies = transpose(DATA.Paradigm.Phasis2.Accuracies); % Transform it into a column
DATA.Paradigm.Phasis2.Accuracies = DATA.Paradigm.Phasis2.Accuracies(randperm(length(DATA.Paradigm.Phasis2.Accuracies)), 1); % Randomly shuffle it
DATA.Paradigm.Phasis2.Facilities = repmat(DATA.Paradigm.Phasis2.Facility_levels, 1, size(DATA.Paradigm.Phasis2.Accuracies_levels, 2)*DATA.Paradigm.Phasis2.Accuracies_number); % Define all the increasing facility index (for each trial)
DATA.Paradigm.Phasis2.Facilities = transpose(DATA.Paradigm.Phasis2.Facilities); % Transform it into a column
DATA.Paradigm.Phasis2.Facilities = DATA.Paradigm.Phasis2.Facilities(randperm(length(DATA.Paradigm.Phasis2.Facilities)), 1); % Randomly shuffle it
DATA.Paradigm.Phasis2.Performances = [DATA.Paradigm.Phasis2.Accuracies DATA.Paradigm.Phasis2.Facilities (DATA.Paradigm.Phasis2.Accuracies + DATA.Paradigm.Phasis2.Facilities)]; % Make a table of (i) basal performance level, (ii) increasing facility index, and (iii) final performance 
DATA.Paradigm.Phasis2.Trials = size(DATA.Paradigm.Phasis2.Performances, 1); % Get the total number of trials in the second phasis

% Set the parameters for the phasis 3 (information seeking phasis)
DATA.Paradigm.Phasis3.Accuracies_number = 10; % Define the number of trials per accuracy level
if (DATA.Subject.Context == 3)
    DATA.Paradigm.Phasis3.Accuracies_number = 1;
end
DATA.Paradigm.Phasis3.Accuracies_levels = 0.1:((1-((DATA.Paradigm.Phasis2.Viewing_number-1)*max(DATA.Paradigm.Phasis2.Facility_levels)))-0.1)/15:(1-((DATA.Paradigm.Phasis2.Viewing_number-1)*max(DATA.Paradigm.Phasis2.Facility_levels))); % Define the accuracy levels we want to test
DATA.Paradigm.Phasis3.Accuracies = repmat(DATA.Paradigm.Phasis3.Accuracies_levels, 1, DATA.Paradigm.Phasis3.Accuracies_number); % Define the accuracy levels we want to test for the total number of trials
DATA.Paradigm.Phasis3.Accuracies = transpose(DATA.Paradigm.Phasis3.Accuracies); % Transform it into a column
DATA.Paradigm.Phasis3.Performances = DATA.Paradigm.Phasis3.Accuracies(randperm(length(DATA.Paradigm.Phasis3.Accuracies)), 1); % Randomly shuffle it
DATA.Paradigm.Phasis3.Trials = size(DATA.Paradigm.Phasis3.Performances, 1); % Get the total number of trials in the third phasis

% Get the total number of trials
DATA.Paradigm.Trials = DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials + DATA.Paradigm.Phasis3.Trials;

% Choose a random stimulus direction for each trial among the possible ones
for i = 1:1:DATA.Paradigm.Trials
    DATA.Paradigm.Directions(i, 1) = display.T1.line.table(1, randi(size(display.T1.line.table, 2)));
end

% Define gains modalities (left column for wrong answers and right column for correct answers)
DATA.Points.Initial = 5000; % Define the initial gain
DATA.Points.Matrix.Phasis1 = [-20, 20]; % Define the gain matrix for phasis 1
DATA.Points.Matrix.Phasis2 = [-50, 50]; % Define the gain matrix for phasis 2
DATA.Points.Matrix.Phasis3 = [-200, 100; -80, 80; -70, 70; -60, 60; -50, 50]; % Define the gain matrix for phasis 3
DATA.Points.Matrix.Confidence = [-50, 100]; % Define the gain matrix for condidence steps

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
        
    for Trial_number = 1:1:DATA.Paradigm.Trials
        % Get the direction of the stimulus
        dots.direction = DATA.Paradigm.Directions(Trial_number, 1);

        % If it is the first trial of the phasis, display instructions
        if (Trial_number == 1) || (Trial_number == DATA.Paradigm.Phasis1.Trials + 1) || (Trial_number == DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials + 1)
            drawInstructions(display, Phasis_number);
        end

        % Display the information that it is a new stimulus
        if (Phasis_number ~= 1) 
            drawText_MxM(display, [0, (display.scale/5)], 'Nouveau stimulus', colors.white, display.scale*4);
            drawText_MxM(display, [0, -(display.scale/5)], '(Appuyez sur n''importe quelle touche pour commencer)', colors.white, display.scale*2);
            Screen('Flip',display.windowPtr);
            while KbCheck; end
            KbWait;
        end

        %% Display the stimulus 

        % For the phasis 1, if the bayesian optimization is activate, define the most informative dots motion coherence
        if (Phasis_number == 1)
            if (DATA.Subject.Optimization == 1)
                    if (Trial_number == 1)
                        a = 0;
                    elseif (Trial_number == 2)
                        a = 0;
                    end
                    % If we reach the threshold, end the first phasis
                    if (z < 0.05) && (x < 0.05)
                        DATA.Paradigm.Phasis1.Trials = Trial_number;
                    end
                % Find the most informative coherence level
                DATA.Paradigm.Phasis1.Coherences(Trial_number) = OptimDesign([], g_fname, dim, opt, u(1),'parameters', DATA.Subject.Design);
            end
            dots.coherence = DATA.Paradigm.Phasis1.Coherences(Trial_number);

        % For the phasis 2, get a coherence level according to a given performance
        elseif (Phasis_number == 2)
            syms Target_coherence
            DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) ...
                = double(solve((1./(1 + exp(-DATA.Fit.Psychometric.SigFit(1)*(Target_coherence - DATA.Fit.Psychometric.SigFit(2))))) ...
                == DATA.Paradigm.Phasis2.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials, 1)));
            dots.coherence = DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 1);

        % For the phasis 3, get a coherence level according to a given performance
        elseif (Phasis_number == 3)
            syms Target_coherence
            DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) ...
                = double(solve((1./(1 + exp(-DATA.Fit.Psychometric.SigFit(1)*(Target_coherence - DATA.Fit.Psychometric.SigFit(2))))) ...
                == DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1)));
            dots.coherence = DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1);
        end

        % Draw fixation cross during 2 seconds
        display = drawFixationCross(display);
        waitTill(2);

        % Show the stimulus
        movingDots_MxM(display, dots, dots.duration, DATA.Paradigm.Step, DATA.Subject.Design);

        % Black screen during 100 milisecond
        Screen('FillOval', display.windowPtr, display.bkColor);
        Screen('Flip',display.windowPtr);
        waitTill(0.1);

        % For each review
        for Review = 2:1:DATA.Paradigm.Phasis2.Viewing_number
            
            % If we have to display a second sample of stimulus
            if (Phasis_number == 2) && (isnan(DATA.Paradigm.Phasis2.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials, 2)) == 0)

                % Get again a coherence level according to a given performance
                syms Target_coherence
                DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 3) ...
                    = double(solve((1./(1 + exp(-DATA.Fit.Psychometric.SigFit(1)*(Target_coherence - DATA.Fit.Psychometric.SigFit(2))))) ...
                    == DATA.Paradigm.Phasis2.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials, 3)));
                dots.coherence = DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 3);
                % Save the difference between the first sample coherence and the second sample one
                DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 2) ...
                    = DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 3) - DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 1);                

                % Draw fixation cross during 2 seconds
                display = drawFixationCross(display);
                waitTill(2);

                % Show the stimulus
                movingDots_MxM(display, dots, dots.duration, DATA.Paradigm.Step, DATA.Subject.Design);

                % Black screen during 100 milisecond
                Screen('FillOval', display.windowPtr, display.bkColor);
                Screen('Flip',display.windowPtr);
                waitTill(0.1);
            
            % If we do not have to display a second sample of stimulus
            elseif (Phasis_number == 2) && (isnan(DATA.Paradigm.Phasis2.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials, 2)) == 1)
                DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 2) = NaN;
                DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 3) = DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 1);
            end
        end

        %% Type II answer (control)

        if (Phasis_number == 3)
            % Display choice
            display.T3.index = 1;
            startTime = GetSecs;
            while true
                % Check the keys press
                [keyIsDown, timeSecs, keyCode] = KbCheck;
                % Display proactive information seeking window
                drawT3Info(display, display.T3.index, DATA.Points.Matrix.Phasis3);
                if keyIsDown
                    
                        % If subject needs additional information, get the easiness increasing level he choose
                        if keyCode(keys.left)
                            display.T3.index = display.T3.index - 1;
                        elseif keyCode(keys.right)
                            display.T3.index = display.T3.index + 1;
                        end
                        % Precautions about the cursor
                        if (display.T3.index < 1)
                            display.T3.index = 1;
                        elseif (display.T3.index > 5)
                            display.T3.index = 5;
                        end
                        waitTill(0.1);

                        % Get the information seeking level (easiness increasing)
                        if keyCode(keys.space)
                            % Get the metacognitive control reaction time
                            DATA.Answers.RT3brut(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) = (timeSecs - startTime)*100;
                            % If the subject has choosen not to see a new stimulus sample
                            if (display.T3.index == 1)
                                % 
                                DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2) = NaN;
                                DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3) = DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1);
                            % If the subject has choosen to see a new stimulus sample
                            elseif (display.T3.index == 2 || 3 || 4 || 5)
                                % Update the targetted performance level
                                DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2) = DATA.Paradigm.Phasis2.Facility_levels(display.T3.index);
                                DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3) ...
                                    = DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) + DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2);
                            end
                            break;
                        end
                        waitTill(0.05);
                end
            end

            % Compute control RT (weighted according to the initial position of the cursor)
            if (display.T3.index == 1)
                DATA.Answers.RT3corr(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) = DATA.Answers.RT3brut(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1);
            elseif (display.T3.index ~= 1)
                DATA.Answers.RT3corr(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) = DATA.Answers.RT3brut(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1)/abs(1 - display.T3.index);
            end

            % If the subject has choosen not to see a new stimulus sample
            if (isnan(DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2)) == 1)
                
                % Update the level of coherence
                DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2) = NaN;
                DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3) = NaN;
            
            % If the subject has choosen to see a new stimulus sample
            elseif (any(DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2) == DATA.Paradigm.Phasis2.Facility_levels(2:5)) == 1) %%%%%% 2:5 éventuellement à modifier

                % Get a coherence level according to the performance we have to reach given the easiness increasing the subject chose
                syms Target_coherence
                DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3) ...
                    = double(solve((1./(1 + exp(-DATA.Fit.Psychometric.SigFit(1)*(Target_coherence - DATA.Fit.Psychometric.SigFit(2))))) ...
                    == DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3)));
                dots.coherence = DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3);
                % Save the difference between the first sample coherence and the second sample one
                DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2) ...
                    = DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3) - DATA.Paradigm.Phasis3.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1);

                % Draw fixation cross during 2 seconds
                display = drawFixationCross(display);
                waitTill(2);

                % Show the stimulus
                movingDots_MxM(display, dots, dots.duration, DATA.Paradigm.Step, DATA.Subject.Design);

                % Black screen during 100 milisecond
                Screen('FillOval', display.windowPtr, display.bkColor);
                Screen('Flip',display.windowPtr);
                waitTill(0.1);
            end
        end

        %% Type I answer

        % Get the response
        if (DATA.Subject.Design == 1)
            display.T1.line.index = 0;
            DATA.Answers.Initial_Direction(Trial_number, 1) = 0;
        elseif (DATA.Subject.Design == 2)
            display.T1.line.index = 1; % Column number
            display.T1.line.angle = display.T1.line.table(2, display.T1.line.index); % Correspondant
            DATA.Answers.Initial_Direction(Trial_number, 1) = display.T1.line.angle;
        end
        startTime = GetSecs;
        
        while true
            % Check the keys press
            [keyIsDown, timeSecs, keyCode] = KbCheck;
            
            % For 2AFC design, update the cursor according to key press
            if (DATA.Subject.Design == 1)
                drawT1Binary(display);
            % For "clock" design, update the arrow according to key press
            elseif (DATA.Subject.Design == 2)
                drawT1Clock(display, DATA.Paradigm.Step);
            end

            if keyIsDown
                    if keyCode(keys.right)
                        if (DATA.Subject.Design == 1)
                            % Set right answer
                            display.T1.line.index = 2;
                        elseif (DATA.Subject.Design == 2)
                            % Increase angle with 1 step
                            display.T1.line.index = display.T1.line.index + 1;
                            if (display.T1.line.index > size(display.T1.line.table, 2))
                                display.T1.line.index = 1;
                            end
                            display.T1.line.angle = display.T1.line.table(2, display.T1.line.index); 
                        end

                    elseif keyCode(keys.left)
                        if (DATA.Subject.Design == 1)
                            % Set left answer
                            display.T1.line.index = 1;
                        elseif (DATA.Subject.Design == 2)
                            % Decrease angle with minus 1 step
                            display.T1.line.index = display.T1.line.index - 1;
                            if display.T1.line.index == 0
                                display.T1.line.index = size(display.T1.line.table, 2);
                            end
                            display.T1.line.angle = display.T1.line.table(2, display.T1.line.index); 
                        end

                    elseif keyCode(keys.space)
                        if (display.T1.line.index ~= 0)
                            % Get the perceptual reaction time
                            DATA.Answers.RT1brut(Trial_number, 1) = (timeSecs - startTime)*100;
                            % Save the subject answer
                            DATA.Answers.Direction(Trial_number, 1) = display.T1.line.table(1, display.T1.line.index);
                            break;
                        end
                    end
                    waitTill(0.05);
            end
        end

        % Compute perceptual RT (weighted according to the initial direction)
        if DATA.Answers.Initial_Direction(Trial_number, 1) ~= DATA.Answers.Direction(Trial_number, 1)
            if (DATA.Subject.Design == 1) % For 2AFC design, do not correct RTs
                DATA.Answers.RT1corr(Trial_number, 1) = DATA.Answers.RT1brut(Trial_number, 1);
            elseif (DATA.Subject.Design == 2) % For "clock" design
                DATA.Answers.RT1corr(Trial_number, 1) = DATA.Answers.RT1brut(Trial_number, 1)/abs(DATA.Answers.Initial_Direction(Trial_number, 1) - DATA.Answers.Direction(Trial_number, 1));
            end
        elseif DATA.Answers.Initial_Direction(Trial_number, 1) == DATA.Answers.Direction(Trial_number, 1)
            DATA.Answers.RT1corr(Trial_number, 1) = DATA.Answers.RT1brut(Trial_number, 1);
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

        % For "clock" design, compute simply perceptual performance
        elseif (DATA.Subject.Design == 2)
            if DATA.Paradigm.Directions(Trial_number, 1) == DATA.Answers.Direction(Trial_number, 1)
                DATA.Answers.Correction(Trial_number, 1) = 1;
            elseif DATA.Paradigm.Directions(Trial_number, 1) ~= DATA.Answers.Direction(Trial_number, 1)
                DATA.Answers.Correction(Trial_number, 1) = 0;
            end
        end

        % Get the amount of gain
        if (Phasis_number == 1)
            % Find the gain in the phasis 1 gain matrix, thanks to correction
            DATA.Points.Counter.Type_I(Trial_number, 1) = DATA.Points.Matrix.Phasis1(DATA.Answers.Correction(Trial_number, 1) + 1);
        elseif (Phasis_number == 2)
            % Find the gain in the phasis 2 gain matrix, thanks to correction
            DATA.Points.Counter.Type_I(Trial_number, 1) = DATA.Points.Matrix.Phasis2(DATA.Answers.Correction(Trial_number, 1) + 1);
        elseif (Phasis_number == 3)
            % Find the gain in the phasis 3 gain matrix, thanks to correction and easiness level
            DATA.Points.Counter.Type_I(Trial_number, 1) = DATA.Points.Matrix.Phasis3(display.T3.index, DATA.Answers.Correction(Trial_number, 1) + 1);
        end

        % Black screen during 100 milisecond
        Screen('FillOval', display.windowPtr, display.bkColor);
        Screen('Flip',display.windowPtr);
        waitTill(.1);

        %% Type II answer (monitoring)

        % If phasis 2 or 3 is displayed
        if (Phasis_number ~= 1) 
            display.T2.rect2.size = 0;
            % Set the initial position to the center of the scale
            DATA.Answers.Initial_Confidence(Trial_number, 1) = round(((display.T2.rect2.size + display.T2.rect1.size) / (2 * display.T2.rect1.size)) * 100);
            startTime = GetSecs;

            while true
                % Check the keys press
                [keyIsDown, timeSecs, keyCode] = KbCheck;
                
                % Update the red rectangle according to key press
                drawT2Rect(display);
                if keyIsDown

                        if keyCode(keys.right)
                            % Increase confidence score with +1%
                            display.T2.rect2.size = display.T2.rect2.size + ((2*display.T2.rect1.size)/100);
                            if display.T2.rect2.size > display.T2.rect1.size
                                display.T2.rect2.size = display.T2.rect1.size;
                            end

                        elseif keyCode(keys.left)
                            % Decrease confidence score with -1%
                            display.T2.rect2.size = display.T2.rect2.size - ((2*display.T2.rect1.size)/100);
                            if display.T2.rect2.size < display.T2.rect1.size*-1
                                display.T2.rect2.size = display.T2.rect1.size*-1;
                            end

                         elseif keyCode(keys.space)
                            % Get the metacognitive monitoring reaction time
                            DATA.Answers.RT2brut(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = (timeSecs - startTime)*100;
                            % Get the confidence score on a 100 scale
                            DATA.Answers.Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = round(((display.T2.rect2.size + display.T2.rect1.size) / (2 * display.T2.rect1.size)) * 100);
                            waitTill(.1);
                            break;
                        end
                end
            end

            % Compute monitoring RT (weighted according to the initial confidence)
            if (DATA.Answers.Initial_Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) ~= DATA.Answers.Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1))
                DATA.Answers.RT2corr(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = DATA.Answers.RT2brut(Trial_number - DATA.Paradigm.Phasis1.Trials, 1)/abs(DATA.Answers.Initial_Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) - DATA.Answers.Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1));
            elseif (DATA.Answers.Initial_Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) == DATA.Answers.Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1))
                DATA.Answers.RT2corr(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = DATA.Answers.RT2brut(Trial_number - DATA.Paradigm.Phasis1.Trials, 1);
            end

            % Get gains based on confidence
            DATA.Points.Tickets.First (Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = randi([40, 100]); % Get a first ticket (between 40 and 100)
            DATA.Points.Tickets.Second(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = randi([1, 100]); % Get a second ticket (between 1 and 100)
            % Compare confidence to first ticket
            if (DATA.Answers.Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) >= DATA.Points.Tickets.First(Trial_number - DATA.Paradigm.Phasis1.Trials, 1))
                DATA.Points.Tickets.Lottery(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = DATA.Answers.Correction(Trial_number - DATA.Paradigm.Phasis1.Trials, 1);
            elseif (DATA.Answers.Confidence(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) < DATA.Points.Tickets.First(Trial_number - DATA.Paradigm.Phasis1.Trials, 1))
                DATA.Points.Tickets.Lottery(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = DATA.Points.Tickets.First(Trial_number - DATA.Paradigm.Phasis1.Trials, 1);
            end
            % Compare the DATA.Points.Tickets.Lottery to a random ticket
            if (DATA.Points.Tickets.Lottery(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) >= DATA.Points.Tickets.Second(Trial_number - DATA.Paradigm.Phasis1.Trials, 1))
                DATA.Points.Counter.Type_II(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = DATA.Points.Matrix.Confidence(1);
            elseif (DATA.Points.Tickets.Lottery(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) < DATA.Points.Tickets.Second(Trial_number - DATA.Paradigm.Phasis1.Trials, 1))
                DATA.Points.Counter.Type_II(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = DATA.Points.Matrix.Confidence(2);
            end

            %% Display a break screen
            if (Trial_number == round(DATA.Paradigm.Phasis1.Trials/2)) || (Trial_number == round(DATA.Paradigm.Phasis2.Trials/2)) || (Trial_number == round(DATA.Paradigm.Phasis3.Trials/2))
                waitTill(1);
                drawText_MxM(display, [0, (display.scale/5)], 'Faîtes une pause d''une ou deux minutes', colors.white, display.scale*4);
                drawText_MxM(display, [0, -(display.scale/5)], '(Appuyez sur n''importe quelle touche pour continuer)', colors.white, display.scale*2);
                Screen('Flip',display.windowPtr);
                while KbCheck; end
                KbWait;
            end
        end

        %% Psychometric fit

        if (Phasis_number == 1) && (Trial_number == DATA.Paradigm.Phasis1.Trials)
            % Make the subject waits while fitting the psychometric curve
            drawText_MxM(display, [0, 0], 'Veuillez patienter quelques secondes', colors.white, display.scale*4);
            Screen('Flip',display.windowPtr);

            % Make a coherence x performance table
            DATA.Fit.Psychometric.Coherence = unique(DATA.Paradigm.Phasis1.Coherences);
            DATA.Fit.Psychometric.Performance = grpstats(DATA.Answers.Correction, DATA.Paradigm.Phasis1.Coherences(1:DATA.Paradigm.Phasis1.Trials ));
            if (DATA.Subject.Design == 1)
                DATA.Fit.Psychometric.Chance = 0.5;
            elseif (DATA.Subject.Design == 2)
                DATA.Fit.Psychometric.Chance = 1/(360/DATA.Paradigm.Step); 
            end
            DATA.Fit.Psychometric.Coherence = [0; DATA.Fit.Psychometric.Coherence];
            DATA.Fit.Psychometric.Performance = [DATA.Fit.Psychometric.Chance; DATA.Fit.Psychometric.Performance];
            DATA.Fit.Psychometric.Coherence = [DATA.Fit.Psychometric.Coherence; 1];
            DATA.Fit.Psychometric.Performance = [DATA.Fit.Psychometric.Performance; 1];

            % If the bayesian optimization is not activate
            if (DATA.Subject.Optimization == 0)
                % Define the psychometric function
                DATA.Fit.Psychometric.SigFunc = @(F, x)(1./(1 + exp(-F(1)*(x-F(2)))));
                if (DATA.Subject.Context ~= 3)
                    % Fit the psychometric function
                    DATA.Fit.Psychometric.SigFit = nlinfit(DATA.Fit.Psychometric.Coherence, DATA.Fit.Psychometric.Performance, DATA.Fit.Psychometric.SigFunc, [1 1]);
                elseif (DATA.Subject.Context == 3)
                    % Define some default psychometric parameters
                    DATA.Fit.Psychometric.SigFit(1) = 10;
                    DATA.Fit.Psychometric.SigFit(2) = 0.5;
                end
            % If it is activate
            elseif (DATA.Subject.Optimization == 1) 
                % Insérer ici les paramètres de sortie du fit bayésien
            end

            % Draw the figure
            fig = figure(1);
            % Plot empirical points
            plot(DATA.Fit.Psychometric.Coherence, DATA.Fit.Psychometric.Performance, '*');
            hold on
            % Plot fit
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
            text(0.8, 0.2, strcat('Mu = ', num2str(DATA.Fit.Psychometric.SigFit(1))));
            text(0.8, 0.1, strcat('Sigma = ', num2str(DATA.Fit.Psychometric.SigFit(2))));
            % Set legend, axis and labels
            legend('Human data', 'Fit', 'Model data', 'Chance', 'location', 'northwest');
            axis([0, 1, 0, 1]);
            xlabel('Motion coherence'); 
            ylabel('Perceptual performance');

            % Get a coherence level according to a given performance
            syms Target_coherence
            DATA.Fit.Psychometric.C50 = double(solve((1./(1 + exp(-DATA.Fit.Psychometric.SigFit(1)*(Target_coherence - DATA.Fit.Psychometric.SigFit(2))))) == 0.5));
        end

        %% Get the compensation payment and display it

        % If the last trial has been displayed
        if (Trial_number == DATA.Paradigm.Trials) % à modifier
            % Set a precaution if only first phasis has been displayed (without confidence recordings)
            if (any(DATA.Subject.Phasis_list == 2) == 0) && (any(DATA.Subject.Phasis_list == 3) == 0)
                DATA.Points.Counter.Type_II = 0;
            end

            % Convert points in money
            if (((DATA.Points.Initial + sum(DATA.Points.Counter.Type_I) + sum(DATA.Points.Counter.Type_II))/1000) <= 0)
                DATA.Points.Money = round(DATA.Points.Initial/1000);
            elseif (((DATA.Points.Initial + sum(DATA.Points.Counter.Type_I) + sum(DATA.Points.Counter.Type_II))/1000) > 0)
                DATA.Points.Money = round((DATA.Points.Initial + sum(DATA.Points.Counter.Type_I) + sum(DATA.Points.Counter.Type_II))/1000);
            end

            % Born the amount of money a subject can win
            if (DATA.Points.Money < 5)
                DATA.Points.Money = round(DATA.Points.Initial/1000); % 5 euros minimum
            elseif (DATA.Points.Money > 20)
                DATA.Points.Money = round(4*(DATA.Points.Initial/1000)); % 20 euros maximum
            end

            % End screen
            drawText_MxM(display, [0, -(display.scale/5)], strcat('Merci d''avoir participé. Vous avez gagné : ', num2str(DATA.Points.Money), '?'), colors.white, display.scale*4);
            drawText_MxM(display, [0, (display.scale/5)], 'Vous pouvez maintenant venir chercher vos gains en salle de contrôle.', colors.white, display.scale*4);
        end
             
        %% Display some variables in the command window during
        if (Phasis_number == 1)
            disp([num2str(Phasis_number), '  ', ... % Phasis number
                  num2str(Trial_number), '  ', ... % Trial number
                  num2str(round(DATA.Paradigm.Phasis1.Coherences(Trial_number, 1)*100)/100), '  ', ... % Coherence level
                  num2str(DATA.Answers.Correction(Trial_number, 1))]); % Correction
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
        %% Switch between phasis
        
        % Switch to phasis 2 when all the phasis 1 trials have been displayed
        if Trial_number == DATA.Paradigm.Phasis1.Trials
            Phasis_number = 2;
        end
        
        % Switch to phasis 3 when all the phasis 2 trials have been displayed
        if Trial_number == DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials
            Phasis_number = 3;
        end
    end
    
% In case of error
catch error_message
Screen('CloseAll');
rethrow(error_message);
end

%% Save a table for further import in DMAT

if (DATA.Subject.Context ~= 4)  % à modifier
    
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
    
    % Make a list of all possible performance levels ...
    DATA.Paradigm.Phasis3.Conditions(:,1) = repmat(unique(DATA.Paradigm.Phasis3.Performances(:,1)), size(horzcat(DATA.Paradigm.Phasis2.Facility_levels, NaN), 2), 1);
    % ... and all possible increasing facility indexes (including the case where there is no information seeking)
    DATA.Paradigm.Phasis3.Conditions(:,2) = sort(repmat(transpose(horzcat(DATA.Paradigm.Phasis2.Facility_levels, -1)), size(DATA.Paradigm.Phasis3.Accuracies_levels, 2), 1));
    % Attribute a condition to each of these combinations
    for i = 1:1:size(DATA.Paradigm.Phasis3.Conditions, 1)
        DATA.Paradigm.Phasis3.Conditions(i,3) = i;
    end
    for i = 1:1:size(DATA.Paradigm.Phasis3.Performances, 1)
        DATA.Fit.DMAT.Phasis3.Input(i,1) = intersect(find(DATA.Paradigm.Phasis3.Conditions(:,1) == DATA.Paradigm.Phasis3.Performances(i,1)), find(DATA.Paradigm.Phasis3.Conditions(:,2) == DATA.Paradigm.Phasis3.Performances(i,2)));
    end
    DATA.Fit.DMAT.Phasis3.Input(:,2) = DATA.Answers.Correction(DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials + 1 : DATA.Paradigm.Trials);
    DATA.Fit.DMAT.Phasis3.Input(:,3) = DATA.Answers.RT1corr(DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials + 1 : DATA.Paradigm.Trials);
    DMAT3 = DATA.Fit.DMAT.Phasis3.Input;
end

%% Save a table for further import in R

if (DATA.Subject.Context ~= 4) % à modifier !!!!

    % Define the table
    Headers = {'Number', 'Date', 'Group', 'Age', 'Gender', ... % Subject information
        'Trials', 'Phasis', 'A_perf', 'A_coh', 'Inc_perf', 'Inc_coh', 'B_perf', 'B_coh', 'Direction', ... % Independant variables
        'Answer', 'Accuracy', 'RT1_brut', 'RT1_corr', 'Confidence', 'RT2_brut', 'RT2_corr', 'Seek', 'RT3_brut', 'RT3_corr', 'Gains'}; % Dependant variables
    Rtable = cell(DATA.Paradigm.Trials+1,length(Headers));

    Rtable(1,:) = Headers;
    for i = 1:1:DATA.Paradigm.Trials
        Rtable{i+1,1} = strcat('#', num2str(DATA.Subject.Number)); % Number
        Rtable{i+1,2} = DATA.Subject.Date; % Date
        Rtable{i+1,3} = DATA.Subject.Group; % Group
        Rtable{i+1,4} = DATA.Subject.Age; % Age
        Rtable{i+1,5} = DATA.Subject.Gender; % Gender

        %
        % Rtable{i+1,6} = DATA.Subject.Design; % 2AFC or 16AFC
        % Rtable{i+1,7} = DATA.Subject.Optimization; % With or without bayesian design optimizations
        %

        Rtable{i+1,6} = i; % Trials
        Rtable{i+1,14} = DATA.Paradigm.Directions(i); % Directions
        Rtable{i+1,15} = DATA.Answers.Direction(i); % Type I answers
        Rtable{i+1,16} = DATA.Answers.Correction(i); % Correction              % MODIFIER ICI : ON NE DEMANDE PLUS LA CONFIANCE EN PHASE 1
        Rtable{i+1,17} = DATA.Answers.RT1brut(i); % Type I RT (brut)
        Rtable{i+1,18} = DATA.Answers.RT1corr(i); % Type I RT (corrected)
        Rtable{i+1,25} = DATA.Points.Counter.Type_I(i); % Gains
    end
    % For phasis 1
    for i = 1:1:DATA.Paradigm.Phasis1.Trials
        Rtable{i+1,7} = 1; % Phasis
        Rtable{i+1,8} = NaN; % Performances 'A'
        Rtable{i+1,9} = DATA.Paradigm.Phasis1.Coherences(i); % Coherences 'A'
        Rtable{i+1,10} = NaN; % Increasing performances
        Rtable{i+1,11} = NaN; % Increasing coherences
        Rtable{i+1,12} = NaN; % Performances 'B'
        Rtable{i+1,13} = NaN; % Coherences 'B'
        Rtable{i+1,19} = NaN; % Type II (monitoring) answers
        Rtable{i+1,20} = NaN; % Type II (monitoring) RT (brut)
        Rtable{i+1,21} = NaN; % Type II (monitoring) RT (corrected)
        Rtable{i+1,22} = NaN; % Type II (control) answers
        Rtable{i+1,23} = NaN; % Type II (control) RT (brut)
        Rtable{i+1,24} = NaN; % Type II (control) RT (corrected)
    end
    % For phasis 2
    for i = 1:1:DATA.Paradigm.Phasis2.Trials
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,7} = 2; % Phasis
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,8} = DATA.Paradigm.Phasis2.Performances(i,1); % Performances 'A'
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,9} = DATA.Paradigm.Phasis2.Coherences(i,1); % Coherences 'A'
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,10} = DATA.Paradigm.Phasis2.Performances(i,2); % Increasing performances
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,11} = DATA.Paradigm.Phasis2.Coherences(i,2); % Increasing coherences
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,12} = DATA.Paradigm.Phasis2.Performances(i,3); % Performances 'B'
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,13} = DATA.Paradigm.Phasis2.Coherences(i,3); % Coherences 'B'
        %
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,19} = DATA.Answers.Confidence(i:DATA.Paradigm.Phasis2.Trials); % Type II (monitoring) answers
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,20} = DATA.Answers.RT2brut(i:DATA.Paradigm.Phasis2.Trials); % Type II (monitoring) RT (brut)
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,21} = DATA.Answers.RT2corr(i:DATA.Paradigm.Phasis2.Trials); % Type II (monitoring) RT (corrected)
        %
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,22} = NaN; % Type II (control) answers
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,23} = NaN; % Type II (control) RT (brut)
        Rtable{i+DATA.Paradigm.Phasis1.Trials+1,24} = NaN; % Type II (control) RT (corrected)
    end
    % For phasis 3
    for i = 1:1:DATA.Paradigm.Phasis3.Trials
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,7} = 3; % Phasis
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,8} = DATA.Paradigm.Phasis3.Performances(i,1); % Performances 'A'
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,9} = DATA.Paradigm.Phasis3.Coherences(i,1); % Coherences 'A'
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,10} = NaN; % Increasing performances
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,11} = DATA.Paradigm.Phasis3.Coherences(i,2); % Increasing coherences
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,12} = DATA.Paradigm.Phasis3.Performances(i,3); % Performances 'B'
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,13} = DATA.Paradigm.Phasis3.Coherences(i,3); % Coherences 'B'
        %
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,19} = DATA.Answers.Confidence(i+DATA.Paradigm.Phasis2.Trials+1:DATA.Paradigm.Phasis3.Trials); % Type II (monitoring) answers
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,20} = DATA.Answers.RT2brut(i+DATA.Paradigm.Phasis2.Trials+1:DATA.Paradigm.Phasis3.Trials); % Type II (monitoring) RT (brut)
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,21} = DATA.Answers.RT2corr(i+DATA.Paradigm.Phasis2.Trials+1:DATA.Paradigm.Phasis3.Trials); % Type II (monitoring) RT (corrected)
        %
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,22} = DATA.Paradigm.Phasis3.Performances(i,2); % Type II (control) answers
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,23} = DATA.Answers.RT3brut(i,1); % Type II (control) RT (brut)
        Rtable{i+DATA.Paradigm.Phasis1.Trials+DATA.Paradigm.Phasis2.Trials+1,24} = DATA.Answers.RT3corr(i,1); % Type II (control) RT (corrected)
    end
 
%% Save files

    % Go to the subject directory
    cd(DATA.Files.Name);

    % Save data for further import in Dift Diffusion Model or Linear Ballistic Accumulator model
    save(strcat(DATA.Files.Name, '_DDM-LBA-1'), 'DMAT1');
    save(strcat(DATA.Files.Name, '_DDM-LBA-2'), 'DMAT2');
    save(strcat(DATA.Files.Name, '_DDM-LBA-3'), 'DMAT3');

    % Save data
    save(DATA.Files.Name, 'DATA', 'display', 'dots');

    % Save R table
    cell2csv(strcat(DATA.Files.Name, '.csv'), Rtable);

    % Save fit graph
    saveas(fig, DATA.Files.Name, 'fig');

%% Close all

    % Return to the task directory
    cd ..

    % Wait 1 minute
    waitTill(60);
    
    % Close the diary
    diary off;
end

% Then close the experiment
Screen('CloseAll');

% Clear some useless variables
clear Phasis_number and Trial_number and Target_coherence and ans and i and fig and Review and Headers;