%-------------------------------------------------------------------------------
% hjorth_feats: calculate parameters according to [1], presented in [2]
%
% Syntax: h = hjorth_feats(x, htype)
%
% Inputs: 
%     x     - input signal 
%     htype - parameter to estimate; either 'activity', 'mobility' (default), 
%             or 'complexity' 
%
% Outputs: 
%     h - Hjorth parameter
%
% Example:
%      % generate test signal:
%      N = 501;
%      f0 = 0.3;
%      x = cos(2 * pi * f0 .* (0:(N - 1)));
%      
%      % estimate the 3 Hjorth parameters:
%      ha = hjorth_feats(x, 'activity'); 
%      hm = hjorth_feats(x, 'mobility'); 
%      hc = hjorth_feats(x, 'complexity'); 
%      
%      fprintf('activity = %.4f\n', ha);
%      fprintf('mobility = %.4f (Hz)\n', hm./(2*pi));
%      fprintf('complexity = %.4f\n', hc);
% 
%     
%
% [1] B. Hjorth, “EEG analysis based on time domain properties,”
% Electroencephalogr. Clin. Neurophysiol., vol. 29, no. 3, pp. 306–310, 1970.
% 
% [2] JM O'Toole, EM Dempsey, D Van Laere, “Nonstationary coupling between heart rate and
% perfusion index in extremely preterm infants over the first day of life”, in
% preparation, 2020.



% John M. O' Toole, University College Cork
% Started: 20-10-2017
%
% last update: Time-stamp: <2020-09-10 14:12:54 (otoolej)>
%-------------------------------------------------------------------------------
function h = hjorth_feats(x, htype)
if(nargin<2 || isempty(htype)), htype = 'mobility'; end



% definition of variance assumes zero-mean (which may not be the case):
nanvar = @(x) nanmean(x.^2);


m0 = nanvar(x);

switch htype
  case {'activity', 0}
    %---------------------------------------------------------------------
    % estimate of 1st moment of PSD
    %---------------------------------------------------------------------
    h = m0;
    
  case {'mobility', 1}
    %---------------------------------------------------------------------
    % estimate of 2nd moment of PSD
    %---------------------------------------------------------------------
    x_hat = estimate_derivate(x);
    m2 = nanvar(x_hat);
    
    h = sqrt(m2 / m0);
    
    
  case {'complexity', 2}
    %---------------------------------------------------------------------
    % estimate of 3rd moment of PSD
    %---------------------------------------------------------------------
    x_hat = estimate_derivate(x);
    m2 = nanvar(x_hat);

    mobility = sqrt(m2 / m0);

    x_hat2 = estimate_derivate(x_hat);
    m4 = nanvar(x_hat2);

    mobility2 = sqrt(m4 / m2);
    
    h = mobility2 / mobility;
    
  otherwise
    error('htype should be either activity, mobility, or complexity');
end







function y = estimate_derivate(x)
%---------------------------------------------------------------------
% Estimate the derivate using either forward finite difference
% approximation or an FIR-based approximation.
%---------------------------------------------------------------------
USE_DIFF = 0;


if(USE_DIFF)
    % 1. first-order estimate:
    y = diff(x);

else
    % 2. FIR filter:    
    L_h = floor(length(x) / 4);

    
    % some contraints on the length of the filter:
    if(L_h > 50)
        L_h = 50;
    end
    % want a Type-IV filter (as length = L_h + 1)
    if(rem(L_h, 2))
        L_h = L_h - 1;
    end

    % use least-squares approach to approximate ideal filter-response:
    b = firls(L_h, [0 0.9], [0 0.9 * pi], 'differentiator');
    y = filter(b, 1, x);    

    % fvtool(b, 1, 'MagnitudeDisplay', 'zero-phase');
end


