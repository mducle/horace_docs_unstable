function varargout=set_sample_sqw(varargin)
% Change the sample in a file or set of files containing Horace sqw data
%
%   >> set_sample_sqw (file, sample)
%
% The altered object is written to the same file.
%
% Input:
% -----
%   file        File name, or cell array of file names. In latter case, the
%              change is performed on each file
%
%   sample      Sample object (IX_sample object) or structure
%              Note: only a single sample object can be provided. That is,
%              there is a single sample for the entire sqw data set
%               If the sample is any empty object, then the sample is set
%              to the default empty structure.


% Original author: T.G.Perring
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)

if nargout > 0
    varargout = set_instr_or_sample_horace_(filename,'-sample',sample,varargin{:});
else
    set_instr_or_sample_horace_(filename,'-sample',sample,varargin{:});
end

