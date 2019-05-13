%-------------------------------------------------------------------------------
% plot_PDC: plot iPDC functions (bivariate only)
%
% Syntax: plot_PDC(pdc_st, Fs)
%
% Inputs: 
%     pdc_st - structure from 'asymp_pdc' function (see asymp_package_v3 toolbox,
%              http://www.lcs.poli.usp.br/~baccala/pdc/))
%     Fs     - sample frequency (in Hz) [default = 1]
%     f_max  - plot upto this maximum frequency [default = Fs/2]
%
%

% John M. O' Toole, University College Cork
% Started: 13-05-2019
%
% last update: Time-stamp: <2019-05-13 15:37:31 (otoolej)>
%-------------------------------------------------------------------------------
function plot_PDC(pdc_st, Fs, f_max)
if(nargin < 3 || isempty(Fs)), Fs = 1; end
if(nargin < 4 || isempty(f_max)), f_max = []; end


Nfreq = size(pdc_st.pdc, 3);


freq = linspace(0, Fs / 2, Nfreq);
k_freq = 1:Nfreq;
% if only want to plot up to a specific frequency:
if(~isempty(f_max))
    [~, istop] = find_closest(freq, f_max);
    k_freq = 1:istop;
    freq = freq(k_freq);
end



set_figure(1);    
ord = [1 2; 2 1];

hax = zeros(1, 2);
hp = zeros(1, 4);
for p = 1:2
    hax(p) = subplot(1, 2, p); 
    hold all;
    
    n = ord(p, 1); 
    m = ord(p, 2);     
    PDCxx_signif = abs(squeeze(pdc_st.pdc_th(n, m, k_freq)));             
    PDCxx = abs(squeeze(pdc_st.pdc(n, m, k_freq)));
    Cohxx = abs(squeeze(pdc_st.coh(n, m, k_freq)));            

    signif_thres = [];
    if(pdc_st.alpha ~= 0)
        signif_thres = squeeze(pdc_st.th(n, m, k_freq));
    end

    hp(3) = plot(freq, Cohxx, 'color', rgb('lightBlue'), 'linewidth', 2);    
    hp(1) = plot(freq, PDCxx, 'color', [1 1 1].*.8, 'linewidth', 2);
    hp(2) = plot(freq, PDCxx_signif, 'color', rgb('darkRed'), 'linewidth', 2.5);
    hp(4) = plot(freq, signif_thres, 'k--', 'linewidth', 2);

    
    if(p == 2)
        legend(hp([2 3 4]), {'iPDC', 'coherence', 'threshold'}, ...
               'location', 'SouthOutside') ;
    else
        xlabel('frequency (Hz)');
        ylabel('|iPDC|');
    end
    

    xlim([freq(1) freq(end)]);
    ylim([-0.05 1.05]);
    axis('square');

    title([num2str(m) ' \rightarrow ' num2str(n)]);
end

p1 = get(hax(1), 'position');
p2 = get(hax(2), 'position');    
set(hax(2), 'position', [p2(1) p1(2:4)]);
