%% SCRIPT FOR THE MECODDEM PROJECT ("MEtacognitive COntrol During DEcision-Making" TASK)

% Author: Maxime Maheu
% Copyright (C) 2014

% * M1 Cogmaster
% * Behavior, Emotion and Basal Ganglia team
% * Brain and Spine Institute

% This program

% ----------------------------------------------------------------------- %

%% Clear the workspace, set the diary and the recording file

% Clear the workspace and the command window, then set the diary
clc;
clear all;
diary 'MeCoDDeM_project.txt';

% DATA.Subject.Number = randi(1000,1,1);
% DATA.Subject.Group = upper(input('Subject group? (HS/OCD) ', 's'));
% DATA.Subject.Age = upper(input('Subject age? ', 's'));
% DATA.Subject.Initials = upper(input('Subject initials? ', 's'));
% DATA.Subject.Handedness = upper(input('Subject handedness? (L/R) ', 's'));
% DATA.Subject.Gender = upper(input('Subject gender? (M/F) ', 's'));
% DATA.Subject.Date = datestr(now);
% 
% DATA.Files.Name = ['MeCoDDeMproject_' DATA.Subject.Group '_' DATA.Subject.Initials '_' num2str(DATA.Subject.Number)];

%% Define parameters

% Set frequently used colors
colors.black = [0 0 0];
colors.white = [255 255 255];
colors.gray = [128 128 128];
colors.red = [255 0 0];

% Set frequently used keys
KbName('UnifyKeyNames');
keys.up = KbName('UpArrow');
keys.down = KbName('DownArrow');
keys.right = KbName('RightArrow');
keys.left = KbName('LeftArrow');
keys.space = KbName('space');

% Set paradigm parameters 
DATA.Paradigm.Blocks = 3;                                                  % 5 blocks of trials
DATA.Paradigm.Error = 10;                                                  % Allowed total error (L+R)
display.scale = 10;

% Set display parameters
display.screenNum = max(Screen('Screens'));
display.bkColor = colors.black;
display.dist = 60; % cm
display.width = 30; % cm
display.skipChecks = 1;                                                    % Avoid Screen's timing checks and verbosity

% Set up dot parameters
dots.nDots = round(1.5*(2*pi*((display.scale/2)^2)));
dots.speed = 5;
dots.lifetime = 12;
dots.apertureSize = [display.scale display.scale];
dots.center = [0 0];
dots.color = colors.white;
dots.size = 5;
dots.coherence = 0.7;
dots.duration = 0.750; % seconds

% Set type I forms parameters
display.T1.tick = display.scale/2;
display.T1.circle.size = display.scale;
display.T1.circle.color = colors.white;
display.T1.line.size = display.scale;
display.T1.line.color = colors.red;
display.T1.triangle.size = display.scale;
display.T1.triangle.color = colors.red;
display.T1.line.table_a = [89:-1:0];                                       % Variables for matching dots and arrow orientations
display.T1.line.table_b = [359:-1:90];
display.T1.line.table = [display.T1.line.table_a display.T1.line.table_b]; 

% Set type II forms parameters
display.T2.tick = display.scale/2;
display.rect1.size = display.scale;
display.rect1.color = colors.white;
display.rect2.color = colors.red;

% Set the parameters for the phasis 1 (calibration phasis)
DATA.Paradigm.Phasis1.Coherences_level = [0.2:.1:.9];
DATA.Paradigm.Phasis1.Coherences_level = transpose(DATA.Paradigm.Phasis1.Coherences_level);
DATA.Paradigm.Phasis1.Coherences_number = 6;
DATA.Paradigm.Phasis1.Coherences = repmat(DATA.Paradigm.Phasis1.Coherences_level, DATA.Paradigm.Phasis1.Coherences_number, 1);
DATA.Paradigm.Phasis1.Coherences = Shuffle(DATA.Paradigm.Phasis1.Coherences);
DATA.Paradigm.Phasis1.Trials = size(DATA.Paradigm.Phasis1.Coherences, 1);

% Set the parameters for the phasis 2 (evidence accumulation phasis)
DATA.Paradigm.Phasis2.Review_number = 2;
DATA.Paradigm.Phasis2.Facility_levels = [0, 5, 10, 15, 20]                 % Decreassing difficulty index
DATA.Paradigm.Phasis2.Trials = 0;

% Set the parameters for the phasis 3 (information seeking phasis)
DATA.Paradigm.Phasis3.Trials = 0;

% Get the total number of trials
DATA.Paradigm.Trials = 1%DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials + DATA.Paradigm.Phasis3.Trials;

% Set the first phasis (calibration phasis)
DATA.Paradigm.Phasis = 1;

try
    %% Start the trial
    for Trial_number = 1:1:DATA.Paradigm.Trials
        
        % Open a window, set the display matrix and get the center of the screen
        display = OpenWindow(display);
        display.center = display.resolution/2;
        
        % Display phasis 1 instructions
        if Trial_number == 1
            drawText(display, [0 2], 'INSTRUCTIONS', colors.white, 40);
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
        
        % STIMULUS
        
        % Define dots direction
        dots.direction = randi(360);
        DATA.Paradigm.Directions(Trial_number, 1) = dots.direction

        % Draw fixation cross during 2 seconds
        display = drawFixation(display);
        waitTill(2);
        
        % Show the stimulus
        movingDots(display, dots, dots.duration);

        % Black screen during 100 milisecond
        Screen('FillOval', display.windowPtr, display.bkColor);
        Screen('Flip',display.windowPtr);
        waitTill(.1);

        if DATA.Paradigm.Phasis == 2
            for Review = 2:1:DATA.Paradigm.Phasis2.Review_number
                % Define dots motion coherence
                if DATA.Paradigm.Phasis == 1
                    dots.coherence = DATA.Paradigm.Phasis1.Coherences(Trial_number);
                    DATA.Paradigm.Coherence(Trial_number, 1) = dots.coherence;
                elseif DATA.Paradigm.Phasis == 2
                    dots.coherence = DATA.Paradigm.Phasis1.Coherences(Trial_number, Review);
                    DATA.Paradigm.Coherence(Trial_number, Review) = dots.coherence;
                end

                % Draw fixation cross during 2 seconds
                display = drawFixation(display);
                waitTill(2);

                % Show the stimulus
                movingDots(display, dots, dots.duration);

                % Black screen during 100 milisecond
                Screen('FillOval', display.windowPtr, display.bkColor);
                Screen('Flip',display.windowPtr);
                waitTill(.1);
            end
        end

        % Get the response
        display.T1.line.angle = randi(360);
        DATA.Answers.Initial_Direction(Trial_number, 1) = display.T1.line.angle;
        DATA.Answers.Direction(Trial_number, 1) = NaN

        while true
            % Check the keys press and get the RT
            [keyIsDown, DATA.RTs.Perceptual_brut(Trial_number, 1), keyCode] = KbCheck;
            % Update the arrow according to key press
            drawT1Circle(display);
            if keyIsDown

                    if keyCode(keys.up)
                        % Increase angle with +1�
                        display.T1.line.angle = display.T1.line.angle + 1;
                        if display.T1.line.angle == 360
                        display.T1.line.angle = 0
                        end

                    elseif keyCode(keys.down)
                        % Decrease angle with -1�
                        display.T1.line.angle = display.T1.line.angle - 1;
                        if display.T1.line.angle == -1
                        display.T1.line.angle = 359
                        end

                    elseif keyCode(keys.space)
                        DATA.Answers.Direction(Trial_number, 1) = display.T1.line.table(display.T1.line.angle);
                        break;
                    end
            end
        end

        % Compute perceptual RT (brut and weighted according to the initial direction)
        if DATA.Answers.Direction(Trial_number, 1) ~= NaN
            DATA.RTs.Perceptual_weighted(Trial_number, 1) = DATA.RTs.Perceptual_brut(Trial_number, 1)/abs(DATA.Answers.Direction(Trial_number, 1) - DATA.Answers.Initial_Direction(Trial_number, 1));
        elseif DATA.Answers.Direction(Trial_number, 1) == NaN
            DATA.RTs.Perceptual_brut(Trial_number, 1) = NaN;
            DATA.RTs.Perceptual_weighted(Trial_number, 1) = NaN;
        end

        % Compute perceptual performance (margin define at the beginning of the script
        if DATA.Answers.Direction(Trial_number, 1) ~= NaN
            if abs(DATA.Paradigm.Directions(Trial_number, 1) - DATA.Answers.Direction(Trial_number, 1)) <= (DATA.Paradigm.Error/2)
                DATA.Answers.Correction(Trial_number, 1) = 1;
            elseif abs(DATA.Paradigm.Directions(Trial_number, 1) - DATA.Answers.Direction(Trial_number, 1)) > (DATA.Paradigm.Error/2)
                DATA.Answers.Correction(Trial_number, 1) = 0;
            end
        end            

        % Black screen during 100 milisecond
        Screen('FillOval', display.windowPtr, display.bkColor);
        Screen('Flip',display.windowPtr);
        waitTill(.1);

        %% CONFIDENCE

        display.rect2.size = randi([-display.rect1.size, display.rect1.size]);            
        DATA.Answers.Initial_Confidence(Trial_number, 1) = round(((display.rect2.size + display.rect1.size) / (2 * display.rect1.size)) * 100);
        DATA.Answers.Confidence(Trial_number, 1) = NaN;

        while true
            % Check the keys press and get the RT
            [keyIsDown, DATA.RTs.Confidence_brut(Trial_number, 1), keyCode] = KbCheck;
            % Update the red rectangle according to key press
            drawT2Rect(display);
            if keyIsDown

                    if keyCode(keys.right)
                        % Increase confidence score with +1%
                        display.rect2.size = display.rect2.size + ((2*display.rect1.size)/100);
                        if display.rect2.size > display.rect1.size
                        display.rect2.size = display.rect1.size;
                        end

                    elseif keyCode(keys.left)
                        % Decrease confidence score with -1%
                        display.rect2.size = display.rect2.size - ((2*display.rect1.size)/100);
                        if display.rect2.size < display.rect1.size*-1
                        display.rect2.size = display.rect1.size*-1;
                        end

                    elseif keyCode(keys.space)
                        % Get the confidence score on a 100 scale
                        DATA.Answers.Confidence(Trial_number, 1) = round(((display.rect2.size + display.rect1.size) / (2 * display.rect1.size)) * 100);
                        break;
                    end
            end

        if DATA.Answers.Confidence(Trial_number, 1) ~= NaN
            DATA.RTs.Confidence_weighted(Trial_number, 1) = DATA.RTs.Confidence_brut(Trial_number, 1)/abs(DATA.Answers.Initial_Confidence(Trial_number, 1) - DATA.Answers.Confidence(Trial_number, 1)) % � corriger
        elseif DATA.Answers.Confidence(Trial_number, 1) == NaN
            DATA.RTs.Confidence_brut(Trial_number, 1) = NaN;
            DATA.RTs.Confidence_weighted(Trial_number, 1) = NaN;
        end
        end

        %if Trial_number = (DATA.Paradigm.Trials.Phasis1/2) or Trial_number = (DATA.Paradigm.Trials.Phasis2/2) or Trial_number = (DATA.Paradigm.Trials.Phasis3/2)
            % Display a break screen
        %end

        %% Fitting the psychometric curve
        if DATA.Paradigm.Phasis == 1
            if Trial_number == DATA.Paradigm.Phasis1.Trials
                % Make a coherence x performance table
                DATA.Fit.Psychometric.Coherence = unique(DATA.Paradigm.Coherence);
                DATA.Fit.Psychometric.Performance = grpstats(DATA.Answers.Correction, DATA.Paradigm.Phasis1.Coherences);
                % Set the psychom�tric function
                DATA.Fit.Psychometric.SigFunc = @(F, x)(1./(1 + exp(-F(1)*(x-F(2)))));
                % Fit it
                DATA.Fit.Psychometric.SigFit = nlinfit(DATA.Fit.Psychometric.Coherence, DATA.Fit.Psychometric.Performance, DATA.Fit.Psychometric.SigFunc, [1 1]);

                figure(1)
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
                plot(DATA.Fit.Psychometric.Theoretical_x, (DATA.Paradigm.Error/360), 'c');
                % Set legend, axis and labels
                legend('Data', 'Fit', 'Theoretical', 'Chance', 'location', 'northwest')
                axis([0 1 0 1]);
                xlabel('Motion coherence'); 
                ylabel('Perceptual performance');
                % Sauver le graphique
                % savefig('Plot1.fig')

                % Get a coherence level according to a given performance
                DATA.Fit.Psychometric.Wanted_performance = .5;
                syms Target_coherence
                DATA.Fit.Psychometric.Halflife = double(solve((1./(1 + exp(-DATA.Fit.Psychometric.SigFit(1)*(Target_coherence - DATA.Fit.Psychometric.SigFit(2))))) == DATA.Fit.Psychometric.Wanted_performance));
            end
        end
        
        % Switch to phasis 2 when all the phasis 1 trials have been displayed
        if Trial_number == DATA.Paradigm.Phasis1.Trials
            DATA.Paradigm.Phasis = 2;
            % Display instructions for phasis 2
        end
        % Switch to phasis 3 when all the phasis 2 trials have been displayed
        if Trial_number == DATA.Paradigm.Phasis2.Trials
            DATA.Paradigm.Phasis = 3;
            % Display instructions for phasis 3
        end
    
    % Close all windows
    Screen('CloseAll');
    end

%% In case of error
catch error_message
Screen('CloseAll'); 
rethrow(error_message);
end

%% Fitting the OPIS model (Optimal Proactive Information Seeking)

%% Clear and save
DATA.Files.Name = 'Temporaire' 
% Save data
save(DATA.Files.Name, 'DATA', 'display', 'dots')
% Save the summary dataset in a csv file(DataSet, 'File', DATA.Files.Name '.csv', 'Delimiter', ',')

% Clear some useless variables
clear Block_number and Trial_number and Target_coherence and ans;
% Close the diary
diary off;