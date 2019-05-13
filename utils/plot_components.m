%-------------------------------------------------------------------------------
% plot_components: plot signals vertically stacked 
% 
%
% Syntax: [hax, hlines] = plot_components(x_comp, y_gap)
%
% Inputs: 
%     x_comp  - matrix of the signal components (L x N)
%     y_gap   - vertical gap between components
%
% Outputs: 
%     hax    - axis handle
%     hlines - handle to the lines in the plot
%
% Example:
%     plot_components(randn(4, 1000));
%

% John M. O' Toole, University College Cork
% Started: 03-08-2016
%
% last update: Time-stamp: <2019-05-13 15:50:12 (otoolej)>
%-------------------------------------------------------------------------------
function [hax, hlines]=plot_components(x_comp,y_gap)
if(nargin<2 || isempty(y_gap)), y_gap=0; end

hold all;

[L,N]=size(x_comp);

y_gap=mean(std(x_comp'));

hlines=zeros(1,L);
all_gap=0;
for l=1:L
    if(l>1)
        yheight=max(x_comp(l,:))-mean(x_comp(l,:));
        all_gap=y_gap+abs(yl)+yheight;
    else
        x_comp(1,:)=x_comp(1,:)-nanmean(x_comp(1,:));
    end
    
    hlines(l)=plot(x_comp(l,:)-all_gap);
    yl=min(get(hlines(l),'ydata'));
end

xlim([1 N]);
ylim([min(get(hlines(end),'ydata')) max(get(hlines(1),'ydata'))]);
