function [varargout] = OptimDesign(action, varargin)
% Optimize Psychometric Fit for the METACODDEM Task (Phase 1)
%   [...] = OptimDesign(action, varargin)
%   'action' can be:
%       'initialize': Prepare the OptimDesign function 
%           OptimDesign('initialize',FuncHandle,StartingParameters);
%
%       'nexttrial': returns the next value to be sampled
%           [value,efficency] = OptimDesign('nexttrial');
%
%       'register',answers: register the response made by the subject
%           OptimDesign('register',accuracy);
%
%       'results': returns the estimated parameters and their variance
%           [mu,sigma2] = OptimDesign('results');

varargout = {};
persistent Fit %#ok<REDEF>
switch action
    
    case 'initialize'        
        % values
        Fit=[];
        Fit.trial = 0 ;
        Fit.FuncHandle = varargin{1};
        options.priors.muPhi = varargin{2};
        options.priors.SigmaPhi = varargin{3};
        Fit.GridU = varargin{4}; % set of potential design control variables
        Fit.u = [];
        Fit.answers = [];        
        % configure simulation and VBA inversion
        dim.n_phi = 2;%numel(options.priors.muPhi);
        dim.n_theta = 0;
        dim.n = 0;
        dim.n_t = 1;
        dim.p = 1;
        Fit.dim = dim;
        % options for the optimizer
        options.binomial = .014;
        options.DisplayWin = 0;
        options.verbose = 0;
        Fit.opt = options;    
        
    case 'nexttrial'
        
        % The Bayesian Magic Trick :
        if Fit.trial>1
            Fit.opt.priors.muPhi = Fit.posterior(end).muPhi;
            Fit.opt.priors.SigmaPhi = Fit.posterior(end).SigmaPhi;
        end
        Fit.trial = Fit.trial+1;
        
        if Fit.trial == 1
            % On the 1st trial we try at the minimum U
            u = min(Fit.GridU);
        elseif Fit.trial==2
            % On the 1st trial we try at the maximum U
            u = max(Fit.GridU);
        else
            %  In any other trial, we find the most efficient control variable
            u = Fit.GridU;
        end
                
        for i=1:numel(u)
            % Compute efficiency at each possible value of u            
            [e(i)] = VBA_designEfficiency([],Fit.FuncHandle,Fit.dim,Fit.opt,Fit.GridU(i),'parameters');
        end
        
        % Find the value yielding the highest efficiency
        best_index = find(e==max(e),1);
        % Use it to probe the participant        
        varargout = { u(best_index) e(best_index) };        
        Fit.u(Fit.trial) = u(best_index);
        Fit.efficency(Fit.trial) =  e(best_index);
        
   
    case 'register'
        % We register what the subject's response was
        Fit.answers(Fit.trial) = varargin{1};
        
        % Invert model with all previous trials
        dim = Fit.dim;
        dim.p = Fit.trial;
        [posterior] = VBA_NLStateSpaceModel(Fit.answers(:),Fit.u(:),[],Fit.FuncHandle,dim,Fit.opt);
        
            Fit.posterior(Fit.trial+1) = posterior;
        
        
    case 'results'        
        varargout{1} = Fit.posterior(end).muPhi;
        varargout{2} = Fit.posterior(end).SigmaPhi;        
        
    case 'plot'
        % compare final estimates with simulations
        displayResults(posterior,out,y,[],[],[],phi,[],[])        
        
        % summarize results of adaptive design strategy
        [handles] = displayUncertainSigmoid(posterior,out);
        set(handles.ha0,'nextplot','add')
        qx = g_sigm_binomial([],phi,gridu,[]);
        plot(handles.ha0,gridu,qx,'k--')
        VBA_ReDisplay(posterior,out)
        hf = figure('color',[1 1 1]);
        ha = axes('parent',hf);
        plot(ha,eu,'k','marker','.');
        ylabel(ha,'design efficiency')
        xlabel(ha,'trials')
        box(ha,'off')
        set(ha,'ygrid','on')

end
if nargout == numel(varargout)+1
    varargout = [varargout Fit];
end