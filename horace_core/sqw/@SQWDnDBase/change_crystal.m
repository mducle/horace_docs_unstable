function varargout = change_crystal (varargin)
% Change the crystal lattice and orientation of an sqw object or array of objects
%
% Most commonly:
%   >> wout = change_crystal (w, rlu_corr)              % change lattice parameters and orientation
%
% OR
%   >> wout = change_crystal (w, alatt)                 % change just length of lattice vectors
%   >> wout = change_crystal (w, alatt, angdeg)         % change all lattice parameters
%   >> wout = change_crystal (w, alatt, angdeg, rotmat) % change lattice parameters and orientation
%   >> wout = change_crystal (w, alatt, angdeg, u, v)   % change lattice parameters and redefine u, v
%
%
% Input:
% -----
%   w           Input sqw object
%
%   rlu_corr    Matrix to convert notional rlu in the current crystal lattice to
%              the rlu in the the new crystal lattice together with any re-orientation
%              of the crystal. The matrix is defined by the matrix:
%                       qhkl(i) = rlu_corr(i,j) * qhkl_0(j)
%               This matrix can be obtained from refining the lattice and
%              orientation with the function refine_crystal (type
%              >> help refine_crystal  for more details).
% *OR*
%   alatt       New lattice parameters [a,b,c] (Angstroms)
%   angdeg      New lattice angles [alf,bet,gam] (degrees)
%   rotmat      Rotation matrix that relates crystal Cartesian coordinate frame of the new
%              lattice as a rotation of the current crystal frame. Orthonormal coordinates
%              in the two frames are related by
%                   v_new(i)= rotmat(i,j)*v_current(j)
%   u, v        Redefine the two vectors that were used to determine the scattering plane
%              These are the vectors at whatever disorientation angles dpsi, gl, gs (which
%              cannot be changed).
%
% Output:
% -------
%   wout        Output sqw object with changed crystal lattice parameters and orientation
%
% NOTE
%  The input data set(s) can be reset to their original orientation by inverting the
%  input data e.g.
%    - call with inv(rlu_corr)
%    - call with the original alatt, angdeg, u and v

% This routine is also used to change the crystal in sqw files, when it overwrites the input file.

% Parse input
% -----------
[w, args, mess] = horace_function_parse_input(nargout, varargin{:});
if ~isempty(mess)
    error(mess);
end

% Perform operations
% ------------------
if w.source_is_file
    for i = 1:numel(w.data)
        ld = w.loaders_list{i};
        data = ld.get_data('-verbatim', '-head');
        target_file = fullfile(ld.filepath,ld.filename);
        ld = ld.set_file_to_update(target_file);
        if ld.sqw_type
            exp_info = ld.get_header('-all');
            [exp_info, data]=change_crystal_alter_fields(exp_info,data,args{:});
            ld = ld.put_headers(exp_info);
            ld = ld.put_samples(exp_info.samples);
        else
            exp_info = struct([]);
            [~, data] = change_crystal_alter_fields(exp_info,data,args{:});
        end
        ld = ld.put_dnd_metadata(data);
        ld.delete();
    end
    argout = {};
else
    argout{1} = w.data;
    for i = 1:numel(w.data)
        if isprop(w.data(i),'experiment_info')
            [hdr, argout{1}(i).data, ok, mess] = change_crystal_alter_fields( ...
                w.data(i).experiment_info, w.data(i).data_,args{:});
            argout{1}(i) = argout{1}(i).change_header(hdr);
        else
            [~, argout{1}(i).data_, ok, mess] = change_crystal_alter_fields( ...
                struct([]), w.data(i).data_,args{:});
        end
        if ~ok
            error(mess);
        end
    end
end

% Package output arguments
% ------------------------
[varargout, mess] = horace_function_pack_output(w, argout{:});
if ~isempty(mess)
    error(mess)
end

