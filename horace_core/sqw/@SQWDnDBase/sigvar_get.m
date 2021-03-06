function [s,var,mask_null] = sigvar_get (w)
% Get signal and variance from object, and a logical array of which values to ignore
%
%   >> [s,var,mask_null] = sigvar_get (w)

% Original author: T.G.Perring
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)

s = w.data_.s;
var = w.data_.e;
mask_null = logical(w.data_.npix);

