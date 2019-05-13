%-------------------------------------------------------------------------------
% IF_coupling_example1: show nonstationary coupling (with varying frequency)
%
% Syntax: []=IF_coupling_example1()
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
% Started: 28-06-2018
%
% last update: Time-stamp: <2018-06-29 17:58:53 (otoolej)>
%-------------------------------------------------------------------------------
function []=IF_coupling_example1(PRINT_)
if(nargin<1 || isempty(PRINT_)), PRINT_=0; end


pi_parameters;


N = 5000; N_iter = 2;
L_win = 150; overlap = 50;

%---------------------------------------------------------------------
% FM nonstationary coupling (1 influences 2 only)
%---------------------------------------------------------------------
[y_st, b, c] = gen_syth_test_signals(N, N_iter, 'nonstat5');


parfor n = 1:N_iter
    ifs{n} = do_PDCs_IFs(y_st(n), L_win, overlap);
end
all_IFs = zeros(N_iter, length(ifs{1}));
for n = 1:N_iter
    all_IFs(n, :) = ifs{n};
end    


Nfreq = size(all_IFs, 2);
%  IF law (from gen_ar_lfm.m):
fn = 0.15 + 0.2 .* sin(2 * pi * (0.5 / Nfreq) .* (1:Nfreq));    

%  save in case want to replot later
save([PIC_DIR 'ifs_plotting_v1.mat'], 'all_IFs', 'fn');

%  then plot:
params.all_IFs = all_IFs;
params.fn = fn;
plot_IFestimates_fromMat(N, PRINT_, params);






function ifs = do_PDCs_IFs(y_st, L_win, overlap)
%---------------------------------------------------------------------
% generate ST-iPDC and estimate IF
%---------------------------------------------------------------------
pdc_st = shorttime_iPDC(y_st, L_win, overlap);
ifs = feats_STiPDC(pdc_st.pdc{2});    


