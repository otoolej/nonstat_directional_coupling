%-------------------------------------------------------------------------------
% gen_PSD_PDF_attributes: PDF attributes (e.g. mean, median, 95th centile) of PSD
%
% Syntax: feats_st=gen_PSD_PDF_attributes(P_xx, freq_range)
%
% Inputs: 
%     P_xx       - power spectral density (PSD)
%     attributes - list (in form of cell) for attributes of the PSD, specifically:
%                       + percentiles are entered as strings, e.g. 'P5', 'P50', 'P90'
%                       + mean and standard deviation is entered as 'mean' and 'SD'
%     freq_range - frequency range to consider (assumes PDF is normalised in this distribution)
%     Fs         - sample frequency (not used if 'freq_range' given)
%
% Outputs: 
%     feats_st - structure containing the PDF moments/attributes
%
% Example:
%       % generate a test signal:
%       N = 1000;
%       Fs = 1;
%       t = (0:(N-1))./Fs;
%       f0 = 0.23;
%       x = sin(2 * pi .* t * f0) + cumsum(0.01 .* randn(1, N));
%       
%       % generate the periodogram PSD:
%       Pxx = abs(fft(x));
%       Pxx = Pxx(1:ceil(N/2));
%       
%       % estimate the mean, median, and standard deviation of the PSD:
%       feat_st = gen_PSD_PDF_attributes(Pxx, {'mean', 'P50', 'SD'}, [], Fs);
%       disp(feat_st);
%       
%       % plot:
%       freq_range = linspace(0, Fs / 2, length(Pxx));
%       figure(27); clf; hold all;
%       plot(freq_range, 10 * log10(Pxx));
%       plot([feat_st.mean] .* [1 1], ylim, 'linewidth', 2);
%       plot([feat_st.P50] .* [1 1], ylim, 'linewidth', 2);
%       

% --
% using moments of CDF from Stack-FX answer:
% Find expected value using cdf, URL (version: 2017-10-10): 
% https://stats.stackexchange.com/q/307220
% from: StijnDeVuyst (https://stats.stackexchange.com/users/71524/stijndevuyst),

% John M. O' Toole, University College Cork
% Started: 01-12-2017
%
% last update: Time-stamp: <2019-05-21 15:22:53 (otoolej)>
%-------------------------------------------------------------------------------
function feats_st = gen_PSD_PDF_attributes(P_xx, attributes, freq_range, Fs)
if(nargin < 2 || isempty(attributes)),  attributes = {'mean', 'P95'}; end
if(nargin < 3 || isempty(freq_range)), freq_range = []; end
if(nargin < 4 || isempty(Fs)),  Fs = 1; end



if(iscolumn(P_xx))
    P_xx = P_xx.';
end


%---------------------------------------------------------------------
% declare structure with attributes as fieldnames
%---------------------------------------------------------------------
if(~iscell(attributes))
    attributes = {attributes};
end
for n = 1:length(attributes)
    feats_st.(char(attributes{n})) = NaN;
end


% if specified a particular frequency range to consider then limit P_xx:
N = length(P_xx);
if(isempty(freq_range))
    freq_range = linspace(0, Fs / 2, N);
else
    freq_range = sort(freq_range);
    k_start = round(freq_range(1) .* (2 * N) ./ Fs);
    k = (1:length(freq_range))+k_start;
    k(k > N) = N; 
    k(k < 1) = 1;
    k = unique(k);
    
    P_xx = P_xx(k);
end

if(~isequal(size(P_xx), size(freq_range)))
    error('different dimensions for P_xx and freq_range;');
end


P_xx(isnan(P_xx)) = 0;
if(all(P_xx == 0))
    return;
end


%---------------------------------------------------------------------
% estimate attributes from cumulative density function (C_xx):
%---------------------------------------------------------------------
C_xx = cumtrapz(freq_range, P_xx);
C_xx = C_xx ./ max(C_xx);

[C_xx_u, ifn] = unique(C_xx);
freq_range_u = freq_range(ifn);
C_xx_u = C_xx_u ./ max(C_xx_u);


% may be more than 1 attribute so iterate otherwise:
for n = 1:length(attributes)
    
    if(attributes{n}(1) == 'P')
        % if percentile then may have to interpolate the extact point on the CDF
        percentile = str2num(attributes{n}(2:end));
        attri = interp1(C_xx_u, freq_range_u, C_xx(end) * (percentile/100), 'pchip');
        
    elseif(strcmp(attributes{n}, 'mean'))
        %  for mean use (1 - CDF) in the estimate:
        attri = trapz(freq_range_u, (1 - C_xx_u));
        
    elseif(strcmp(attributes{n}, 'SD'))
        %  for standard deviation use (1 - CDF) in the estimate:
        attri = trapz(freq_range_u, freq_range_u .* (1 - C_xx_u));
    end
    
    feats_st.(char(attributes{n})) = attri;
end

