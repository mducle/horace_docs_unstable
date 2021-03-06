function [rot_ustep,trans_bott_left,ebin,trans_elo,urange_step,u_to_rlu,ulen] = get_pix_transf_(obj)

if ~isempty(obj.projaxes_)
    [rlu_to_ustep, u_to_rlu,ulen] = projaxes_to_rlu (obj.projaxes_, obj.alatt_, obj.angdeg_, obj.usteps(1:3));
    rot_ustep = rlu_to_ustep*obj.data_upix_to_rlu_; % convert from pixel proj. axes to steps of output projection axes
    trans_bott_left = obj.data_upix_to_rlu_\...
        (obj.uoffset(1:3)-obj.data_upix_offset_(1:3)+u_to_rlu*obj.urange_offset(1,1:3)'); % offset between origin
    % of pixel proj. axes and the lower limit of hyper rectangle defined by range of data , expressed in pixel proj. coords
    %
    % Transformation from pix coordinate system to img coordinate system:
    %u_to_rlu = u_to_rlu\obj.data_upix_to_rlu_;
else
    u_to_rlu = obj.data_u_to_rlu_(1:3,1:3);
    ulen = obj.data_ulen_(1:3);
    ustep_to_rlu = zeros(3,3);
    for i=1:3
        ustep_to_rlu(:,i) = obj.usteps(i)*u_to_rlu(:,i); % get step vector in r.l.u.
    end
    %rlu_to_ustep = inv(ustep_to_rlu);
    rot_ustep = ustep_to_rlu\obj.data_upix_to_rlu_; % convert from pixel proj. axes to steps of output projection axes
    trans_bott_left = obj.data_upix_to_rlu_\...
        (obj.data_uoffset_(1:3)-obj.data_upix_offset_(1:3)+u_to_rlu*obj.urange_offset(1,1:3)'); % offset between origin
    % of pixel proj. axes and the lower limit of hyper rectangle defined by range of data , expressed in pixel proj. coords
end


ebin=obj.usteps(4);                 % plays role of rot_ustep for energy
trans_elo = obj.urange_offset(1,4); % plays role of trans_bott_left for energy
urange_step = obj.urange_step;


