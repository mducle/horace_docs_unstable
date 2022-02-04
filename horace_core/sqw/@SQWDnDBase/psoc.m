function [figureHandle, axesHandle, plotHandle] = psoc(w)
% Overplot a surface plot of a 2D sqw dataset or array of datasets on the current figure
%
%   >> psoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = psoc(w) 


[ok,mess]=dimensions_match(w,2);
if ~ok, error(mess), end

% Check input arguments
nam=get_global_var('horace_plot','name_surface');
opt=struct('newplot',false,'default_name',nam,'over_curr',true);
[args,ok,mess]=genie_figure_parse_plot_args(opt);
if ~ok, error(mess), end

% Perform plot
[figureHandle_, axesHandle_, plotHandle_] = psoc(IX_dataset_2d(w), args{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
