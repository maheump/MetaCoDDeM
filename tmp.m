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