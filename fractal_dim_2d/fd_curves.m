%-------------------------------------------------------------------------------
% fd_curves: fractal dimension for planar curves
%
% Syntax: D = fd_curves(x,y,kmax)
%
% Inputs: 
%     x,y,type - 
%
% Outputs: 
%     D - 
%
% Example:
%     
%
% [1] T. Higuchi, “Approach to an irregular time series on the basis of the fractal
% theory,” Phys. D Nonlinear Phenom., vol. 31, pp. 277–283, 1988.
% 
% [2] T. Higuchi, “Relationship between the fractal dimension and the power law index for
% a time series: a numerical investigation,” Phys. D Nonlinear Phenom., vol. 46,
% pp. 254–264, 1990
% 
% [3] JM O'Toole, EM Dempsey, D Van Laere, “Nonstationary coupling between heart rate and
% perfusion index in extremely preterm infants over the first day of life”, in
% preperation, 2019.


% John M. O' Toole, University College Cork
% Started: 30-05-2018
%
% last update: Time-stamp: <2019-05-03 14:50:50 (otoolej)>
%-------------------------------------------------------------------------------
function [D, r2] = fd_curves(x, y, kmax, DBplot)
if(nargin < 3 || isempty(kmax)), kmax = []; end
if(nargin < 4 || isempty(DBplot)), DBplot = 0; end


% check if input arguments ok:
N = length(x);
if(N == 1)
    D = NaN;
    return;
end
if(N ~= length(y))
    error('x and y must be same length.');
end

    

%---------------------------------------------------------------------
% Higuchi 1988 (modified for planar curves).
%---------------------------------------------------------------------
if(isempty(kmax)) 
    kmax = floor(N / 10); 
end
k_all = 1:kmax;

%---------------------------------------------------------------------
% curve length for each vector:
%---------------------------------------------------------------------
L_avg = zeros(1,length(k_all));
inext = 1; 
% iterate over all scales (k):
for k = k_all

    L = zeros(1,k);
    % iterate over different starting points:
    for m = 1:k
        N_seg = floor( (N-m) / k );
        ik = 1:N_seg;

        i1 = m + ik .* k;
        i2 = m + (ik - 1) .* k;

        % find the average distance between these points:
        L(m) = mean( sqrt((x(i1) - x(i2)) .^ 2 + (y(i1) - y(i2)) .^ 2) );            
    end

    L_avg(inext) = nanmedian(L); 
    inext = inext + 1;    
end
L_avg = L_avg ./ (k_all .^ 2);


% generate the scale-dependent fractal dimension: 
D_k = -diff(log(L_avg)) ./ diff(log(k_all));

% estimate the fractal dimension as the median value of scale-dependent D(k):
D = nanmedian(D_k);



%---------------------------------------------------------------------
% plot: log(L[k]) vs log(k)  and D(k) vs. log(k)
%---------------------------------------------------------------------
if(DBplot)
    x1 = log(k_all); 
    y1 = log(L_avg);        
    
    c = polyfit(x1, y1, 1);
    dispVars(-c(1));

    set_figure(56);
    subplot(2, 1, 1); hold all;        
    plot(x1, y1, 'o');
    xfit = linspace(min(x1), max(x1));
    plot(xfit, polyval(c, xfit), '-');
    xlabel('log(k)');
    ylabel('log[ L(k) ]');    
    
    subplot(2, 1, 2); hold all;
    D_k = -diff(y1) ./ diff(x1);
    fprintf('median D(k) = %g\n',nanmedian(D_k));

    plot(x1(1:end - 1), D_k, '*');
    line(xlim, [1 1] .* nanmedian(D_k));
    xlabel('log(k)');
    ylabel('D(k)');    
    
end


