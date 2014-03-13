%%% ------------------------------------------------------------------------------------- %%%
%%%                             SCRIPT OF THE MECODDEM PROJECT                            %%%
%%%                 ("MEtacognitive COntrol During DEcision-Making" task)                 %%%
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
%clear all;
diary 'MeCoDDeM_project.txt';

% DATA.Subject.Number = randi(1000,1,1);
% DATA.Subject.Group = upper(input('Subject group? (HS/OCD/DLGG) ', 's'));
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
DATA.Paradigm.Step = 15; % Step  
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
dots.duration = 1; % seconds

% Set a correponding table between dots angle (classic) and line angle (trigonometric)
display.T1.line.table_a = [0:DATA.Paradigm.Step:359];
display.T1.line.table_b = [90:-DATA.Paradigm.Step:0];
display.T1.line.table_c = [360:-DATA.Paradigm.Step:91];
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
DATA.Paradigm.Phasis1.Coherences_margin = .2
DATA.Paradigm.Phasis1.Coherences_level = [0.1:DATA.Paradigm.Phasis1.Coherences_margin:(1 - DATA.Paradigm.Phasis1.Coherences_margin)]; % Define the list of coherence levels
DATA.Paradigm.Phasis1.Coherences_level = transpose(DATA.Paradigm.Phasis1.Coherences_level); % Transform it into a column
DATA.Paradigm.Phasis1.Coherences_number = 20; % Number of trials per coherence level
DATA.Paradigm.Phasis1.Coherences = repmat(DATA.Paradigm.Phasis1.Coherences_level, DATA.Paradigm.Phasis1.Coherences_number, 1); % Repeat each coherence level a certain number of time
DATA.Paradigm.Phasis1.Coherences = Shuffle(DATA.Paradigm.Phasis1.Coherences); % Shuffle it
DATA.Paradigm.Phasis1.Trials = 1%size(DATA.Paradigm.Phasis1.Coherences, 1); % The phasis 1 total number of trials is the size of this coherence list

% Set the parameters for the phasis 2 (evidence accumulation phasis)
DATA.Paradigm.Phasis2.Viewing_number = 2;
DATA.Paradigm.Phasis2.Facility_levels = [0,.05,.10,.15]; % Decreasing difficulty index
DATA.Paradigm.Phasis2.Accuracies_number = 5; % Number of trials per accuracy level
DATA.Paradigm.Phasis2.Accuracies_levels = [0.5:.05:(1 - ((DATA.Paradigm.Phasis2.Viewing_number - 1)*DATA.Paradigm.Phasis2.Facility_levels(end)))];
DATA.Paradigm.Phasis2.Accuracies = repmat(DATA.Paradigm.Phasis2.Accuracies_levels, 1, size(DATA.Paradigm.Phasis2.Facility_levels, 2)*DATA.Paradigm.Phasis2.Accuracies_number);
DATA.Paradigm.Phasis2.Accuracies = transpose(DATA.Paradigm.Phasis2.Accuracies);
DATA.Paradigm.Phasis2.Accuracies = Shuffle(DATA.Paradigm.Phasis2.Accuracies);
for i = 1:1:size(DATA.Paradigm.Phasis2.Facility_levels, 2)
    DATA.Paradigm.Phasis2.Facilities(:,i) = [repmat(DATA.Paradigm.Phasis2.Facility_levels(i), 1, size(DATA.Paradigm.Phasis2.Accuracies_levels, 2)*DATA.Paradigm.Phasis2.Accuracies_number)];
end
DATA.Paradigm.Phasis2.Facilities = DATA.Paradigm.Phasis2.Facilities( : );
DATA.Paradigm.Phasis2.Facilities = Shuffle(DATA.Paradigm.Phasis2.Facilities);
DATA.Paradigm.Phasis2.Design = [DATA.Paradigm.Phasis2.Accuracies DATA.Paradigm.Phasis2.Facilities (DATA.Paradigm.Phasis2.Accuracies + DATA.Paradigm.Phasis2.Facilities)];
DATA.Paradigm.Phasis2.Trials = 3%size(DATA.Paradigm.Phasis2.Design, 1);

% Set the parameters for the phasis 3 (information seeking phasis)
DATA.Paradigm.Phasis3.Gains = [100,-200;80,-80;70,-70;60,-60;50,-50];
DATA.Paradigm.Phasis3.Trials = 0;

% Get the total number of trials
DATA.Paradigm.Trials = DATA.Paradigm.Phasis1.Trials + DATA.Paradigm.Phasis2.Trials + DATA.Paradigm.Phasis3.Trials;

try
    %% Start the trial
    
    % Open a window, set the display matrix and get the center of the screen
    display = OpenWindow(display);
    display.center = display.resolution/2;
      
    % Set the first phasis (calibration phasis)
    Phasis_number = 1;
    
    for Trial_number = 1:1:DATA.Paradigm.Trials
        
        % Display phasis 1 instructions
        if Trial_number == 1
            drawText(display, [0 0], 'INSTRUCTIONS', colors.white, 40);
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
        dots.direction = display.T1.line.table_a(randi(size(display.T1.line.table_a)));
        DATA.Paradigm.Directions(Trial_number, 1) = dots.direction
        
        % Define dots motion coherence
        if Phasis_number == 1
            dots.coherence = DATA.Paradigm.Phasis1.Coherences(Trial_number);
        % Get a coherence level according to a given performance
        elseif Phasis_number == 2
            syms Target_coherence
            DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 1) = double(solve((1./(1 + exp(-DATA.Fit.Psychometric.SigFit(1)*(Target_coherence - DATA.Fit.Psychometric.SigFit(2))))) == DATA.Paradigm.Phasis2.Design(Trial_number - DATA.Paradigm.Phasis1.Trials, 1)));
            dots.coherence = DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials);
        elseif Phasis_number == 3
            syms Target_coherence
            DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1) = double(solve((1./(1 + exp(-DATA.Fit.Psychometric.SigFit(1)*(Target_coherence - DATA.Fit.Psychometric.SigFit(2))))) == DATA.Paradigm.Phasis2.Design(Trial_number - DATA.Paradigm.Phasis1.Trials - DATA.Paradigm.Phasis2.Trials, 1)));
            dots.coherence = DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials);
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
                DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 3) = double(solve((1./(1 + exp(-DATA.Fit.Psychometric.SigFit(1)*(Target_coherence - DATA.Fit.Psychometric.SigFit(2))))) == DATA.Paradigm.Phasis2.Design(Trial_number - DATA.Paradigm.Phasis1.Trials, 1)));
                dots.coherence = DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials);
                % Save the difference between the first sample coherence and the second sample one
                DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 2) = DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 3) - DATA.Paradigm.Phasis2.Coherences(Trial_number - DATA.Paradigm.Phasis1.Trials, 1);
                
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
        
        if Phasis_number == 1%3
            % Display choice
            choice = 1;
            drawT3Info(display, choice, DATA.Paradigm.Phasis3.Gains);
            while true
                % Check the keys press and get the RT
                [keyIsDown, DATA.RTs.Phasis3.Choice(Trial_number, 1), keyCode] = KbCheck;
                % Update the arrow according to key press
                drawT3Info(display, choice, DATA.Paradigm.Phasis3.Gains);

                if keyIsDown

                        if keyCode(keys.up)
                            % 
                            choice = 1; 

                        elseif keyCode(keys.down)
                            %
                            choice = 2;
                            
                        elseif keyCode(keys.left)
                            choice = 3;
                            
                        elseif keyCode(keys.right)
                            choice = 5;

                        elseif keyCode(keys.space)
                            % Get
                            display.T3.Answers.Information = choice; % à modifier 
                            waitTill(.1);
                            break;
                        end
                end
            end
        end

        % Get the response
        display.T1.line.index = 1 %randi(size(display.T1.line.table, 2)); % Column number
        display.T1.line.angle = display.T1.line.table(2, display.T1.line.index);
        DATA.Answers.Initial_Direction(Trial_number, 1) = display.T1.line.angle;
        DATA.Answers.Direction(Trial_number, 1) = NaN

        while true
            % Check the keys press and get the RT
            [keyIsDown, DATA.RTs.Perceptual_brut(Trial_number, 1), keyCode] = KbCheck;
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
            waitTill(.1);
            end
        end

        % Compute perceptual RT (brut and weighted according to the initial direction)
        if DATA.Answers.Direction(Trial_number, 1) ~= NaN
            DATA.RTs.Perceptual_weighted(Trial_number, 1) = DATA.RTs.Perceptual_brut(Trial_number, 1)/abs(DATA.Answers.Direction(Trial_number, 1) - DATA.Answers.Initial_Direction(Trial_number, 1));
        elseif DATA.Answers.Direction(Trial_number, 1) == NaN
            DATA.RTs.Perceptual_brut(Trial_number, 1) = NaN;
            DATA.RTs.Perceptual_weighted(Trial_number, 1) = NaN;
        end

        % Compute perceptual performance
        if DATA.Answers.Direction(Trial_number, 1) ~= NaN
            if abs(DATA.Paradigm.Directions(Trial_number, 1) == DATA.Answers.Direction(Trial_number, 1))
                DATA.Answers.Correction(Trial_number, 1) = 1;
            elseif abs(DATA.Paradigm.Directions(Trial_number, 1) ~= DATA.Answers.Direction(Trial_number, 1))
                DATA.Answers.Correction(Trial_number, 1) = 0;
            end
        end            

        % Black screen during 100 milisecond
        Screen('FillOval', display.windowPtr, display.bkColor);
        Screen('Flip',display.windowPtr);
        waitTill(.1);

        %% CONFIDENCE

        display.T2.rect2.size = randi([-display.T2.rect1.size, display.T2.rect1.size]);            
        DATA.Answers.Initial_Confidence(Trial_number, 1) = round(((display.T2.rect2.size + display.T2.rect1.size) / (2 * display.T2.rect1.size)) * 100);
        DATA.Answers.Confidence(Trial_number, 1) = NaN;

        while true
            % Check the keys press and get the RT
            [keyIsDown, DATA.RTs.Confidence_brut(Trial_number, 1), keyCode] = KbCheck;
            
            % Display instructions
            if Phasis_number == 1
                drawText(display, [0, (display.T2.rect1.size - display.T2.rect1.size/4)], 'Veuillez donner votre niveau de confiance dans votre réponse', [255 255 255], 40);
            elseif Phasis_number == 2 % à modifier
                drawText(display, [0, (display.T2.rect1.size - display.T2.rect1.size/4)], 'Veuillez donner votre niveau de confiance dans votre réponse', [255 255 255], 40);
            elseif Phasis_number == 3 % à modifier
                drawText(display, [0, (display.T2.rect1.size - display.T2.rect1.size/4)], 'Veuillez donner votre niveau de confiance si vous aviez dû répondre', [255 255 255], 40);
            end
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
                        % Get the confidence score on a 100 scale
                        DATA.Answers.Confidence(Trial_number, 1) = round(((display.T2.rect2.size + display.T2.rect1.size) / (2 * display.T2.rect1.size)) * 100);
                        waitTill(.1);
                        break;
                    end
            end

        if DATA.Answers.Confidence(Trial_number, 1) ~= NaN
            DATA.RTs.Confidence_weighted(Trial_number, 1) = DATA.RTs.Confidence_brut(Trial_number, 1)/abs(DATA.Answers.Initial_Confidence(Trial_number, 1) - DATA.Answers.Confidence(Trial_number, 1)) % à corriger
        elseif DATA.Answers.Confidence(Trial_number, 1) == NaN
            DATA.RTs.Confidence_brut(Trial_number, 1) = NaN;
            DATA.RTs.Confidence_weighted(Trial_number, 1) = NaN;
        end
        end

        % Display a break screen
        if ((Trial_number == (DATA.Paradigm.Phasis1.Trials/2)) | (Trial_number == (DATA.Paradigm.Phasis2.Trials/2)) | (Trial_number == (DATA.Paradigm.Phasis3.Trials/2)))
            drawText(display, [0 2], 'Faîtes une pause d''une ou deux minutes', colors.white, 40);
            drawText(display, [0 -2], '(Appuyer sur n''importe quelle touche pour continuer)', colors.white, 20);
            Screen('Flip',display.windowPtr);
            while KbCheck; end
            KbWait;
        end

        %% Fitting the psychometric curve
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
                % Draw the figure
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
                plot(DATA.Fit.Psychometric.Theoretical_x, DATA.Fit.Psychometric.Chance, 'c-');
                % Set legend, axis and labels
                legend('Data', 'Fit', 'Theoretical', 'Chance', 'location', 'northwest');
                axis([0 1 0 1]);
                xlabel('Motion coherence'); 
                ylabel('Perceptual performance');
                % Sauver le graphique
                %%%%%%%%%%%%%%% savefig(DATA.Files.Name, '.fig')
                % Get a coherence level according to a given performance
                syms Target_coherence
                DATA.Fit.Psychometric.C50 = double(solve((1./(1 + exp(-DATA.Fit.Psychometric.SigFit(1)*(Target_coherence - DATA.Fit.Psychometric.SigFit(2))))) == .5));
            end
        end
        
        % Switch to phasis 2 when all the phasis 1 trials have been displayed
        if Trial_number == DATA.Paradigm.Phasis1.Trials
            Phasis_number = 2;
            % Display instructions for phasis 2
        end
        % Switch to phasis 3 when all the phasis 2 trials have been displayed
        if Trial_number == DATA.Paradigm.Phasis2.Trials
            Phasis_number = 3;
            % Display instructions for phasis 3
        end
    end
     
    % Close all windows
    Screen('CloseAll');

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
clear Phasis_number and Trial_number and Target_coherence and ans and i;
% Close the diary
diary off;