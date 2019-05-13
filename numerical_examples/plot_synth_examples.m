%-------------------------------------------------------------------------------
% plot_PDCs: 
%
% Syntax: [] = plot_synth_examples(coh1, coh2, Fs, names_str)
%
% Inputs: 
%     coh1, coh2, Fs, names_str - 
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
% last update: Time-stamp: <2019-05-13 14:12:39 (otoolej)>
%-------------------------------------------------------------------------------
function [] = plot_synth_examples(coh1, coh2, coupling_params, x_st, fig_num)
if(nargin < 3 || isempty(coupling_params)), coupling_params = []; end
if(nargin < 4 || isempty(x_st)), x_st = []; end
if(nargin < 5 || isempty(fig_num)), fig_num = 3; end


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




