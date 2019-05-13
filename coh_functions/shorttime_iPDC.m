%-------------------------------------------------------------------------------
% shorttime_iPDC: short-time information partial directed coherence (STiPDC)
%                 (BI-VARIATE ONLY)
%
% Syntax: pdc_st = shorttime_iPDC(x_st)
%
% Inputs: 
%     x         - signals to analyse (matrix of size N x 2)
%     L_win     - length (in samples) for the short-time window [default = 150]
%     L_overlap - overalp length (in samples) for the short-time window 
%                 [default = 50%]
%     names_str - if plotting this is cell with the names of channels 
%                 [default = {'1', '2'}]
%     DBplot    - plot the STiPDC functions
% 
%
% Outputs: 
%     pdc_st - output structure comprising of the following fields:
%              .pdc = 2 coherence functions (cell)
%              .pdc_names = string of the names of functions (cell)
%              .ar_fit_ok = MVAR fit significant or not (logical vector)
% 
% 

%
% Example:
%       N = 5000; 
%       L_win = 150; 
%       overlap = 50;
%       
%       x_st = gen_syth_test_signals(N, 1, 'nonstat3');
%       
%       pdc_st = shorttime_iPDC(x_st(1).x, L_win, overlap, {'x1', 'x2'}, 1); 
% 
% 


% John M. O' Toole, University College Cork
% Started: 25-06-2018
%
% last update: Time-stamp: <2019-05-13 15:22:58 (otoolej)>
%-------------------------------------------------------------------------------
function pdc_st = shorttime_iPDC(x, L_win, L_overlap, names_str, DBplot)
if(nargin < 2 || isempty(L_win)), L_win = 100; end
if(nargin < 3 || isempty(L_overlap)), L_overlap = 95; end
if(nargin < 4 || isempty(names_str)), names_str = {'1', '2'}; end
if(nargin < 5 || isempty(DBplot)), DBplot = 0; end



params = hrpi_parameters;


% output structure:
pdc_st.pdc = [];
pdc_st.pdc_names = [];
pdc_st.ar_fit_ok = [];


% segmenting the signal into short-duration epochs:
N = size(x, 2);
iepoch = buffer(1:N, L_win, floor(L_win * (L_overlap / 100)), 'nodelay'); 

N_epochs = size(iepoch, 2) - 1;
coh1 = NaN(N_epochs, params.N_freq);
coh2 = NaN(N_epochs, params.N_freq);
ar_fit_ok = false(1, N_epochs);


% do for all short-time epochs:
for k = 1:N_epochs

    % generate the iPDC:
    pdc_st_tmp = do_PDC(x(:, iepoch(:, k)), params.N_freq);

    % extract the iPDC functions from the structure:
    coh1(k+1, :) = pdc_st_tmp.ipdc{1};
    coh2(k+1, :) = pdc_st_tmp.ipdc{2};
    ar_fit_ok(k+1) = pdc_st_tmp.ar_fit_ok;

    % if MVAR does not fit then ignore this time-slice:
    if(~pdc_st_tmp.ar_fit_ok)
        coh1(k+1, :) = NaN;
        coh2(k+1, :) = NaN;            
    end
end

pdc_st.pdc = {coh1; coh2};
pdc_st.pdc_names = { [names_str{2} ' \rightarrow ' names_str{1}],  ...
                    [names_str{1} ' \rightarrow ' names_str{2}]};    
pdc_st.ar_fit_ok = ar_fit_ok;




%---------------------------------------------------------------------
% plot the two coherence functions:
%---------------------------------------------------------------------
if(DBplot)
    set_figure(21); 
    [N_time, N_freq] = size(coh1);
    nn = 1:N_time;
    
    % assuming sample frequency = 1 Hz:
    kk = (1:N_freq) ./ (2 * N_freq);
    
    hs(1) = subplot(1, 2, 1); 
    imagesc(nn, kk, coh1'); axis('xy');  set(gca, 'clim', [0 1]);
    xlabel('time (seconds)');
    ylabel('frequency (Hz)');
    axis('square');
    set(hs(1), 'ytick', [0:0.1:0.5]);
    
    title(pdc_st.pdc_names{1});
    hs(2) = subplot(1, 2, 2); 
    imagesc(nn, kk, coh2'); axis('xy');  set(gca, 'clim', [0 1]);
    title(pdc_st.pdc_names{2});       
    set(hs(2), 'ytick', [0:0.1:0.5]);
    axis('square');    
    

    hc = colorbar('location', 'eastoutside');
    hc.Label.String = '|ST-iPDC|^2 (dB)';

    p1 = get(hs(1), 'position');
    p2 = get(hs(2), 'position');    
    set(hs(2), 'position', [p2(1) p1(2:4)]);
end


