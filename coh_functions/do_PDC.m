%-------------------------------------------------------------------------------
% do_PDC: bi-variate information partial directed coherence (iPDC) using the
%         'asymp_package_v3' toolbox (see e.g. [1])
%
% Syntax: [pdc_st] = do_PDC(x_all, N_freq)
%
% Inputs: 
%     x_all   - signals (matrix of size 2 x N)
%     N_freq  - number of frequency-domain sample points for the coherence 
%               functions [default = 128]
%
% Outputs: 
%     pdc_st     - output structure comprising of the following fields:
%                    .pdc = 2 coherence functions (cell)
%                    .pdc_names = string of the names of functions (cell)
%                    .ar_fit_ok = MVAR fit significant or not (logical vector)
%     pdc_tmp_st - structure from asymp_pdc.m (see asymp_package_v3 for more
%                  details)
%
% Example:
%     DBplot = 1;
%     N_freq = 256;
%     N = 1000;
% 
%     x_st = gen_syth_test_signals(N, 1, 'nonstat4');
%     pdc_st = do_PDC(x_st(1).x, N_freq, DBplot);
% 
%
% REQUIRES:
%   asymp_package_v3 toolbox (http://www.lcs.poli.usp.br/~baccala/pdc/)
%   arfit toolbox (https://github.com/tapios/arfit)
%
% 
% 
% [1] Baccala, L. A., Takahashi, D. Y., & Sameshima, K. (2016). Directed Transfer
% Function: Unified Asymptotic Theory and Some of its Implications. IEEE Transactions on
% Biomedical Engineering, 63(12), 2450–2460. https://doi.org/10.1109/TBME.2016.2550199
% 
% [2] Baccala, L. A., de Brito, C. S. N., Takahashi, D. Y., & Sameshima,
% K. (2013). Unified asymptotic theory for all partial directed coherence
% forms. Philosophical Transactions of the Royal Society A: Mathematical, Physical and
% Engineering Sciences, 371(1997), 20120158. https://doi.org/10.1098/rsta.2012.0158


% John M. O' Toole, University College Cork
% Started: 31-08-2017
%
% last update: Time-stamp: <2021-02-16 16:13:22 (otoolej)>
%-------------------------------------------------------------------------------
function [pdc_st, pdc_tmp_st] = do_PDC(x_all, N_freq, DBplot)
if(nargin < 2 || isempty(N_freq)), N_freq = 128; end
if(nargin < 3 || isempty(DBplot)), DBplot = 0; end



DBverbose = 0;

% data should be columns:
[M, N] = size(x_all);

%---------------------------------------------------------------------
% requires 'asymp_package_v3' and 'arfit'
%---------------------------------------------------------------------
if(exist('asymp_pdc', 'file') ~= 2)
    fprintf('|*** __________\n' );
    fprintf('Need to install ''asymp_PDC'' toolbox. \n');
    fprintf('Download from http://www.lcs.poli.usp.br/~baccala/pdc/\n');
    fprintf('__________ ***|\n' );
    error('install software. see previous message.');
end
if(exist('arfit','file') ~= 2)
    fprintf('|*** __________\n' );
    fprintf('Need to install ''arfit'' toolbox. \n');
    fprintf('Download from https://github.com/tapios/arfit\n');
    fprintf('__________ ***|\n' );
    error('install software. see previous message.');
end


%---------------------------------------------------------------------
% set parameters for PDC (for asymp_package_v3 toolbox)
%---------------------------------------------------------------------
% for iPDC:
type_PDC = 'info';
% statistical threshold:
alpha = 0.01; 
% max. order for multivariate autoregressive model (MVAR):
max_order = 10; 



%---------------------------------------------------------------------
% 1. preprocess data
%---------------------------------------------------------------------
% remove NaNs:
inans = [];
for n = 1:M
    inans = [inans find(isnan(x_all(n,:)))];
end
x_all(:, unique(inans)) = [];
[M, N] = size(x_all);

% remove linear trend:
for n = 1:M
    x_all(n,:) = detrend(x_all(n,:));
end



%---------------------------------------------------------------------
% 2. fit AR (using QR decomposition to fit the coefficients and Akaike’s
%     Final Prediction Error to estimate optimal model order)
% 
% (should use more up-to-date version of arfit, at 
%  https://github.com/tapios/arfit, not at 
%  http://www.lcs.poli.usp.br/~baccala/pdc/)
%---------------------------------------------------------------------
[w, Au, C] = arfit(x_all.', 1, max_order, 'fpe');

p_opt = size(Au, 2) / M;

% test if residuals are un-correlated (using the Li--McLeod Portmanteau statistic)
max_lag = 20;  
ar_fit_ok = false;
[pvalue_portmanteau, res] = arres(w, Au, x_all.', max_lag);

if(pvalue_portmanteau > 0.05)
    ar_fit_ok = true;
end

if(DBverbose)
    if(ar_fit_ok)
        fprintf('*GOOD? fit ');
    else
        fprintf('*BAD? fit ');
    end
    fprintf(' (p=%.3f); MVAR order=%d\n',pvalue_portmanteau,p_opt);
end

% reshape coefficent matrix:
A = reshape(Au, M, M, p_opt);


%---------------------------------------------------------------------
% plotting MVAR fit
%---------------------------------------------------------------------
% a. plot the correlation function:
DBplotACF = 0;
if(DBplotACF)
    figure(9); clf; hold all;
    acf(res(:, 1, 1));
end

% b. plot MVAR estimates:
DBtest_ARfit_plot_sims = 0;
if(DBtest_ARfit_plot_sims)
    x_ar_sim = arsim(w, Au, C, N);

    figure(19); clf; hold all;
    for n = 1:M
        hx(n) = subplot(2, 1, n); hold all;
        plot_components([x_all(n, :); x_ar_sim(:, n)']);
    end
    linkaxes(hx, 'x');
end


%---------------------------------------------------------------------
% 3. calculate PDC
%---------------------------------------------------------------------
pdc_tmp_st = asymp_pdc(x_all', A, C, N_freq, type_PDC, alpha);

% extract the iPDC from the structure:
pdc_st.ipdc{1} = squeeze(pdc_tmp_st.pdc_th(1, 2, :));
pdc_st.ipdc{2} = squeeze(pdc_tmp_st.pdc_th(2, 1, :));

pdc_st.ar_fit_ok = ar_fit_ok;

if(DBplot)
    plot_PDC(pdc_tmp_st)
end


