%-------------------------------------------------------------------------------
% plot_FD_examples: fractal dimension (FD) estimate for 3 x 2D signals.
%                         (Figure 2 in [1])
%
% Syntax: plot_FD_examples()
% 
% Inputs: 
%     none
% 
% Outputs: 
%     none
% 
% Example:
%         plot_FD_examples;
% 
% 
% [1] JM O'Toole, EM Dempsey, D Van Laere, “Nonstationary coupling between heart rate and
% perfusion index in extremely preterm infants over the first day of life”, in
% preparation, 2019.


% John M. O' Toole, University College Cork
% Started: 06-06-2018
%
% last update: Time-stamp: <2019-05-22 13:13:53 (otoolej)>
%-------------------------------------------------------------------------------
function [] = plot_FD_examples()


%---------------------------------------------------------------------
% 1. generate the signals
%---------------------------------------------------------------------
N = 50; 
sig_types = {'line', '2D_CGN', '2D_WGN'};
L = length(sig_types);
kmax = 6;

x = zeros(L, N); 
y = zeros(L, N);
for n = 1:L
    [x(n, :), y(n, :)] = nonuniform_sampling(N, sig_types{n});
end


%---------------------------------------------------------------------
% 2. plot the signals and estimate the fractal dimension
%---------------------------------------------------------------------

% set up the figure:
figure(28); clf; hold all;
pp = get(gcf, 'position');
set(gcf, 'position', [pp(1:2) 700  200]);

% colours and fonts:
lc = lines(8);
fill_col = lc(7, :);
edge_col = lc(1, :);
FONT_NAME = 'helvetica';
FONT_SIZE = 10;

D = zeros(1, L);
for n = 1:L
    % plot the 2D data:
    hx(n) = subplot(1, 3, n); hold all;
    hl(n) = plot(x(n, :), y(n, :), '-s');
    set(hl(n), 'markerfacecolor', fill_col, 'color', edge_col); 
    hx(n).XAxis.Visible = 'off';
    hx(n).YAxis.Visible = 'off';    
    
    % estimate the FD:
    D(n) = fd_curves(x(n, :), y(n, :), kmax, 0); 
end


%---------------------------------------------------------------------
% 3. place FD on plots:
%---------------------------------------------------------------------
xs = [0 133 133 * 2]; ys = [106 -30];
txy = [xs(1) ys(1); xs(2) ys(1); xs(3) ys(1)];
for n = 1:L
    ht(n) = text(hx(1), txy(n, 1), txy(n, 2), ['D=' sprintf('%.1f', D(n))], ...
                 'fontname', FONT_NAME, 'fontsize', FONT_SIZE);
end





function [x, y] = nonuniform_sampling(N, type)
%---------------------------------------------------------------------
% 2D signals with non-uniform sampling
%---------------------------------------------------------------------
N_over = 2 * N;

switch type
  case 'line'
    x = 1:N_over; y = 1:N_over;
    
    x = datasample(x, N, 'Replace', false);
    x = sort(x);
    y = y(x);
    
  case '2D_CGN'
    x = cumsum(randn(1, N)); 
    y = cumsum(randn(1, N));
    
  case '2D_WGN'
    x = rand(1, N); 
    y = rand(1, N);
    
end

