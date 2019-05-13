%-------------------------------------------------------------------------------
% gen_STiPDC_all_signals: generate the short-time information partial directed
% coherence (ST-iPDC)
%
% Syntax: [] = gen_STiPDC_all_signals()
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
% Started: 07-05-2019
%
% last update: Time-stamp: <2019-05-13 15:41:00 (otoolej)>
%-------------------------------------------------------------------------------
function [] = gen_STiPDC_all_signals()

% parameters for the AR models
N = 5000; 
N_iter = 1;
L_win = 150; 
overlap = 50;


ar_type = {'nonstat1', 'nonstat2', 'nonstat3', 'nonstat4'};
L = length(ar_type);

for n = 1:L
    % a. generate the test signals:
    [x_st, b, c] = gen_syth_test_signals(N, N_iter, ar_type{n});
    
    % b. generate the ST-iPDC
    pdc_st = shorttime_iPDC(x_st(1).x, L_win, overlap, [], 0); 
    
    % c. plot:
    plot_synth_examples(pdc_st.pdc{1}, pdc_st.pdc{2}, [b(:) c(:)]', x_st, n + 10);

end

