function [cf_,gof]=myfilt(sBlack,vBlack)
%MYFILT    Create plot of datasets and fits
%   MYFILT(SBLACK,VBLACK)
%   Creates a plot, similar to the plot in the main curve fitting
%   window, using the data that you provide as input.  You can
%   apply this function to the same data you used with cftool
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of datasets:  1
%   Number of fits:  1

 
% Data from dataset "vBlack vs. sBlack":
%    X = sBlack:
%    Y = vBlack:
%    Unweighted
%
% This function was automatically generated on 13-Jun-2016 00:09:30

% Set up figure to receive datasets and fits
% f_ = clf;
% figure(f_);
% legh_ = []; legt_ = {};   % handles and text for legend
% xlim_ = [Inf -Inf];       % limits of x axis
% ax_ = subplot(1,1,1);
% set(ax_,'Box','on');
% axes(ax_); hold on;

 
% --- Plot data originally in dataset "vBlack vs. sBlack"
% sBlack = sBlack(:);
% vBlack = vBlack(:);
% h_ = line(sBlack,vBlack,'Parent',ax_,'Color',[0.333333 0 0.666667],...
%      'LineStyle','none', 'LineWidth',1,...
%      'Marker','.', 'MarkerSize',12);
% xlim_(1) = min(xlim_(1),min(sBlack));
% xlim_(2) = max(xlim_(2),max(sBlack));
% legh_(end+1) = h_;
% legt_{end+1} = 'vBlack vs. sBlack';

% Nudge axis limits beyond data limits
% if all(isfinite(xlim_))
%    xlim_ = xlim_ + [-1 1] * 0.01 * diff(xlim_);
%    set(ax_,'XLim',xlim_)
% end


% --- Create fit "fit 1"
fo_ = fitoptions('method','SmoothingSpline','SmoothingParam',0.999);
ft_ = fittype('smoothingspline' );

% Fit this model using new data
[cf_,gof] = fit(sBlack,vBlack,ft_ ,fo_);
% Plot this fit
% h_ = plot(cf_,'fit',0.95);
% legend off;  % turn off legend from plot method call
% set(h_(1),'Color',[1 0 0],...
%      'LineStyle','-', 'LineWidth',2,...
%      'Marker','none', 'MarkerSize',6);
% legh_(end+1) = h_(1);
% legt_{end+1} = 'fit 1';

% hold off;
% legend(ax_,legh_, legt_);
