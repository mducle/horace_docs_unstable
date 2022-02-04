function indexes = check_pixel_fields_(obj, fields)
%CHECK_PIXEL_FIELDS_ Check the given field names are valid pixel data fields
% Raises error with ID 'HORACE:PIXELDATA:invalid_field' if any fields not valid.
%
%
% Input:
% ------
% fields    -- A cellstr of field names to validate.
% 
% Output: 
% indexes   -- the indexes corresponding to the fields
%
num_bad_fields = 0;
bad_fields = cell(1, numel(fields));
indexes = bad_fields;
for i = 1:numel(fields)
    field = fields{i};
    if ~obj.FIELD_INDEX_MAP_.isKey({field})
        bad_fields{num_bad_fields + 1} = field;
        num_bad_fields = num_bad_fields + 1;
    else
        indexes{i} = obj.FIELD_INDEX_MAP_(field);
    end
end
indexes = unique([indexes{:}]);


if num_bad_fields > 0
    valid_fields = obj.FIELD_INDEX_MAP_.keys();
    error( ...
        'HORACE:PixelData:invalid_argument', ...
        'Invalid pixel field(s) {''%s''}.\nValid keys are: {''%s''}', ...
        strjoin(bad_fields(1:num_bad_fields), ''', '''), ...
        strjoin(valid_fields, ''', ''') ...
    );
end
