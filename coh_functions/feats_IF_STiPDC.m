%-------------------------------------------------------------------------------
% feats_IF_STiPDC: features of instantaneous frequency (IF) of the short-time information 
%               partial directed coherence (ST-iPDC) function. From [1].
%               
%
% Syntax: [feat_st, if_P50] = feats_IF_STiPDC(pdc)
%
% Inputs: 
%     pdc - ST-iPDC (N x N_freq) 
%     Fs  - sampling frequency
%
% Outputs: 
%     feat_st - structure containing following fields:
%                .IF_P50_mean        = mean IF
%                .IF_P50_SD          = standard deviation of the IF
%                .IF_P50_Hactivity   = Hjorth parameter: activity
%                .IF_P50_Hmobility   = Hjorth parameter: mobility
%                .IF_P50_Hcomplexity = Hjorth parameter: complexity
%     if_P50  - IF estimate as the time-varying median frequency
%
% Example:
%     % parameters for test signal:
%     N = 5000; 
%     L_win = 150; 
%     overlap = 50;
%     
%     x_st = gen_syth_test_signals(N, 1, 'nonstat4');
% 
%     % estimate the ST-iPDC: 
%     pdc_st = shorttime_iPDC(x_st(1).x, L_win, overlap, {'x1', 'x2'}, 1);
% 
%     % generate the features of the IF from x1 -> x2 coupling:
%     [feat_st, if_P50] = feats_IF_STiPDC(pdc_st.pdc{2});
%     disp(feat_st);
%     
%     % plot:
%     figure(10); clf; hold all;
%     plot(if_P50); 
%     xlabel('time (samples)'); 
%     ylabel('frequency (Hz)');
%     ylim([0 0.5]);
%
% 
% [1] JM O'Toole, EM Dempsey, D Van Laere, “Nonstationary coupling between heart rate and
% perfusion index in extremely preterm infants over the first day of life”, in
% preparation, 2020.


% John M. O' Toole, University College Cork
% Started: 27-06-2018
%
% last update: Time-stamp: <2020-09-10 14:12:58 (otoolej)>
%-------------------------------------------------------------------------------
function [feat_st, if_P50] = feats_IF_STiPDC(pdc, Fs)
if(nargin < 2 || isempty(Fs)), Fs = 1; end


% set missing values to zero:
pdc(isnan(pdc)) = 0;
[N, N_freq] = size(pdc);


%---------------------------------------------------------------------
% 1. estimate the IF from the time-varying median frequency
%---------------------------------------------------------------------
freq = Fs.*(0:(N_freq-1))./(2*N_freq);

if_P50 = zeros(1, size(pdc,1));
% iterate over all time-slices:
for n = 1:N
    if(~all(pdc(n,:) == 0))
        % estimate the median frequency:
        a_st = gen_PSD_PDF_attributes(pdc(n, :), 'P50', freq);
        if_P50(n) = a_st.P50;                        
    else
        if_P50(n) = NaN;
    end
end

%---------------------------------------------------------------------
% 2. generate features from the IF
%---------------------------------------------------------------------
% mean and SD of the IF:
feat_st.IF_P50_mean = nanmean(if_P50);
feat_st.IF_P50_SD = nanstd(if_P50);

% Hjorth parameters:
if_x = if_P50;
if_x(isnan(if_x)) = [];

feat_st.IF_P50_Hactivity = hjorth_feats(if_x, 'activity');
feat_st.IF_P50_Hmobility = hjorth_feats(if_x, 'mobility');
feat_st.IF_P50_Hcomplexity = hjorth_feats(if_x, 'complexity');


