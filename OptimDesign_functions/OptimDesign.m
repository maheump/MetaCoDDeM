function [x,Fit] = OptimDesign(action, varargin)
% Optimize Psychometric Fit for the METACODDEM Task (Phase 1)
%   [x,Fit] = OptimDesign(action, varargin)
%   'action' can be:
%       'initialize',Func,InitParameters:
%       'nexttrial': returns the next value to be sampled in 'x'
%       'register',answers: register the repsonse made by the subject
%       'results': returns the estimated parameters

persistent Fit %#ok<REDEF>
switch action
    
    case 'initialize'
        % values
        Fit.trial = 0 ;
        Fit.SigFunc = varargin{1};
        Fit.SigFit = varargin{2};
        Fit.GridU = 0:.01:1; % set of potential design control variables
        Fit.u = [];
        Fit.answers = [];        
        % configure simulation and VBA inversion
        dim.n_phi = 2;
        dim.n_theta = 0;
        dim.n=0;
        dim.n_t = 1;
        dim.p = 1;
        Fit.dim = dim;
        % options for the optimizer
        options.binomial = .014;
        options.priors.muPhi = [0;0];
        options.priors.SigmaPhi = 1e2*eye(2);
        options.DisplayWin = 0;
        options.verbose = 0;
        Fit.opt = options;        
        
    case 'nexttrial'
        Fit.trial = Fit.trial+1;        
        
        if Fit.trial == 1
            u(1) = min(Fit.GridU);
            eu(1) = VBA_designEfficiency([],Fit.SigFunc,Fit.dim,Fit.opt,Fit.u(1),'parameters');
        elseif Fit.trial==2
            u(2) = max(Fit.GridU);
            eu(2) = VBA_designEfficiency([],Fit.SigFunc,Fit.dim,Fit.opt,Fit.u(2),'parameters');
        else
            % find most efficient control variable
            for i=1:length(gridu)
                [e(i)] = VBA_designEfficiency([],g_fname,dim,opt,gridu(i),'parameters');
            end
            ind = find(e==max(e));
            u(t) = gridu(ind(1));
            eu(t) = e(ind(1));           
        end
        Fit.u(Fit.trial) = 
        
   
    case 'register'
        Fit.answers(trial) = varargin{1};
       % sample choice according to simulated params
        sx(t) = g_sigm_binomial([],phi,u(t),[]);
        [y(t)] = sampleFromArbitraryP([sx(t),1-sx(t)]',[1,0]',1);
        
        % invert model with all inputs and choices
        dim.p = t;
        [posterior,out] = VBA_NLStateSpaceModel(y(1:t),u(1:t),[],g_fname,dim,options);
        mu(:,t) = posterior.muPhi;
        va(:,t) = diag(posterior.SigmaPhi);
        
    case 'results'        
        x = Fit.SigFit(:,end);
    
    
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