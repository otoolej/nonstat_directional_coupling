%-------------------------------------------------------------------------------
% time_traj_coupling_examples: Examples of different time-varying coupling and
%                              associated features. Figure 4B and 4C in [1].
% 
%
% Syntax: time_traj_coupling_examples()
%
% Inputs: 
%     none
%
% Outputs: 
%     none
%
% Example:
%     time_traj_coupling_examples;
%
% 
% [1] JM O'Toole, EM Dempsey, D Van Laere, “Nonstationary coupling between heart rate and
% perfusion index in extremely preterm infants over the first day of life”, in
% preparation, 2019.

% John M. O' Toole, University College Cork
% Started: 03-07-2018
%
% last update: Time-stamp: <2019-05-22 13:09:20 (otoolej)>
%-------------------------------------------------------------------------------
function time_traj_coupling_examples()


N = 5000; N_iter = 1;
L_win = 150; overlap = 50;


% 1. generate signals and ST-iPDCs and coupling trajectories:
ft3 = do_traj(N, N_iter, L_win, overlap, 'nonstat2', 0);
ft4 = do_traj(N, N_iter, L_win, overlap, 'nonstat3', 1);


% 2. show summary features of this coupling:
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




function ft = do_traj(N, N_iter, L_win, overlap, type, cbar)
%---------------------------------------------------------------------
% generate PDCs and print
%---------------------------------------------------------------------
x_st = gen_syth_test_signals(N, N_iter, type);
pdc_st = shorttime_iPDC(x_st(1).x, L_win, overlap);

ft = traj_coupling_xy(pdc_st.pdc{1}, pdc_st.pdc{2}, N, cbar);




function feat_st = traj_coupling_xy(coh1, coh2, N, CBAR)
%---------------------------------------------------------------------
% track trajectory of coupling between x and y
%---------------------------------------------------------------------
[P, Q] = size(coh1);


coh1(isnan(coh1)) = 0;    
coh2(isnan(coh2)) = 0;

hr_pi_coords = NaN(P, 2);

%---------------------------------------------------------------------
% estimate the centroid with magnitude/angle:
%---------------------------------------------------------------------
irem = [];
for p = 1:P    
    hr_pi_coords(p, 1) = trapz(coh1(p, :)) / Q;
    hr_pi_coords(p, 2) = trapz(coh2(p, :)) / Q;
end    

av_co(1) = mean(hr_pi_coords(:, 1));
av_co(2) = mean(hr_pi_coords(:, 2));    


feat_st.mag = (sqrt(av_co(1) .^ 2 + av_co(2) .^ 2));
feat_st.angle = acos(av_co(1) / sqrt(av_co(1) .^ 2 + av_co(2) .^ 2));        


%---------------------------------------------------------------------
% plot:
%---------------------------------------------------------------------
figure(67 + CBAR); clf; hold all;
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
    xlabel(hcol, 'time (seconds)');
end
set(gca, 'position', [0.1282    0.1784    0.6238    0.7466]);
xlabel('y \rightarrow x'); 
ylabel('x\rightarrow y');    

