%-------------------------------------------------------------------------------
% gen_syth_test_signals: generate non-stationary bivariate AR signals. 
%                        See [1] for details.
%
% Syntax: x_st = gen_syth_test_signals(N, N_iter, artype)
%
% Inputs: 
%     N      - length of AR signals
%     N_iter - number of signals (iterations of the AR signals)
%     fmtype - linear or non-linear frequency-modulated law; either 'lfm' or 'nlfm'
%              either: 'nonstat1' (default), 'nonstat2', 'nonstat3', or 'nonstat4'
%
% Outputs: 
%     x_st - structure containing the signals
%     b    - time-varying coefficient
%     c    - time-varying coefficient
%
% Example:
%     N = 5000; N_iter = 1;
%     x_st = gen_syth_test_signals(N, N_iter, 'nonstat1');    
%     
%     figure(1); clf; hold all;
%     plot(x_st(1).x(1, :));
%     plot(x_st(1).x(2, :));
%
% 
% [1] JM O'Toole, EM Dempsey, D Van Laere, “Nonstationary coupling between heart rate and
% perfusion index in extremely preterm infants over the first day of life”, in
% preparation, 2020.




% John M. O' Toole, University College Cork
% Started: 25-06-2018
%
% last update: Time-stamp: <2020-09-10 14:13:14 (otoolej)>
%-------------------------------------------------------------------------------
function [x_st, b, c] = gen_syth_test_signals(N, N_iter, artype)
if(nargin<1 || isempty(N)), N = 5000; end
if(nargin<2 || isempty(N_iter)), N_iter = 1; end
if(nargin<3 || isempty(artype)), artype = 'nonstat1'; end

b = zeros(1, N);
c = zeros(1, N);

% coefficients for bivariate AR models:
A = [0.6 -0.91; 1.58 -0.96];

switch lower(artype)
    
  case 'nonstat1'
    %---------------------------------------------------------------------
    % 2.  nonstationary amplitude (1 influences 2)
    %---------------------------------------------------------------------
    c = 1 .* exp(-(1:N) ./ (N / 1.5)) .* sin(2 * pi * (5/N) .* (1:N) );
    
    x_st = ar_2order_tv_amplitude(A, b, c, N, N_iter);
    

  case 'nonstat2'
    %---------------------------------------------------------------------
    % 2.  nonstationary amplitude (TV back-and-forth influence, with step function)
    %---------------------------------------------------------------------
    Nh = ceil(N / 2);
    b(1:Nh) = 0.2;
    c(Nh:end) = 0.8;
    
    x_st = ar_2order_tv_amplitude(A, b, c, N, N_iter);

 
  case 'nonstat3'
    %---------------------------------------------------------------------
    % 2.  nonstationary amplitude (TV back-and-forth influence, with sinusoid)
    %---------------------------------------------------------------------
    x_sin = 0.5 .* sin(2 * pi * (5/N) .* (1:N) );    
    b(x_sin > 0) = x_sin( x_sin > 0);
    x_sin2 = 0.5 .* sin(2 * pi * (5/N) .* (1:N) + pi / 2);        
    c(x_sin2 <= 0) = abs(x_sin2( x_sin2<= 0));
    
    x_st = ar_2order_tv_amplitude(A, b, c, N, N_iter);

    
  case 'nonstat4'
    %---------------------------------------------------------------------
    % 2.  nonstationary frequency (1 influence 2)
    %---------------------------------------------------------------------
    A = [0.6 -0.91; 1.58 -0.96];
    c = 1 .* exp(-(1:N) ./ (N/1.5));

    
    for p = 1:N_iter
        w = randn(2, N);
        x = zeros(2, N);
        
        x1 = gen_ar_lfm(N, 1, 'nlfm');
        x(1, :) = x1(1).x;
        
        for n = 3:N
            x(2, n) = A(2, 1) * x(2, n - 1) + A(2, 2) * x(2, n - 2) + c(n) * x(1, n - 1) + w(2, n - 2);
        end
        x_st(p).x = x;    
    end
    
    

  otherwise
    error('unkown option?');
end





function x_st = ar_2order_tv_amplitude(A, b, c, N, N_iter)
%---------------------------------------------------------------------
% generate 2nd-order AR model
%---------------------------------------------------------------------
for p = 1:N_iter
    w = randn(2, N);
    x = zeros(2, N);
    
    for n = 3:N
        x(1, n) = A(1, 1) * x(1, n - 1) + A(1, 2) * x(1, n - 2) + b(n) * x(2, n - 1) + w(1, n - 2);
        x(2, n) = A(2, 1) * x(2, n - 1) + A(2, 2) * x(2, n - 2) + c(n) * x(1, n - 1) + w(2, n - 2);
    end
    x_st(p).x = x;    
end

