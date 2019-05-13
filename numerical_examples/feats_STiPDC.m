%-------------------------------------------------------------------------------
% feats_STiPDC: features of the short-time information PDC
%
% Syntax: []=feats_STiPDC(pdc)
%
% Inputs: 
%     pdc_st - 
%
% Outputs: 
%     [] - 
%
% Example:
%     
%

% John M. O' Toole, University College Cork
% Started: 27-06-2018
%
% last update: Time-stamp: <2018-06-27 17:42:21 (otoolej)>
%-------------------------------------------------------------------------------
function [if_percentiles, feat_st]=feats_STiPDC(pdc)


pdc(isnan(pdc))=0;

Fs = 1;


N_freq=size(pdc,2);
freq=Fs.*(0:(N_freq-1))./(2*N_freq);

inans_n=[];
for n=1:size(pdc,1)
    if(all(pdc(n,:)==0))
        inans_n=[inans_n n];
    end
end


% median frequency:
if_percentiles=zeros(1, size(pdc,1));
for n=1:size(pdc,1)
    if(~all(pdc(n,:)==0))
        a_st=gen_PSD_PDF_attributes(pdc(n,:),{'P50'},freq);
        if_percentiles(n)=a_st.P50;                        
    else
        if_percentiles(n)=NaN;
    end
end
if_percentiles(inans_n)=NaN;

in=find(isnan(if_percentiles));


feat_st.IF_P50_mean=nanmean(if_percentiles(1,:));
feat_st.IF_P50_SD=nanstd(if_percentiles(1,:));

in=find(isnan(if_percentiles(1,:)));

if_x=if_percentiles;
if_x(isnan(if_x))=[];


feat_st.IF_P50_Hactivity=hjorth_params(if_x,'activity');
feat_st.IF_P50_Hmobility=hjorth_params(if_x,'mobility');
feat_st.IF_P50_Hcomplexity=hjorth_params(if_x,'complexity');


