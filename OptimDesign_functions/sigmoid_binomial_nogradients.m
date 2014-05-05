function [Sx] = sigmoid_binomial(chancelevel,Phi,u,varargin)
% Evaluates the sigmoid function for binomial data analysis
if nargin>3 && ~isempty(varargin{1})
    varargin{:}
end
persistent param
if ~isempty(chancelevel)
    if nargin>1
		error('To adjust the chance level, please use: sigmoid_binomial(chancelevel) ONLY!')
	end
	fprintf('Adjusting for chance level: %g%%\n', chancelevel*100);
    if ~isempty(param)
        fprintf('Previous chance level was: %g%%\n', param.S0*100);
    end
    param.G0 = 1-chancelevel;
    param.S0 = chancelevel;
    param.beta = 1/param.G0;
    param.INV = 0;
    if nargin==1        
        return
    end
elseif isempty(param)
    param.G0 = 1;
    param.S0 = 0;
    param.beta = 1;
    param.INV = 0;
end

%try,in.x;catch,in.x = 0;end
% if in.x % for learning effects (sigmoid parameters evolve over time)
%     [Sx,dsdx,dsdp] = sigm(u,in,x);
%     dsdx = dsdp;
%     dsdp = [];
% else
%   [Sx,dsdx,dsdp] = sigm(u,in,Phi);
%   dsdx = [];
% end

% return

param.deriv = 0;
param.mat = 0;

x = u ;
x = x(:)';

beta = param.beta.*exp(Phi(1));
%beta = param.beta;

th = Phi(2);

bx = beta*(x-th);
Sx = param.G0./(1+exp(-bx));
Sx = Sx + param.S0;

% dP/dx = (beta*param.G0*exp(beta*(th-x)))/((exp(beta*(th-x))+1)^2);
% dP/dx = (beta*param.G0*exp(beta*(x-th)))/((exp(beta*(x-th))+1)^2);

% dX
% dsdx = (beta*param.G0*exp(beta*(th+x)))/((exp(beta*th)+exp(beta*x))^2);
% dsdx = (beta*param.G0*exp(beta*(th-x)))/((exp(beta*(th-x))+1)^2);
% dsdx = (beta*param.G0*exp(beta*(x-th)))/((exp(beta*(x-th))+1)^2);
%
% db
% dsdx = -(param.G0*(th-x)*exp(beta*(th-x)))/((exp(beta*th)+exp(beta*x))^2);
% dsdx = -(param.G0*(th-x)*exp(beta*(th+x)))/((exp(beta*(th-x))+1)^2);
% dsdx = -(param.G0*(th-x)*exp(beta*(x-th)))/((exp(beta*(th-x))+1)^2);
%
% dt
% dsdx = -(beta*param.G0*exp(beta*(th+x)))/((exp(beta*th)+exp(beta*x))^2);
% dsdx = -(beta*param.G0*exp(beta*(th-x)))/((exp(beta*(th-x))+1)^2);
% dsdx = -(beta*param.G0*exp(beta*(x-th)))/((exp(beta*(x-th))+1)^2);

% Formule MBB
dsdx = beta*Sx.*(1-Sx./param.G0);

% Wolfram:
% S(x) = S + G/(1+exp(-b*(x-th)))
% ds/dx =
% dsdx = (b*G*exp(b*(th+x)))/((exp(b*th)+exp(b*x))^2);
% dsdx = (b*G*exp(b*(th-x)))/(exp(b*(th-x))+1)^2;
% dsdx = (b*G*exp(b*(x-th)))/(exp(b*(x-th))+1)^2;

% Formule de Karim
% dsdx = (beta*(param.G0+(param.G0./(1+exp(-bx)))))/(exp(beta*(x-th))+1)^2;
% Formule de Maxime
% dsdx = (beta*(param.G0+(param.G0./(1+exp(-bx)))))*((1-(param.G0+(param.G0./(1+exp(-bx)))))/param.G0);

% Donc si: 
% Sx  = S0 + G0./(1+exp(-bx))
% bx = beta*(x-th) soit: beta=bx/(x-th) 
% alors : dsdx =  beta * (S0 + G0/(1+exp(-beta*(x-th)))) * (1 - (S0 + G0/(1+exp(-beta*(x-th))))/G0)

% evaluate derivative wrt x
% dsdx = b*Sx.*(1-Sx./in.G0); % Celle de sigm.m

if nargout < 3 ; return; end

dsdp = zeros(size(Phi,1),length(x));
%dsdp(1,:) = beta.*param.G0./(1+exp(-bx)).^2.*x.*exp(-bx);

% Formule MBB (la bonne) : 
dsdp(1,:) = (x-th).*param.beta.*dsdx;

% D'après Wolfram, c'est plutôt : 
% dsdp(1,:) = (x-th)./param.beta.*dsdx;

% dsdp(1,:) = (x-th).*in.beta.*dsdx; % Dans sigm.m c'est bien cette formule (Wolfram a tord => c'est la formule initiale (primitive) qui est donc erronnée).

if size(Phi,1) == 2
    dsdp(2,:) = -dsdx;
end
dsdp(isnan(dsdp)) = 0;

dsdx = [];

% vérifié : bx, beta
% Il n'y a pas qu'un seul Sx car param.G0 est une structure de taille
% différente