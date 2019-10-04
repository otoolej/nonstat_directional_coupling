%-------------------------------------------------------------------------------
% feats_direction_coupling_STiPDC: features to quantify the time-varying changes in
%                                  the direction of the coupling between the short-time
%                                  information partial directed coherence (ST-iPDC)
%                                  functions. See [1] for more details.
%
% Syntax: [feat_st] = feats_direction_coupling_STiPDC(st_pdc1, st_pdc2)
%
% Inputs: 
%     st_pdc1 - ST-iPDC function of bi-variate signal (x1 -> x2)
%     st_pdc2 - ST-iPDC function of bi-variate signal (x2 -> x1)
%
% Outputs: 
%     feat_st - structure containing following fields:
%                .mag        = magnitude of centroid
%                .angle      = angle of centroid
%                .D          = fractal dimension
% 
%
% Example:
%       % parameters for test signal:
%       N = 5000; 
%       L_win = 150; 
%       overlap = 50;
%       
%       x_st = gen_syth_test_signals(N, 1, 'nonstat3');
%       
%       % estimate the ST-iPDC: 
%       pdc_st = shorttime_iPDC(x_st(1).x, L_win, overlap, {'x1', 'x2'}, 1);
%       
%       % generate features of time-varying x1 -> x2 and x2 -> x1 coupling:
%       DBplot = 1;
%       feat_st = feats_direction_coupling_STiPDC(pdc_st.pdc{1}, pdc_st.pdc{2}, DBplot);
% 
%       % show features:
%       disp(feat_st);
% 
%
% [1] JM O'Toole, EM Dempsey, D Van Laere, “Nonstationary coupling between heart rate and
% perfusion index in extremely preterm infants over the first day of life”, in
% preparation, 2019.


% John M. O' Toole, University College Cork
% Started: 21-05-2019
%
% last update: Time-stamp: <2019-05-22 13:23:35 (otoolej)>
%-------------------------------------------------------------------------------
function feat_st = feats_direction_coupling_STiPDC(st_pdc1, st_pdc2, DBplot)
if(nargin < 2)
    error('requires 2 ST-iPDC functions');
end
if(nargin < 3 || isempty(DBplot)), DBplot = 0; end

[P, Q] = size(st_pdc1);

st_pdc1(isnan(st_pdc1)) = 0;    
st_pdc2(isnan(st_pdc2)) = 0;


%---------------------------------------------------------------------
% 1. estimate the directional trajectory of coupling from the 
%    time-marginal of the ST-iPDC
%---------------------------------------------------------------------
%  time-maginal:
hr_pi_coords = NaN(P, 2);
irem = [];
for p = 1:P    
    hr_pi_coords(p, 1) = trapz(st_pdc1(p, :)) / Q;
    hr_pi_coords(p, 2) = trapz(st_pdc2(p, :)) / Q;
end

%  A. magnitude/angle of centroid:
av_co(1) = mean(hr_pi_coords(:, 1));
av_co(2) = mean(hr_pi_coords(:, 2));    

feat_st.mag = (sqrt(av_co(1) .^ 2 + av_co(2) .^ 2));
feat_st.angle = acos(av_co(1) / sqrt(av_co(1) .^ 2 + av_co(2) .^ 2));        

% B. 2D fractal dimension:
% for the HR-PI data ([1]), better to integrate here (see [2]):
feat_st.D = fd_curves(cumsum(hr_pi_coords(:, 1)), hr_pi_coords(:, 2), 6);    


%---------------------------------------------------------------------
% plot
%---------------------------------------------------------------------
if(DBplot)
    figure(21);
    clf; hold all;
    line_col = lines(1); 
    hline = plot(hr_pi_coords(:, 1), hr_pi_coords(:, 2), '-', 'linewidth', 1, ...
                 'color', line_col);

    colormap(copper(P));
    xtime = linspace(0, P, P);
    hscat = scatter(hr_pi_coords(:, 1), hr_pi_coords(:, 2), 40, xtime, 'filled');

    hcol = colorbar;
    xlabel(hcol, 'time (samples)');
end
