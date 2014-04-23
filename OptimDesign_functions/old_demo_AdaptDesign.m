% demo for binomial data inversion with adaptative design
% This demo simulates a psychophysics paradigm similar to a signal
% detection task, whereby the detection probability is a sigmoidal function
% of the stimulus contrast (which is the design control variable). However,
% neither does one know the inflexion point (detection threshold) nor the
% sigmoid steepness (d prime). Thus, the design is adpated online, in the
% aim of providing the most efficient estimate of these model parameters,
% given trial-by-trial subjects' binary choice data (seen/unseen).

clear variables
close all

% Pour nous, param�tre de design = niveau de coh�rence
p = 100; % Nombre de trials
phi = [3;.20]; % Param�tres simul�s [log sigmoid slope ; inflexion point]
gridu = 0.01:0.01:1; % Variables de design potentielles

% configure simulation and VBA inversion 
dim.n_phi = 2;
dim.n_theta = 0;
dim.n=0;
dim.n_t = 1;
dim.p = p;
g_fname = @g_sigm_binomial;
options.binomial = 1;
options.priors.muPhi = [0;0]; % A priori � propos des param�tres de la sigmo�de
options.priors.SigmaPhi = 1e2*eye(2);
options.DisplayWin = 0;
options.verbose = 0;
opt = options;

%% D�finis les subplots qui seront mis � jour en temps r�el (post�rieur bay�sien)

posterior = options.priors;
hf = figure('color',[1 1 1]);
ha = subplot(2,1,1,'parent',hf);
ha2 = subplot(2,1,2,'parent',hf);
set(ha,'nextplot','add')
set(ha2,'nextplot','add')
xlabel(ha,'trials')
ylabel(ha,'sigmoid parameters')
xlabel(ha2,'u: design control variable (stimulus contrast)')
ylabel(ha2,'design efficiency')

%% Pr�pare les variables

y = zeros(p,1);
u = zeros(p,1);
sx = zeros(p,1);
eu = zeros(p,1);
mu = zeros(dim.n_phi,p);
va = zeros(dim.n_phi,p);

%% Pour chaque trial
for t=1:p
    
    % On met � jour le prior de l'efficience de design
    dim.p = 1;
    opt.priors = posterior;
    
    if t==1 % Pour le premier trial
        u(1) = min(gridu); % On commence par la valeur de design la plus petite
        eu(1) = VBA_designEfficiency([],g_fname,dim,opt,u(1),'parameters'); % On calcule l'efficience associ�e
    
    elseif t==2 % Pour le second trial
        u(2) = max(gridu); % On fait ensuite la valeur du design la plus grande
        eu(2) = VBA_designEfficiency([],g_fname,dim,opt,u(2),'parameters'); % On calcule l'efficience associ�e
    
    else % Pour tous les autres trials
        
        % find most efficient control variable
        for i=1:length(gridu) % Pour chaque valeur de design
            [e(i)] = VBA_designEfficiency([],g_fname,dim,opt,gridu(i),'parameters'); % Calcule l'efficience de design que son test apporterait
        end
        ind = find(e==max(e)); % Trouver la ligne correspondant � la valeur d'optimisation de design maximum
        u(t) = gridu(ind(1)); % Utiliser ce num�ro de ligne pour retrouver le param�tre de design �quivalent
        eu(t) = e(ind(1)); % Stocke la valeur d'optimisation de design maximum dans une liste
        
        % display design eficiency as a function of control variable
        cla(ha2) % Clear current axis
        plot(ha2,gridu,e) % Plotter dans le 2e subplot, la liste des variables de design potentielles en fonction de la valeur d'optimisation du design
        plot(ha2,gridu(ind),e(ind),'go') % Plotter dans le 2e subplot, le param�tre de design ayant la plus grande valeur d'optimisation de design associ�e
        drawnow % Le dessiner
    end % Fin de la boucle pour tous les trials
    
    % Choisit une r�ponse � partir des param�tres de la sigmo�de entr�e et au d�but et en fonction du param�tre de design pr�sent� � ce trial
    sx(t) = g_sigm_binomial([],phi,u(t),int); % u est le param�tre de design et phi les param�tres de la sigmo�de
    [y(t)] = sampleFromArbitraryP([sx(t),1-sx(t)]',[1,0]',1); % Obtient et stocke la r�ponse, bonne ou mauvaise (en fait ici vu/non-vu)
    
    % invert model with all inputs and choices
    dim.p = t; % La dimension du truc est le nombre de trial � cet instant
    [posterior,out] = VBA_NLStateSpaceModel(y(1:t),u(1:t),[],g_fname,dim,options); % Obtient le post�rieur sur la base de l'histoire des r�ponses (dont la derni�re)
    mu(:,t) = posterior.muPhi; % Obtient les param�tres de la sigmo�de cible
    va(:,t) = diag(posterior.SigmaPhi); % Matrice de corr�lation a posteriori entre les param�tres de la sigmo�de cible (?)
    
    % display posterior credible intervals
    if t > 1 % Pour tous les trials apr�s le premier
        cla(ha) % Clear current axis
        plotUncertainTimeSeries(mu(:,1:t),sqrt(va(:,1:t)),1:t,ha,1:2); % Plotte dans le premier subplot
    end
end

%% Compare les r�sultats finaux extim�s avec les param�tres d'entr�e
displayResults(posterior,out,y,[],[],[],phi,[],[])

%% R�sume les r�sultats de la strat�gie d'adaptation de design
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