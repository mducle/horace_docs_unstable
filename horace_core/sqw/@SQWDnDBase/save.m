function save (w, varargin)
% Save a sqw object or array of sqw objects to file
%
%   >> save (w)              % prompt for file
%   >> save (w, file)        % give file
%   >> save (w, file,loader) % save file using specific data loader
%                             (-update option, is provided, will be
%                             ignored)
% 
%   >> save (w, file,'-update') % if the target file exist, update it to
%                               latest format if this is possible. If
%                               update is possible, pixels in file will not be
%                               overwritten.
% Input:
%   w       sqw object
%   file    [optional] File for output. if none given, then prompted for a file
%
%   Note that if w is an array of sqw objects then file must be a cell
%   array of filenames of the same size.
%
% Output:

% Original author: T.G.Perring
%

[ok,mess,upgrade,argi] = parse_char_options(varargin,{'-update'});
if ~ok
    error('SQW_FILE_IO:invalid_argument',mess);
end

% Use the concrete class name as file extension
file_ext = lower(class(w));

% Get file name - prompting if necessary
ldw = [];
if numel(argi)==0
    file_internal = putfile(['*.' file_ext]);
    if (isempty(file_internal))
        error ('No file given')
    end
elseif numel(argi)>1 && isa(argi{2},'dnd_binfile_common') % specific loader provided
    file_internal = argi{1};
    ldw  = argi{2};
else
    [file_internal,mess]=putfile_horace(argi{1});
    if ~isempty(mess)
        error(mess)
    end
end
if ~iscellstr(file_internal)
    file_internal=cellstr(file_internal);
end
if numel(file_internal)~=numel(w)
    error('Number of data objects in array does not match number of file names')
end

hor_log_level = ...
    config_store.instance().get_value('herbert_config','log_level');


for i=1:numel(w)
    if isempty(ldw)
        if isa(w(i), 'DnDBase') %
            sqw_type = false;
            ldw = sqw_formats_factory.instance().get_pref_access('dnd');
        else
            sqw_type = true;
            ldw = sqw_formats_factory.instance().get_pref_access(w(i));
        end
    else
        sqw_type = isa(w(i),'sqw');
    end

    % Write data to file   x
    if hor_log_level>0
        disp(['*** Writing to ',file_internal{i},'...'])
    end
    if ~upgrade && exist(file_internal{i},'file') == 2
        delete(file_internal{i});
    end
    ldw = ldw.init(w(i),file_internal{i});
    if ldw.upgrade_mode % as we delete file, this never happens. The question is where it should?
        if sqw_type
            ldw = ldw.put_sqw('-update','-nopix');
        else  %TODO:  OOP violation -- save dnd should be associated with dnd class
            ldw = ldw.put_dnd('-update','-nopix');
        end
    else
        if sqw_type   %TODO:  OOP violation -- save dnd should be associated with dnd class
            ldw = ldw.put_sqw();
        else
            ldw = ldw.put_dnd();
        end
    end
    ldw = ldw.delete();
end
