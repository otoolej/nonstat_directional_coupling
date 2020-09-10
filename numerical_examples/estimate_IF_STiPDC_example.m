%-------------------------------------------------------------------------------
% estimate_IF_STiPDC_example: example of directional coupling with a non-linear
%                             instantaneous frequency (IF) law. Estimate based
%                             on 1,000 iterations of a time-varying AR model.
%                             Figure 4A from [1].
%
% Syntax: IF_coupling_example1();
%
% Inputs: 
%     none
%
% Outputs: 
%     none
%
% Example:
%     estimate_IF_STiPDC_example;
%
% 
% [1] JM O'Toole, EM Dempsey, D Van Laere, “Nonstationary coupling between heart rate and
% perfusion index in extremely preterm infants over the first day of life”, in
% preparation, 2020.


% John M. O' Toole, University College Cork
% Started: 28-06-2018
%
% last update: Time-stamp: <2020-09-10 14:13:09 (otoolej)>
%-------------------------------------------------------------------------------
function [] = estimate_IF_STiPDC_example()


%---------------------------------------------------------------------
% 1. set parameters
%---------------------------------------------------------------------
N = 5000;       % length of signal
N_iter = 1000;     % number of iterations
L_win = 150;    % length of short-time window 
overlap = 50;   % overlap for short-time approach (percentage)


%---------------------------------------------------------------------
% 2. generate synthetic signal with FM nonstationary coupling 
%    (1 influences 2 only)
%---------------------------------------------------------------------
x_st = gen_syth_test_signals(N, N_iter, 'nonstat4');


%---------------------------------------------------------------------
% 3. generate the ST-iPDC for each iteration
%---------------------------------------------------------------------
fprintf('Do you want generate all 1,000 ST-iPDC iterations?');
fprintf(' May take some time to compute, e.g. hours.\n');
m = input('Use pre-computed IF estimates from .mat instead file to avoid computation? y/n [y]: ', ...
          's');

if(any(strcmp({'no', 'n', }, lower(m))))
    
    % generate ST-iPDC and estimate the IF for all iterations:
    % (use parrallel processing for this to speed things up)
    parfor n = 1:N_iter
        if_tmp{n} = do_PDCs_IFs(x_st(n), L_win, overlap);
    end
    all_IFs = NaN(N_iter, length(if_tmp{1}));
    for n = 1:N_iter
        all_IFs(n, :) = if_tmp{n};
    end    
    
else
    % otherwise just load the estimated IF from a .mat file:
    cur_dir = fileparts(mfilename('fullpath'));
    load([cur_dir filesep 'ifs_plotting_v1.mat']);
end


%  the exact IF law (from function: gen_ar_lfm.m)
Nfreq = size(all_IFs, 2);
fn = 0.15 + 0.2 .* sin(2 * pi * (0.5 / Nfreq) .* (1:Nfreq));    


%---------------------------------------------------------------------
% 4. plot:
%---------------------------------------------------------------------
params.all_IFs = all_IFs;
params.fn = fn;
plot_IFestimates_fromMat(N, params);






function if_est = do_PDCs_IFs(x_st, L_win, overlap)
%---------------------------------------------------------------------
% generate ST-iPDC and estimate IF
%---------------------------------------------------------------------
pdc_st = shorttime_iPDC(x_st.x, L_win, overlap);
[~, if_est] = feats_IF_STiPDC(pdc_st.pdc{2});    




function plot_IFestimates_fromMat(N, params)
%---------------------------------------------------------------------
% plot the IF estimates 
%---------------------------------------------------------------------
figure(32); 
clf; hold all;
pp = get(gcf, 'position');
set(gcf, 'position', [pp(1:2) 420  260]);


all_IFs = params.all_IFs;
fn = params.fn;


[N_iter, Nfreq] = size(all_IFs);
ntime = linspace(0, N - 1, Nfreq);


clines = lines(8);
% plot each IF estimate for each iteration:
for n = 1:N_iter
    hl(n) = plot(ntime, all_IFs(n, :), 'color', [1 1 1] .* 0.7, ...
                 'linewidth', 0.2);
end
% plot the actual IF:
hfn = plot(ntime, fn, 'linewidth', 2, 'color', clines(2, :), 'linestyle', '-.');
% and then the average over the estimates:
hest = plot(ntime, nanmean(all_IFs), 'linewidth', 2, 'color', clines(1, :));


xlabel('time (seconds)');
ylabel('frequency (Hz)');
set(gca, 'ytick', [0.1:0.1:0.5]);
ylim([0 0.5]);

hleg = legend([hl(end) hest hfn], {'IF estimate (each iteration)', ...
                    'IF estimate (mean)', 'true IF'});
hleg.Position = [0.2741 0.2528 0.4778 0.2174];
hleg.Box = 'off';


%---------------------------------------------------------------------
% for docker testing
%---------------------------------------------------------------------
PRINT_PNG = 1;
if(PRINT_PNG)
    print('./pics/docker_tests/estimate_IF_STiPDC_fig.png', '-dpng');
end

