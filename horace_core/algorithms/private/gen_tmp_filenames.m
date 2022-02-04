function [tmp_file,sqw_file_tmp] = gen_tmp_filenames (spe_file, sqw_file,ind)
% Create temporary sqw file names, one for each of the spe files to be processed
%
%   >> tmp_file = gen_tmp_filenames (spe_file, sqw_file, ind)
%
% Input:
% ------
%   spe_file        Cell array of spe file names (cell array even if a single file)
%   sqw_file        Output sqw file name (character string)
%   ind             Index into the array spe_file for which to create tmp files
%                  If omitted, then assume all spe files are to be used.
%
% Output:
% -------
%   tmp_file        Cell array of unique temporary sqw file names (it is a cell
%                  array even if a single file). The name is chosen as:
%                   - In same folder as output sqw file
%                   - Will try to use the spe file name but with extension .tmp
%                   - If the spe file name is empty, then will behave as if the
%                    name of the source is 'dummy.spe'.
%                   - If ambiguous (two spe files with the same name, either
%                    because the same file appears twice, or the spe files are in
%                    different folders) then the output files have name and
%                    extension: <name>.tmp, <name>_2.tmp, <name>_3.tmp ...
%                   - If the above leads to non-unique tmp file names (e.g.
%                    if spe files are file_2.spe, file.spe, file.spe), then
%                    create unique tmp file name using random string generation
%                   - If the tmp files matches the sqw file (e.g. if the sqw file
%                    happens to be  'file.tmp' in the above example) then the same
%                    random string generation is used. (This case could
%                    arise because one may try to accumulate to a previously
%                    existing tmp file).
%
%   sqw_file_tmp    Temporary sqw file (character)
%                   This is a unique name that can be used to accumulate
%                   output to, and then rename as sqw_file.
%
%
% Note: the functions that call this routine should already have checked that none
%       of the spe file input has extension '.tmp' or '.sqw'. This should avoid any
%       possibility of overwriting an spe file when the tmp files are created.


% Assume all spe files if ind array not given
if nargin==2
    ind=1:numel(spe_file);
end

% Catch trivial case of no spe file
if isempty(ind)
    tmp_file={};
    sqw_file_tmp='';
    return
end

% General case: .tmp files
% ------------------------
ntmp=numel(ind);
tmp_file = cell(ntmp,1);
[tmp_path,sqw_name,sqw_ext] = fileparts(sqw_file);
tmp_ext = '.tmp';


name=cell(ntmp,1);
spe_path = '';
for i=1:ntmp
    if ~isempty(spe_file{ind(i)})
        [sp,name{i}]=fileparts(spe_file{ind(i)});
        if isempty(spe_path)
            spe_path  = sp;
        end
    else
        name{i}='dummy';
    end
end

%
hc = hor_config;
wk_dir_is_default = hc.wkdir_is_default;

if isempty(tmp_path) % always write tmp files where sqw file located
    if wk_dir_is_default % if working directory has not been explicitly set,
        if isempty(spe_path)
            tmp_path = pwd;
        else
            hc.working_directory = spe_path;
            tmp_path = spe_path;
        end
    else
        tmp_path= hc.working_directory;
    end
else
    if wk_dir_is_default
        hc.working_directory = tmp_path;
    else
        pc = parallel_config;
        rem_dir = pc.shared_folder_on_remote;
        loc_dir = pc.shared_folder_on_local;
        if strcmpi(rem_dir,loc_dir) %TODO: This needs further analysis of the logic
            hc.working_directory = tmp_path;
        end
    end
end
%



% Must account for the possibility that the spe file is repeated, or that
% the name is not unique even if the full name is unique
[namesort,ix]=sort(name);
namesort_mod=namesort;
irep=1;
for i=2:ntmp
    if strcmp(namesort{i-1},namesort{i})
        irep=irep+1;
        namesort_mod{i}=[namesort{i},'_',num2str(irep)];
    else
        irep=1;
    end
end
ok=true;
% Check no ambiguity introduced
namesort2=sort(namesort_mod);
for i=2:ntmp
    if strcmp(namesort2{i-1},namesort2{i})
        ok=false;
        break
    end
end
% Check no conflict with sqw file name
if ok && strcmp(tmp_ext,sqw_ext) && any(strcmp(sqw_name,namesort_mod))
    ok=false;
end
% Create new list of tmp files if not ok
if ok
    for i=1:ntmp
        tmp_file{ix(i)}=fullfile(tmp_path,[namesort_mod{i},tmp_ext]);
    end
else
    ranstr=str_random(8);
    for i=1:ntmp
        tmp_file{i}=fullfile(tmp_path,[name{i},'_',ranstr,'_',num2str(i),tmp_ext]);
    end
end


% General case: temporary sqw_file name
% -------------------------------------
% Create temporary sqw_file name
sqw_file_tmp=fullfile(tmp_path,[sqw_name,'_tmp',sqw_ext]);

% Check no conflict with tmp file names
if any(strcmp(sqw_file_tmp,tmp_file))
    sqw_file_tmp=fullfile(tmp_path,[sqw_name,'_',ranstr,'_tmp',sqw_ext]);
end
