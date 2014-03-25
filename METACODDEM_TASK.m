%%% ------------------------------------------------------------------------------------- %%%
%%%                            SCRIPT OF THE METACODDEM PROJECT                           %%%
%%%                 ("METAcognitive COntrol During DEcision-Making" task)                 %%%
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
diary 'MetaCoDDeM_diary.txt';

% DATA.Subject.Number = randi(1000,1,1);
% DATA.Subject.Group = upper(input('Subject group? (HS/OCD/DLGG) ', 's'));
% DATA.Subject.Age = upper(input('Subject age? ', 's'));
% DATA.Subject.Initials = upper(input('Subject initials? ', 's'));
% DATA.Subject.Handedness = upper(input('Subject handedness? (L/R) ', 's'));
% DATA.Subject.Gender = upper(input('Subject gender? (M/F) ', 's'));
% DATA.Subject.Date = datestr(now);
% 
DATA.Files.Name = 'Temporaire'; % ['MetaCoDDeMproject_' num2str(DATA.Subject.Group) '_' DATA.Subject.Initials '_' num2str(DATA.Subject.Number)];
mkdir(DATA.Files.Name); % Create the subject folder

%% Define parameters

% Set frequently used colors
colors.black = [0 0 0];
colors.white = [255 255 255];
colors.gray = [128 128 128];
colors.red = [255 0 0];

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
dots.center = [0 0];
dots.color = colors.white;
dots.size = 5;
dots.coherence = 0.7;
dots.duration = .750; % miliseconds

% Set a correponding table between dots angle (classic) and line angle (trigonometric)
display.T1.line.table_a = 0:DATA.Paradigm.Step:359;
display.T1.line.table_b = 90:-DATA.Paradigm.Step:0;
display.T1.line.table_c = 360:-DATA.Paradigm.Step:91;
display.T1.line.table_c(:,1) = [];
display.T1.line.table = [display.T1.line.table_a;display.T1.line.table_b,display.T1.line.table_c];

% Set type I forms parameters
display.T1.tick = display.scale/2;
display.T1.circle.size = display.scale;
display.T1.circle.color = colors.white;
display.T1.line.size = display.scale;
display.T1.line.color = colors.red;
display.T1.triangle.size = display.scale;
display.T1.triangle.color = colors.red;

% Set type II forms parameters
display.T2.tick = display.scale/2;
display.T2.rect1.size = display.scale;
display.T2.rect1.color = colors.white;
display.T2.rect2.color = colors.red;

% Set the parameters for the phasis 1 (calibration phasis)
DATA.Paradigm.Phasis1.Coherences_margin = .1;
DATA.Paradigm.Phasis1.Coherences_level = 0.1:DATA.Paradigm.Phasis1.Coherences_margin:(1 - DATA.Paradigm.Phasis1.Coherences_margin); % Define the list of coherence levels
DATA.Paradigm.Phasis1.Coherences_level = transpose(DATA.Paradigm.Phasis1.Coherences_level); % Transform it into a column
DATA.Paradigm.Phasis1.Coherences_number = 15; % Number of trials per coherence level
DATA.Paradigm.Phasis1.Coherences = repmat(DATA.Paradigm.Phasis1.Coherences_level, DATA.Paradigm.Phasis1.Coherences_number, 1); % Repeat each coherence level a certain number of time
DATA.Paradigm.Phasis1.Coherences = DATA.Paradigm.Phasis1.Coherences(randperm(length(DATA.Paradigm.Phasis1.Coherences)), 1); % Randomly shuffle it
DATA.Paradigm.Phasis1.Trials = size(DATA.Paradigm.Phasis1.Coherences, 1); % The phasis 1 total number of trials is the size of this coherence list

% Set the parameters for the phasis 2 (evidence accumulation phasis)
DATA.Paradigm.Phasis2.Viewing_number = 2; % Define the maximum number of time a RDK will be displayed
DATA.Paradigm.Phasis2.Facility_levels = [0,.05,.10,.15]; % Define the increasing facility indexes
DATA.Paradigm.Phasis2.Accuracies_number = 1;%0; % Define the number of trials per accuracy level
DATA.Paradigm.Phasis2.Accuracies_levels = [.10,.425,.75];  % Define the initial wanted performance (before increasing facility index) for one set of increasing difficulty indes
DATA.Paradigm.Phasis2.Accuracies = repmat(DATA.Paradigm.Phasis2.Accuracies_levels, 1, size(DATA.Paradigm.Phasis2.Facility_levels, 2)*DATA.Paradigm.Phasis2.Accuracies_number); % Define the initial wanted performance (before increasing facility index) for the total number of trials
DATA.Paradigm.Phasis2.Accuracies = transpose(DATA.Paradigm.Phasis2.Accuracies); % Transform it into a column
DATA.Paradigm.Phasis2.Accuracies = DATA.Paradigm.Phasis2.Accuracies(randperm(length(DATA.Paradigm.Phasis2.Accuracies)), 1); % Randomly shuffle it
DATA.Paradigm.Phasis2.Facilities = repmat(DATA.Paradigm.Phasis2.Facility_levels, 1, size(DATA.Paradigm.Phasis2.Accuracies_levels, 2)*DATA.Paradigm.Phasis2.Accuracies_number); % Define all the increasing facility index (for each trial)
DATA.Paradigm.Phasis2.Facilities = transpose(DATA.Paradigm.Phasis2.Facilities); % Transform it into a column
DATA.Paradigm.Phasis2.Facilities = DATA.Paradigm.Phasis2.Facilities(randperm(length(DATA.Paradigm.Phasis2.Facilities)), 1); % Randomly shuffle it
DATA.Paradigm.Phasis2.Performances = [DATA.Paradigm.Phasis2.Accuracies DATA.Paradigm.Phasis2.Facilities (DATA.Paradigm.Phasis2.Accuracies + DATA.Paradigm.Phasis2.Facilities)]; % Make a table of (i) basal performance level, (ii) increasing facility index, and (iii) final performance 
DATA.Paradigm.Phasis2.Trials = size(DATA.Paradigm.Phasis2.Performances, 1); % Get the total number of trials in the second phasis

% Set the parameters for the phasis 3 (information seeking phasis)
DATA.Paradigm.Phasis3.Gains = [100, -200; 80, -80; 70, -70; 60, -60; 50, -50]; % Define the gain matrix
DATA.Paradigm.Phasis3.Accuracies_number = 1;%0; % Define the number of trials per accuracy level
% Remettre 1-max(review)
DATA.Paradigm.Phasis3.Accuracies_levels = 0.1:(0.9-0.1)/16:0.9; % Define the accuracy levels we want to test
DATA.Paradigm.Phasis3.Accuracies = repmat(DATA.Paradigm.Phasis3.Accuracies_levels, 1, DATA.Paradigm.Phasis3.Accuracies_number); % Define the accuracy levels we want to test for the total number of trials
DATA.Paradigm.Phasis3.Accuracies = transpose(DATA.Paradigm.Phasis3.Accuracies); % Transform it into a column
DATA.Paradigm.Phasis3.Performances = DATA.Paradigm.Phasis3.Accuracies(randperm(length(DATA.Paradigm.Phasis3.Accuracies)), 1); % Randomly shuffle it
DATA.Paradigm.Phasis3.Trials = size(DATA.Paradigm.Phasis3.Performances, 1); % Get the total number of trials in the third phasis

% Get the total number of trials
DATA.Paradigm.Trials = DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials + DATA.Paradigm.Phasis3.Trials;
for i = 1:1:DATA.Paradigm.Trials % Get random direction for each trial
    DATA.Paradigm.Directions(i, 1) = display.T1.line.table_a(randi(size(display.T1.line.table_a)));
end

%% Start the trial
try    
    % Open a window, set the display matrix and get the center of the screen
    display = OpenWindow(display);
    display.center = display.resolution/2;
      
    % Set the first phasis (calibration phasis)
    Phasis_number = 1;
    
    for Trial_number = 1:1:DATA.Paradigm.Trials
        % Get the direction of the stimulus
        dots.direction = DATA.Paradigm.Directions(Trial_number, 1);
        
        % Display phasis 1 instructions
        if Trial_number == 1
            drawText(display, [0 0], 'INSTRUCTIONS PHASIS 1', colors.white, 40);
            % Load instructions image
            Screen('Flip',display.windowPtr);
            while KbCheck; end
            KbWait;
        end
        
        % Display phasis 2 instructions
        if Trial_number == DATA.Paradigm.Phasis1.Trials + 1
            drawText(display, [0 0], 'INSTRUCTIONS PHASIS 2', colors.white, 40);
            % Load instructions image
            Screen('Flip',display.windowPtr);
            while KbCheck; end
            KbWait;
        end
        
        % Display phasis 3 instructions
        if Trial_number == DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials + 1
            drawText(display, [0 0], 'INSTRUCTIONS PHASIS 3', colors.white, 40);
            % Load instructions image
            Screen('Flip',display.windowPtr);
            while KbCheck; end
            KbWait;
        end
        
        % Display the information that it is a new stimulus
        drawText(display, [0 2], 'NOUVEAU STIMULUS', colors.white, 40);
        drawText(display, [0 -2], '(Appuyer sur n''importe quelle touche pour commencer)', colors.white, 20);
        Screen('Flip',display.windowPtr);
        while KbCheck; end
        KbWait;
        
        %% STIMULUS

        % Define dots motion coherence
        if Phasis_number == 1
            dots.coherence = DATA.Paradigm.Phasis1.Coherences(Trial_number);
        
        % Get a coherence level according to a given performance
        elseif Phasis_number == 2
            syms Target_coherence
            DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) ...
                = double(solve((1./(1 + exp(-DATA.Fit.Psychometric.SigFit(1)*(Target_coherence - DATA.Fit.Psychometric.SigFit(2))))) ...
                == DATA.Paradigm.Phasis2.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials, 1)));
            dots.coherence = DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 1);
        
        elseif Phasis_number == 3
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
        movingDots_MxM(display, dots, dots.duration, DATA.Paradigm.Step);

        % Black screen during 100 milisecond
        Screen('FillOval', display.windowPtr, display.bkColor);
        Screen('Flip',display.windowPtr);
        waitTill(.1);

        if Phasis_number == 2
            % For each review
            for Review = 2:1:DATA.Paradigm.Phasis2.Viewing_number
                
                % Get a coherence level according to a given performance
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
                movingDots_MxM(display, dots, dots.duration, DATA.Paradigm.Step);
                
                % Black screen during 100 milisecond
                Screen('FillOval', display.windowPtr, display.bkColor);
                Screen('Flip',display.windowPtr);
                waitTill(.1);
            end
        end
        
        if Phasis_number == 3
            % Display choice
            display.T3.index = 1;
            Initial
            startTime = GetSecs;
            while true
                % Check the keys press and get the RT
                [keyIsDown, timeSecs, keyCode] = KbCheck;
                % 
                drawT3Info(display, display.T3.index, DATA.Paradigm.Phasis3.Gains);
                
                if keyIsDown
                        
                        % If subject needs additional information, get the easiness increasing level he choose
                        if keyCode(keys.left)
                            display.T3.index = display.T3.index - 1;
                        elseif keyCode(keys.right)
                            display.T3.index = display.T3.index + 1;
                        end
                        % Precautions
                        if display.T3.index < 1
                            display.T3.index = 1;
                        elseif display.T3.index > 5
                            display.T3.index = 5;
                        end
                        waitTill(.1);
                            
                        % Get the information seeking level (easiness increasing)
                        if keyCode(keys.space)
                            if display.T3.index == 1
                                DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2) = NaN;
                                DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3) = NaN;
                            elseif display.T3.index == 2 || 3 || 4 || 5
                                DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2) = DATA.Paradigm.Phasis2.Facility_levels(display.T3.index - 1);
                                DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3) ...
                                    = DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) + DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2);
                            end
                            break;
                        end
                end
            end
            
            % Compute control RT (brut and weighted according to the initial direction
            DATA.Answers.RT3brut(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) = timeSecs - startTime;
            if display.T3.index ~= 1
                DATA.Answers.RT3corr(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) = DATA.Answers.RT3brut(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1)/abs(1 - display.T3.index);
            elseif display.T3.index == 1
                DATA.Answers.RT3corr(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) = DATA.Answers.RT3brut(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1);
            end
            
            waitTill(.1);
            
            if any(DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2) == DATA.Paradigm.Phasis2.Facility_levels) == 1
               
                % Get a coherence level according to a given performance
                DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 3) ...
                    = DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) + DATA.Paradigm.Phasis3.Performances(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 2);
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
                movingDots_MxM(display, dots, dots.duration, DATA.Paradigm.Step);

                % Black screen during 100 milisecond
                Screen('FillOval', display.windowPtr, display.bkColor);
                Screen('Flip',display.windowPtr);
                waitTill(.1);
            end
        end
        
        % Get the response
        display.T1.line.index = 1; % Column number
        display.T1.line.angle = display.T1.line.table(2, display.T1.line.index);
        DATA.Answers.Initial_Direction(Trial_number, 1) = display.T1.line.angle;
        DATA.Answers.Direction(Trial_number, 1) = NaN;
        startTime = GetSecs;
        
        while true
            % Check the keys press
            [keyIsDown, timeSecs, keyCode] = KbCheck;
            % Update the arrow according to key press
            drawT1Circle(display, DATA.Paradigm.Step);
            if keyIsDown

                    if keyCode(keys.down)
                        % Increase angle with 1 step
                        display.T1.line.index = display.T1.line.index + 1;
                        if display.T1.line.index > size(display.T1.line.table, 2)
                            display.T1.line.index = 1;  
                        end
                        display.T1.line.angle = display.T1.line.table(2, display.T1.line.index);  

                    elseif keyCode(keys.up)
                        % Decrease angle with minus 1 step
                        display.T1.line.index = display.T1.line.index - 1;
                        if display.T1.line.index == 0
                            display.T1.line.index = size(display.T1.line.table, 2);
                        end
                        display.T1.line.angle = display.T1.line.table(2, display.T1.line.index);
                        
                    elseif keyCode(keys.space)
                        % Get
                        DATA.Answers.Direction(Trial_number, 1) = display.T1.line.table(1, display.T1.line.index);
                        break;
                    end
            end
        end
        
        waitTill(.1);
        
        % Compute perceptual RT (brut and weighted according to the initial direction)
        DATA.Answers.RT1brut(Trial_number, 1) = timeSecs - startTime;
        if DATA.Answers.Initial_Direction(Trial_number, 1) ~= DATA.Answers.Direction(Trial_number, 1)
            DATA.Answers.RT1corr(Trial_number, 1) = DATA.Answers.RT1brut(Trial_number, 1)/abs(DATA.Answers.Initial_Direction(Trial_number, 1) - DATA.Answers.Direction(Trial_number, 1));
        elseif DATA.Answers.Initial_Direction(Trial_number, 1) ~= DATA.Answers.Direction(Trial_number, 1)
            DATA.Answers.RT1corr(Trial_number, 1) = DATA.Answers.RT1brut(Trial_number, 1);
        end
        
        % Compute perceptual performance
        if DATA.Paradigm.Directions(Trial_number, 1) == DATA.Answers.Direction(Trial_number, 1)
            DATA.Answers.Correction(Trial_number, 1) = 1;
        elseif DATA.Paradigm.Directions(Trial_number, 1) ~= DATA.Answers.Direction(Trial_number, 1)
            DATA.Answers.Correction(Trial_number, 1) = 0;
        end
        
        % Get the amount of gain
        if Phasis_number == 1
            DATA.Answers.Gains(Trial_number, 1) = DATA.Answers.Correction(Trial_number, 1);
        end
        if Phasis_number == 2
            DATA.Answers.Gains(Trial_number, 1) = DATA.Answers.Correction(Trial_number, 1);
        end
        if Phasis_number == 3
            DATA.Answers.Gains(Trial_number, 1) = DATA.Paradigm.Phasis3.Gains(display.T3.index, DATA.Answers.Correction(Trial_number, 1) + 1);
        end
        
        % Black screen during 100 milisecond
        Screen('FillOval', display.windowPtr, display.bkColor);
        Screen('Flip',display.windowPtr);
        waitTill(.1);

        %% CONFIDENCE

        display.T2.rect2.size = 0;
        DATA.Answers.Initial_Confidence(Trial_number, 1) = round(((display.T2.rect2.size + display.T2.rect1.size) / (2 * display.T2.rect1.size)) * 100);
        DATA.Answers.Confidence(Trial_number, 1) = NaN;
        startTime = GetSecs;
        
        while true
            % Check the keys press and get the RT
            [keyIsDown, timeSecs, keyCode] = KbCheck;
            
            % Display instructions
            drawText(display, [0, (display.T2.rect1.size - display.T2.rect1.size/4)], 'Veuillez donner votre niveau de confiance dans votre réponse', [255 255 255], 40);
            drawText(display, [0, (display.T2.rect1.size - display.T2.rect1.size/4)*-1], '(Appuyer sur ESPACE pour valider votre choix)', [255 255 255], 20);
            
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
                        DATA.Answers.RT2brut(Trial_number, 1) = timeSecs - startTime;
                        DATA.Answers.RT2corr(Trial_number, 1) = DATA.Answers.RT2brut(Trial_number, 1)/abs(DATA.Answers.Initial_Confidence(Trial_number, 1) - DATA.Answers.Confidence(Trial_number, 1));
                        % Get the confidence score on a 100 scale
                        DATA.Answers.Confidence(Trial_number, 1) = round(((display.T2.rect2.size + display.T2.rect1.size) / (2 * display.T2.rect1.size)) * 100);
                        waitTill(.1);
                        break;
                    end
            end
        end
        
        % Compute monitoring RT (brut and weighted according to the initial confidence)
        DATA.Answers.RT2brut(Trial_number, 1) = timeSecs - startTime;
        if DATA.Answers.Initial_Confidence(Trial_number, 1) ~= DATA.Answers.Confidence(Trial_number, 1)
            DATA.Answers.RT2corr(Trial_number, 1) = DATA.Answers.RT2brut(Trial_number, 1)/abs(DATA.Answers.Initial_Confidence(Trial_number, 1) - DATA.Answers.Confidence(Trial_number, 1));
        elseif DATA.Answers.Initial_Confidence(Trial_number, 1) == DATA.Answers.Confidence(Trial_number, 1)
            DATA.Answers.RT2corr(Trial_number, 1) = DATA.Answers.RT2brut(Trial_number, 1);
        end
        
        % Display a break screen
        if ((Trial_number == (DATA.Paradigm.Phasis1.Trials/2)) || (Trial_number == (DATA.Paradigm.Phasis2.Trials/2)) || (Trial_number == (DATA.Paradigm.Phasis3.Trials/2)))
            drawText(display, [0 2], 'Faîtes une pause d''une ou deux minutes', colors.white, 40);
            drawText(display, [0 -2], '(Appuyer sur n''importe quelle touche pour continuer)', colors.white, 20);
            Screen('Flip',display.windowPtr);
            while KbCheck; end
            KbWait;
        end

        %% FIT
        if Phasis_number == 1
            if Trial_number == DATA.Paradigm.Phasis1.Trials
                
                % Make a coherence x performance table
                DATA.Fit.Psychometric.Coherence = unique(DATA.Paradigm.Phasis1.Coherences);
                DATA.Fit.Psychometric.Performance = grpstats(DATA.Answers.Correction, DATA.Paradigm.Phasis1.Coherences);
                % Insert born values (chance and 100% accuracy)
                DATA.Fit.Psychometric.Chance = 1/(360/DATA.Paradigm.Step);
                DATA.Fit.Psychometric.Coherence = [0; DATA.Fit.Psychometric.Coherence];
                DATA.Fit.Psychometric.Performance = [DATA.Fit.Psychometric.Chance; DATA.Fit.Psychometric.Performance];
                DATA.Fit.Psychometric.Coherence = [DATA.Fit.Psychometric.Coherence; 1];
                DATA.Fit.Psychometric.Performance = [DATA.Fit.Psychometric.Performance; 1];
                
                % Set the psychometric function
                DATA.Fit.Psychometric.SigFunc = @(F, x)(1./(1 + exp(-F(1)*(x-F(2)))));
                % Fit it
                DATA.Fit.Psychometric.SigFit = nlinfit(DATA.Fit.Psychometric.Coherence, DATA.Fit.Psychometric.Performance, DATA.Fit.Psychometric.SigFunc, [1 1]);
                
                % A SUPPRIMER
%                 DATA.Fit.Psychometric.SigFit(1) = 10;
%                 DATA.Fit.Psychometric.SigFit(2) = .50;
                
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
                % Set legend, axis and labels
                legend('Human data', 'Fit', 'Model data', 'Chance', 'location', 'northwest');
                axis([0 1 0 1]);
                xlabel('Motion coherence'); 
                ylabel('Perceptual performance');
                
                % Get a coherence level according to a given performance
                syms Target_coherence
                DATA.Fit.Psychometric.C50 = double(solve((1./(1 + exp(-DATA.Fit.Psychometric.SigFit(1)*(Target_coherence - DATA.Fit.Psychometric.SigFit(2))))) == .5));
            end
        end
        
        % Switch to phasis 2 when all the phasis 1 trials have been displayed
        if Trial_number == DATA.Paradigm.Phasis1.Trials
            Phasis_number = 2;
        end
        
        % Switch to phasis 3 when all the phasis 2 trials have been displayed
        if Trial_number == DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials
            Phasis_number = 3;
        end
    end
     
    % Close all windows
    Screen('CloseAll');

%% In case of error
catch error_message
Screen('CloseAll');
rethrow(error_message);
end

%% Save a table for further import in DMAT
cd(DATA.Files.Name); % Go to the subject directory

% For phasis 1
DATA.Paradigm.Phasis1.Conditions = sort(unique(DATA.Paradigm.Phasis1.Coherences)); % Make a list of all possible coherence levels to future import in DMAT
for i = 1:1:size(DATA.Paradigm.Phasis1.Conditions)
    DATA.Paradigm.Phasis1.Conditions(i,2) = i;
end

for i = 1:1:size(DATA.Paradigm.Phasis1.Coherences,1)
    DATA.Fit.DMAT.Phasis1(i,1) = find(DATA.Paradigm.Phasis1.Conditions(:,1) == DATA.Paradigm.Phasis1.Coherences(i));
end
DATA.Fit.DMAT.Phasis1(:,2) = DATA.Answers.Correction(1:DATA.Paradigm.Phasis1.Trials);
DATA.Fit.DMAT.Phasis1(:,3) = DATA.Answers.RT1corr(1:DATA.Paradigm.Phasis1.Trials);
DMAT1 = DATA.Fit.DMAT.Phasis1;
save(strcat(DATA.Files.Name, '_DMAT1'), 'DMAT1');

% For phasis 2
DATA.Paradigm.Phasis2.Conditions(:,1) = repmat(unique(DATA.Paradigm.Phasis2.Performances(:,1)), size(DATA.Paradigm.Phasis2.Facility_levels, 2), 1);
DATA.Paradigm.Phasis2.Conditions(:,2) = sort(repmat(transpose(DATA.Paradigm.Phasis2.Facility_levels), size(DATA.Paradigm.Phasis2.Accuracies_levels, 2), 1));
for i = 1:1:size(DATA.Paradigm.Phasis2.Conditions, 1)
    DATA.Paradigm.Phasis2.Conditions(i,3) = i;
end
for i = 1:1:size(DATA.Paradigm.Phasis2.Performances,1)
    DATA.Fit.DMAT.Phasis2(i,1) = find(DATA.Paradigm.Phasis2.Conditions(:,1) == DATA.Paradigm.Phasis2.Performances(i,3));
end
DATA.Fit.DMAT.Phasis2(:,2) = DATA.Answers.Correction(DATA.Paradigm.Phasis1.Trials + 1 : DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials);
DATA.Fit.DMAT.Phasis2(:,3) = DATA.Answers.RT1corr(DATA.Paradigm.Phasis1.Trials + 1 : DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials);
DMAT2 = DATA.Fit.DMAT.Phasis2;
save(strcat(DATA.Files.Name, '_DMAT2'), 'DMAT2');

% For phasis 3
DATA.Paradigm.Phasis3.Conditions(:,1) = repmat(unique(DATA.Paradigm.Phasis3.Performances(:,1)), size(horzcat(DATA.Paradigm.Phasis2.Facility_levels, NaN), 2), 1);
DATA.Paradigm.Phasis3.Conditions(:,2) = sort(repmat(transpose(horzcat(DATA.Paradigm.Phasis2.Facility_levels, NaN)), size(DATA.Paradigm.Phasis3.Accuracies_levels, 2), 1));
for i = 1:1:size(DATA.Paradigm.Phasis3.Conditions, 1)
    DATA.Paradigm.Phasis3.Conditions(i,3) = i;
end
for i = 1:1:size(DATA.Paradigm.Phasis3.Performances, 1)
    DATA.Fit.DMAT.Phasis3(i,1) = intersect(find(DATA.Paradigm.Phasis3.Conditions(:,1) == DATA.Paradigm.Phasis3.Performances(i,1)), find(DATA.Paradigm.Phasis3.Conditions(:,2) == DATA.Paradigm.Phasis3.Performances(i,2)));
end
DATA.Fit.DMAT.Phasis3(i,2) = DATA.Answers.Correction(DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials + 1 : DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials + DATA.Paradigm.Phasis3.Trials);
DATA.Fit.DMAT.Phasis3(i,3) = DATA.Answers.RT1corr(DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials + 1 : DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials + DATA.Paradigm.Phasis3.Trials);
DMAT3 = DATA.Fit.DMAT.Phasis3;
save(strcat(DATA.Files.Name, '_DMAT3'), 'DMAT3');

%% Save a table for futher import in R

% Make a summary table and save it in a csv file(DataSet, 'File', DATA.Files.Name '.csv', 'Delimiter', ',')

%% Save files

% Get the __
DATA.Answers.Money = 5 + (sum(DATA.Answers.Gains)/1000);

% Save data
save(DATA.Files.Name, 'DATA', 'display', 'dots');

% Save fit graph
saveas(fig, DATA.Files.Name, 'fig');

% Return to the task directory
cd ..

% Clear some useless variables
clear Phasis_number and Trial_number and Target_coherence and ans and i and fig and Review;
% Close the diary
diary off;