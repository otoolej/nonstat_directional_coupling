%-------------------------------------------------------------------------------
% gen_ar_lfm: generate a (non)linear-FM type signal using a time-varying AR model
%
% Syntax: x_st = gen_ar_lfm(N, N_iter, fmtype)
%
% Inputs: 
%     N      - length of AR signals
%     N_iter - number of signals (iterations of the AR signals)
%     fmtype - linear or non-linear frequency-modulated law; either 'lfm' or 'nlfm'
%
% Outputs: 
%     x_st - structure containing the signals
%
% Example:
%     DBplot = 1;
%     x_st = gen_ar_lfm(1024, 10, 'nlfm', DBplot);
%    
%
% 
% [1] JM O'Toole, EM Dempsey, D Van Laere, “Nonstationary coupling between heart rate and
% perfusion index in extremely preterm infants over the first day of life”, in
% preparation, 2020.


% John M. O' Toole, University College Cork
% Started: 26-06-2018
%
% last update: Time-stamp: <2020-09-10 14:13:27 (otoolej)>
%-------------------------------------------------------------------------------
function x_st = gen_ar_lfm(N, N_iter, fmtype, DBplot)
if(nargin < 1 || isempty(N)), N = 1024; end
if(nargin < 2 || isempty(N_iter)), N_iter = 5; end
if(nargin < 3 || isempty(fmtype)), fmtype = 'nlfm'; end
if(nargin < 4 || isempty(DBplot)), DBplot = 0; end



As = [1 -0.91];
p = length(As);

%---------------------------------------------------------------------
% 1. define IF law
%---------------------------------------------------------------------
switch lower(fmtype)
  case 'lfm'
    fn = 0.2 + linspace(0, 0.1, N);
      
  case 'nlfm'
    n = 1:N;
    fn = 0.15 + 0.2 .* sin(2 * pi * (0.5 / N) .* n);    
    
  otherwise
    error('which type (either ''lfm'' or ''nlfm'')?');
end

% time-varying coefficient:
c = 2 .* cos(2 * pi * fn);


%---------------------------------------------------------------------
% 2. generate the MVAR models (multiple iterations)
%---------------------------------------------------------------------
for l = 1:N_iter
    A_tv = zeros(p, N);
    for m = 1:p
        A_tv(m, :) = As(m);
    end
    A_tv(1, :) = c;

    w = randn(1, N);
    x = w;

    for n = (p + 1):N
        for m = 1:p
            x(n) = x(n) + A_tv(m, n) .* x(n - m);
        end
    end
    
    x_st(l).x = x;
end



%---------------------------------------------------------------------
% plot (if needed)
%---------------------------------------------------------------------
if(DBplot)
    
    %  generate theoretical spectrum:
    Hr = zeros(N, N);
    for n = 1:N
        Hr(n, :) = 1 ./ abs(1 - fft([0 A_tv(:, n)'], N)) .^ 2;
    end
    Hr_mean = mean(Hr, 1);    

    
    % plot and compare with AR generated signal:
    figure(9); clf; hold all;
    Nh = ceil(N / 2);
    k = linspace(0, 0.5, Nh);
    plot(k, Hr_mean(1:Nh) ./ max(Hr_mean(1:Nh)));

    X = abs(fft(x)) .^ 2;
    plot(k, X(1:Nh) ./ max(X));



    % plot TFD:
    if(exist('full_tfd.m', 'file') == 2)
        tf = full_tfd(x, 'sep', {{255, 'hann'}, {61, 'hann'}}, 256, 256);
        figure(101); clf; hold all;
        vtfd(tf, x);
        figure(102); clf; hold all;
        vtfd(Hr(:, 1:Nh), x);
    else
        fprintf('|*** __________\n' );
        fprintf('Consider installing ''memeff_TFDs'' to plot the time--frequency\n');
        fprintf('distribution of the time-varying frequency.\n');
        fprintf('Download and install from https://github.com/otoolej/memeff_TFDs\n');
        fprintf('__________ ***|\n' );
    end
end



