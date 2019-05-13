%-------------------------------------------------------------------------------
% time_traj_coupling_examples: 
%
% Syntax: []=time_traj_coupling_examples()
%
% Inputs: 
%      - 
%
% Outputs: 
%     [] - 
%
% Example:
%     
%

% John M. O' Toole, University College Cork
% Started: 03-07-2018
%
% last update: Time-stamp: <2018-08-30 12:14:18 (otoolej)>
%-------------------------------------------------------------------------------
function []=time_traj_coupling_examples(PRINT_)
if(nargin<1 || isempty(PRINT_)), PRINT_=0; end


pi_parameters;

N = 5000; N_iter = 1;
L_win = 150; overlap = 50;


% 0. generate signals and ST-iPDCs
ft3 = do_traj(N, N_iter, L_win, overlap, 'nonstat3', 0, PRINT_);
ft4 = do_traj(N, N_iter, L_win, overlap, 'nonstat4', 1, PRINT_);

fprintf('\n** Example 2:\n');
fn = fieldnames(ft3);
for n = 1:length(fn)
    fprintf('feature %s = %g\n', fn{n}, ft3.(char(fn{n})));
end
fprintf('\n** Example 3:\n');
fn = fieldnames(ft4);
for n = 1:length(fn)
    fprintf('feature %s = %g\n', fn{n}, ft4.(char(fn{n})));
end




function ft = do_traj(N, N_iter, L_win, overlap, type, cbar, PRINT_)
%---------------------------------------------------------------------
% generate PDCs and print
%---------------------------------------------------------------------
[y_st, b, c]= gen_syth_test_signals(N, N_iter, type);
pdc_st = shorttime_iPDC(y_st(1), L_win, overlap);

ft = traj_coupling_xy(pdc_st.pdc{1}, pdc_st.pdc{2}, N, cbar);

fn = fieldnames(ft);
for n = 1:length(fn)
    fprintf('feature %s = %g\n', fn{n}, ft.(char(fn{n})));
end


if(PRINT_)
    pi_parameters;
    print2eps([PIC_DIR 'traj_coup_' type '_v1.eps']);
end




function feat_st=traj_coupling_xy(coh1, coh2, N, CBAR)
%---------------------------------------------------------------------
% track trajectory of coupling between x and y
%---------------------------------------------------------------------
FONT_NAME = 'helvetica';
FONT_SIZE = 11;

%---------------------------------------------------------------------
% 
%---------------------------------------------------------------------
[P, Q] = size(coh1);

coh1(isnan(coh1)) = 0;    
coh2(isnan(coh2)) = 0;

hr_pi_coords = NaN(P, 2);

irem = [];
for p = 1:P    
    hr_pi_coords(p, 1) = trapz(coh1(p, :)) / Q;
    hr_pi_coords(p, 2) = trapz(coh2(p, :)) / Q;
end    

% up-sample:
% $$$ N = size(hr_pi_coords, 1);
% $$$ hr_pi_UP(:, 1) = interp1(1:N, hr_pi_coords(:, 1), 1:0.1:N);
% $$$ hr_pi_UP(:, 2) = interp1(1:N, hr_pi_coords(:, 2), 1:0.1:N);
% $$$ 
% $$$ hr_pi_coords = hr_pi_UP;
% $$$ N = size(hr_pi_coords, 1);
% $$$ P = N;

if(~isempty(find(isnan(hr_pi_coords))))
    keyboard;
end

% $$$ keyboard;
av_co(1) = mean(hr_pi_coords(:, 1));
av_co(2) = mean(hr_pi_coords(:, 2));    

feat_st.d = fd_curves([(hr_pi_coords(:, 1))], (hr_pi_coords(:, 2)), 'higuchi', 6);    
feat_st.mag = (sqrt(av_co(1) .^ 2 + av_co(2) .^ 2));
feat_st.angle = acos(av_co(1) / sqrt(av_co(1) .^ 2 + av_co(2) .^ 2));        



set_figure(67 + CBAR); 
pp = get(gcf, 'position');
set(gcf, 'position', [pp(1:2) 420  260]);

line_col = lines(1); %  [1 1 1] .* 0.7;
hline = plot(hr_pi_coords(:, 1), hr_pi_coords(:, 2), '-', 'linewidth', 1, 'color', line_col);

colormap(copper(P));
xtime = linspace(0, N, P);
hscat = scatter(hr_pi_coords(:, 1), hr_pi_coords(:, 2), 40, xtime, 'filled');

%  plot the centroid:
dot_col = lines(8); 
dot_col = dot_col(2, :);
hcent = plot(av_co(1), av_co(2), '*', 'markersize', 8, 'color', dot_col, ...
         'markerfacecolor', dot_col, 'markeredgecolor', 'k');
hleg = legend(hcent, 'centroid');
hleg.Box = 'off';

xlim([0 0.4]);
ylim([0 0.6]);


%  include colorbar:
if(CBAR)
    hcol = colorbar;
    xlabel(hcol, 'time (seconds)', ...
           'fontname', FONT_NAME, 'fontsize', FONT_SIZE);
    set(hcol, 'fontname', FONT_NAME, 'fontsize', FONT_SIZE);
end


set(gca, 'position', [0.1282    0.1784    0.6238    0.7466]);




xlabel('y \rightarrow x'); ylabel('x\rightarrow y');    

set_gca_fonts(FONT_NAME, FONT_SIZE)
