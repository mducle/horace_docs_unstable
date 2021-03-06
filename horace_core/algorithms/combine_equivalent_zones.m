function transf_list=combine_equivalent_zones(data_source,proj,pos,qstep,erange,outfile,varargin)
%
%>>transf_list= combine_equivalent_zones(data_source,proj,pos,qstep,erange,outfile)
%>>transf_list= combine_equivalent_zones(data_source,proj,pos,qstep,erange,outfile,keyword,params)
%>>transf_list= combine_equivalent_zones(data_source,proj,pos,qstep,erange,outfile,zonelist,params)
%
% Necessary input Arguments:
% data_source  -- input sqw file
% proj             --  the projection plane [proj.u, proj.v ] in the horace
%                       meaning (see cut_sqw or gen_sqw) describing the
%                       target sqw object
% pos            --  three integer numbers, (e.g [0,0,0])  specifying the initial point
%                       in reciprocal space (h,k,l)  which is a reference
%                       point for the transformation
% qstep         --   3-vector or float describing delta Q in all 3 q-directions of the reciprocal
%                       space. If one number is specified, the steps are
%                       eqial in all 3 directions
% egange      --   3-vector describing energy range and energy step of the
%                       cut [e_min,e_step,e_max], or cellarray of such
%                       vectors, used to decrease memory usage during
%                       combining (each zone split into number of energy
%                       sub-zones according to this list)
%
%
% params -- optional key-value pairs to be present after keyword or
%           zonelist parameters.
%Their possible values are:
%
%
% Output argument:
% transf_list -- cellarray of cut_tranf objects, describing the transformations applied to each
%                combined zone
%
% Additional input arguments describe the symmetrisation operation.
%
% Create a new sqw file which corresponds to just one Brillouin zone, but
% with data from equivalent positions. Default choice is all equivalent
% wave-vectors, but can also manually specify which zones are to be combined.
% This is done either by using the keywords:
%   '-cyclic' : only cyclic permutations (with no sign changes) of the chosen zone are included
%   '-cycwithneg' : cyclic permutations AND the negatives (e.g. (2,1,0),
%   (-2,1,0) etc.
%   '-ab' : equivalent positions in the ab plane
%   '-ac' : equivalent positions in the ac plane
%   '-bc' : equivalent positions in the bc plane
%
% Alternatively one can explicitly provide a list of wave-vectors to be
% combined by providing a cell array
%
% RAE 30/3/2010

%==========================================================================
%First do some checks on the inputs:

if ~ischar(data_source)
    error('Horace error: data source must be a string');
end

if ~(isstruct(proj) || isa(proj,'aProjection'))
    error('Horace error: proj must be a structure array or an instance of a projection class');
else
    if isstruct(proj) && (~isfield(proj,'u') || ~isfield(proj,'v'))
        error('Horace error: proj structure array must have fields u and v');
    end
end

if ~isnumeric(pos) || numel(pos)~=3
    error('Horace error: pos argument must be a vector with 3 elements specifying h,k,l of reference Brillouin zone');
end

if iscell(qstep)
    if ~isa(qstep{1},'cut_transf') % transformations defined, pass it through
        if ~isnumeric(qstep{1})
            error('COMBINE_EQUIV_LIST:invalid_argument','Cells in cellarray of step arguments must be numeric');
        end
    end
else
    if ~isnumeric(qstep)
        error('Horace error: step argument must be numeric');
    elseif numel(qstep)~=1 && numel(qstep)~=3
        error('Horace error: step argument must either be a single number, or a vector containing 3 elements');
    end
end

if ~isnumeric(erange)
    if ~iscell(erange)
        error('Horace error: erange argument must be numeric');
    else
        all_ok = cellfun(@(x)(numel(x)==3),erange);
        if sum(all_ok) ~= numel(erange)
            error('Horace error: erange as cellarray has to contain a list vector having 3 elements');
        end
    end
elseif numel(erange)~=3
    error('Horace error: erange argument must be a vector containing 3 elements');
end

if ~ischar(outfile)
    error('Horace error: outfile argument must be a string');
end

%==========================================================================

%Now work out what format the arguments have taken:
basicinput=false; cellinput=false; keywordinput=false;
if nargin==6
    basicinput=true;
    argi = {};
elseif nargin>=7
    if iscell(varargin{1})
        cellinput=true;
    elseif ischar(varargin{1})
        keywordinput=true;
    end
    if nargin>7
        argi = varargin(2:end);
    else
        argi = {};
    end
else
    error('Horace error: check the format of optional inputs are either cell array or keyword');
end

%===
%If optional inputs have been chosen, check that they are in the correct
%format:
    function ok=correct_zone(zone_par)
        if ~isnumeric(zone_par) || numel(zone_par)~=3
            ok = false;
        else
            ok = true;
        end
    end

if cellinput
    zonelist=varargin{1};
    if prod(size(zonelist))~=numel(zonelist)
        error('Horace error: cell array specifying zones must be a 1-by-n cell array');
    else
        all_ok = cellfun(@(x)correct_zone(x),zonelist);
        if sum(all_ok) ~= numel(zonelist)
            error('Horace error: all elements of cell array specifying zones must be 3-element vectors');
        end
    end
end

if keywordinput
    keyword=varargin{1};
    if ~strcmp(keyword,'-cyclic') && ~strcmp(keyword,'-cycwithneg') && ~strcmp(keyword,'-ab') && ...
            ~strcmp(keyword,'-ac') && ~strcmp(keyword,'-bc');
        error('Horace error: keyword must be either ''-cyclic'', ''-cycwithneg'', ''-ab'', ''-ac'', or ''-bc''');
    end
end

%==========================================================================

if basicinput
    %wout=combine_equiv_basic(data_source,proj,pos,qstep,erange,outfile);
    transf_list=combine_equiv_basic(data_source,proj,pos,qstep,erange,outfile,argi{:});
elseif keywordinput
    %wout=combine_equiv_keyword(data_source,proj,pos,qstep,erange,outfile,keyword);
    transf_list=combine_equiv_keyword(data_source,proj,pos,qstep,erange,outfile,keyword,argi{:});
elseif cellinput
    %wout=combine_equiv_list(data_source,proj,pos,qstep,erange,outfile,zonelist);
    transf_list=combine_cuts_list(data_source,proj,pos,qstep,erange,outfile,zonelist,argi{:});
else
    error('Horace error: logic flaw - contact R. Ewings');
end

%if nargout==1
%    varargout{1}=wout;
%end

end