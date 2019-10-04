%-------------------------------------------------------------------------------
% gen_STiPDC_all_signals: 4 numerical examples (time-varying MVAR models) to 
%                         generate the short-time information partial directed 
%                         coherence (ST-iPDC) function.  See [1].
%
% Syntax: [] = gen_STiPDC_all_signals()
%
% Inputs: 
%     none
%
% Outputs: 
%     none
%
% Example:
%     gen_STiPDC_all_signals;
% 
%
% [1] JM O'Toole, EM Dempsey, D Van Laere, “Nonstationary coupling between heart rate and
% perfusion index in extremely preterm infants over the first day of life”, in
% preparation, 2019.


% John M. O' Toole, University College Cork
% Started: 07-05-2019
%
% last update: Time-stamp: <2019-10-04 11:09:05 (otoolej)>
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







function [] = plot_synth_examples(coh1, coh2, coupling_params, x_st, fig_num)
%---------------------------------------------------------------------
% plot the coupling parameters, ST-iPDCs, and the PSD on 1 figure
%---------------------------------------------------------------------
FONT_NAME = 'helvetica';
FONT_SIZE = 10;



figure(fig_num); clf; hold all;
pp = get(gcf, 'position');
set(gcf, 'position', [pp(1:2) 553 500]);


%---------------------------------------------------------------------
% 1. coupling parameters
%---------------------------------------------------------------------
if(~isempty(coupling_params))
    ynames = {'c[n]', 'd[n]'};
    
    if(any(coupling_params(2, :) < 0))
        ylims = [-1 1];
    else
        ylims = [0 1];
    end

    % hardcode position of subplots:
    ax_pos = [0.1300    0.8209    0.3315    0.1470; ...
              0.5703    0.8209    0.3315    0.1521];
    
    for n = 1:2
        hs(n) = subplot(4, 2, n);
        N = size(coupling_params, 2);
        hl(n) = plot(1:N, coupling_params(n, :), 'linewidth', 1.3);
        xlim([0 N]); ylim(ylims);
        set(hs, 'FontName', FONT_NAME, 'FontSize', FONT_SIZE);        


        ylabel(ynames{n});
        if(n == 1)
            % xlabel('time (seconds)');
        end
        hs(n).XTick = [0 2000 4000];
        
        set(hs(n), 'position', ax_pos(n, :));
    end
    p = 2;
else 
    p = 0;
end


%---------------------------------------------------------------------
% 2. coherence functions
%---------------------------------------------------------------------
[N_time, N_freq] = size(coh1);
nn = linspace(0, N, N_time);
kk = (1:N_freq) ./ (2 * N_freq);


hs(1 + p) = subplot(4, 2, [3 5]);
imagesc(nn, kk, coh1'); axis('xy');  set(gca, 'clim', [0 1]);
title('y \rightarrow x');    	
ylabel('frequency (Hz)');
% xlabel('time (seconds)');

hs(2 + p) = subplot(4, 2, [4 6]);
imagesc(nn, kk, coh2'); axis('xy');  set(gca, 'clim', [0 1]);
title('x \rightarrow y');    	

hc=colorbar('location', 'eastoutside');
hc.Label.String='|ST-iPDC|^2';

p1=get(hs(1 + p), 'position');
p2=get(hs(2 + p), 'position');    
set(hs(2 + p), 'position', [p2(1) p1(2:4)]);


%---------------------------------------------------------------------
% 3. auto-PSDs
%---------------------------------------------------------------------
if(~isempty(x_st))
    x1 = x_st.x(1, :);
    x2 = x_st.x(2, :);    

    Fs = 1;
    
    S1 = pwelch(x1, 100, Fs);
    S2 = pwelch(x2, 100, Fs);

    f = linspace(0, Fs ./ 2, length(S1));

    hs(3 + p) = subplot(4, 2, 7);
    plot(f, S1 ./ max(S1), 'linewidth', 1.3);
    xlim([0 Fs / 2]);
    xlabel('frequency (Hz)');
    hs(3 + p).YAxis.Visible = 'off';    
    hylab = ylabel('|X(f)|');    
    ypos = hylab.Position;
    text(ypos(1), ypos(2), '|X(f)|', 'rotation', 90, 'horizontalalignment', 'center');
    


    hs(4 + p) = subplot(4, 2, 8);
    plot(f, S2 ./ max(S2), 'linewidth', 1.3);
    xlim([0 Fs / 2]);
% $$$     xlabel('frequency (Hz)');

    hs(4 + p).YAxis.Visible = 'off';
    hylab = ylabel('|Y(f)|');    
    ypos = hylab.Position;
    text(ypos(1), ypos(2), '|Y(f)|', 'rotation', 90, 'horizontalalignment', 'center');
    

    set(hs(3 + p), 'xtick', [0:0.1:0.5]);
    set(hs(4 + p), 'xtick', [0:0.1:0.5]);    
    set(hs(3 + p), 'ytick', []);
    set(hs(4 + p), 'ytick', []);    
end

set(hs, 'FontName', FONT_NAME, 'FontSize', FONT_SIZE);


%---------------------------------------------------------------------
% for docker testing
%---------------------------------------------------------------------
PRINT_PNG = 1;
if(PRINT_PNG)
    print(['./pics/docker_tests/coh_num_eg_fig' num2str(fig_num) '.png'], '-dpng');
end
