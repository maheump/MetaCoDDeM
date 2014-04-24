function [Sx,dsdx,dsdp] = g_sigm_binomial(chancelevel,Phi,u,varargin)
% Evaluates the sigmoid function for binomial data analysis
if nargin>3 && ~isempty(varargin{1})
    varargin{:}
end
persistent param
if ~isempty(chancelevel)
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

th = Phi(2);

bx = beta*(x-th);
Sx = param.G0./(1+exp(-bx));
Sx = Sx + param.S0;


% Récupérer les dérivés dX et db et dt de:
% http://www.wolframalpha.com/input/?i=d%2FdX%5BS+%2B+G+%2F%281+%2B+exp%28-b*%28X-t%29%29%29%5D

dsdx = beta*Sx.*(1-Sx./param.G0);

% evaluate derivative wrt x
% dsdx = b*Sx.*(1-Sx./in.G0);

if nargout < 3 ; return; end

dsdp = zeros(size(Phi,1),length(x));
%dsdp(1,:) = beta.*param.G0./(1+exp(-bx)).^2.*x.*exp(-bx);

dsdp(1,:) = (x-th).*param.beta.*dsdx;
%  dsdp(1,:) = (x-th).*in.beta.*dsdx;

if size(Phi,1) == 2
    dsdp(2,:) = -dsdx;
end
dsdp(isnan(dsdp)) = 0;

dsdx = [];
