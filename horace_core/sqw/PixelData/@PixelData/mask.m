function pix_out = mask(obj, mask_array, varargin)
% MASK remove the pixels specified by the input logical array
%
% You must specify exactly one return argument when calling this function.
%
% Input:
% ------
% mask_array   A logical array specifying which pixels should be kept/removed
%              from the PixelData object. Must be of length equal to the number
%              of pixels in 'obj' or equal in size to the 'npix' argument. A
%              true/1 in the array indicates that the pixel at that index
%              should be retained, a false/0 indicates the pixel should be
%              removed.
%
% npix         (Optional)
%              Array of integers that specify how many times each value in
%              mask_array should be replicated. This is useful for when masking
%              all pixels contributing to a bin. Size must be equal to that of
%              'mask_array'. E.g.:
%               mask_array = [      0,     1,     1,  0,     1]
%               npix       = [      3,     2,     2,  1,     2]
%               full_mask  = [0, 0, 0,  1, 1,  1, 1,  0,  1, 1]
%
%              The npix array must account for all pixels in the PixelData
%              object i.e. sum(npix, 'all') == obj.num_pixels. It must also be
%              the same dimensions as 'mask_array' i.e.
%              all(size(mask_array) == size(npix)).
%
% Output:
% -------
% pix_out      A PixelData object containing only non-masked pixels.
%
if nargout ~= 1
    error('PIXELDATA:mask', ['Bad number of output arguments.\n''mask'' must be ' ...
        'called with exactly one output argument.']);
else
    [mask_array, npix] = validate_input_args(obj, mask_array, varargin{:});
end

if numel(mask_array) == obj.num_pixels && all(mask_array)
    pix_out = obj;
    return;
elseif numel(mask_array) == obj.num_pixels && ~any(mask_array)
    pix_out = PixelData();
    return;
end

if numel(mask_array) == obj.num_pixels

    if obj.is_filebacked()
        pix_out = do_mask_file_backed_with_full_mask_array(obj, mask_array);
    else
        pix_out = do_mask_in_memory_with_full_mask_array(obj, mask_array);
    end

elseif ~isempty(npix)

    if obj.is_filebacked()
        pix_out = do_mask_file_backed_with_npix(obj, mask_array, npix);
    else
        full_mask_array = repelem(mask_array, npix);
        pix_out = do_mask_in_memory_with_full_mask_array(obj, full_mask_array);
    end

end

end


% -----------------------------------------------------------------------------
function pix_out = do_mask_in_memory_with_full_mask_array(obj, mask_array)
% Perform a mask of an all in-memory PixelData object with a mask array as
% long as the PixelData array i.e. numel(mask_array) == pix.num_pixels
%
pix_out = obj.get_pixels(mask_array);
end

function pix_out = do_mask_file_backed_with_full_mask_array(obj, mask_array)
% Perfrom a mask of a file-backed PixelData object with a mask array as
% long as the full PixelData array i.e. numel(mask_array) == pix.num_pixels
%
obj.move_to_first_page();

pix_out = PixelData();
end_idx = 0;
while true
    start_idx = end_idx + 1;
    end_idx = start_idx + obj.page_size - 1;
    mask_array_chunk = mask_array(start_idx:end_idx);

    pix_out.append(PixelData(obj.data(:, mask_array_chunk)));

    if obj.has_more()
        obj = obj.advance();
    else
        break;
    end
end
end

function pix_out = do_mask_file_backed_with_npix(obj, mask_array, npix)
% Perform a mask of a file-backed PixelData object with a mask array and
% an npix array. The npix array should account for the full range of pixels
% in the PixelData instance i.e. sum(npix) == pix.num_pixels.
%
% The mask_array and npix array should have equal dimensions.
%
obj.move_to_first_page();
pix_out = PixelData();

[npix_chunks, idxs] = split_vector_fixed_sum(npix(:), obj.base_page_size);
page_number = 1;
while true
    npix_for_page = npix_chunks{page_number};
    idx = idxs(:, page_number);

    mask_array_chunk = repelem(mask_array(idx(1):idx(2)), npix_for_page);
    pix_out.append(PixelData(obj.data(:, mask_array_chunk)));

    if obj.has_more()
        obj.advance();
        page_number = page_number + 1;
    else
        break;
    end
end
end

function [mask_array, npix] = validate_input_args(obj, mask_array, varargin)
parser = inputParser();
parser.addRequired('obj');
parser.addRequired('mask_array');
parser.addOptional('npix', []);
parser.parse(obj, mask_array, varargin{:});

mask_array = parser.Results.mask_array;
npix = parser.Results.npix;
persistent sum_all;
if isempty(sum_all)
    % versions lower then 2018b do not accept 'all' option
    try
        sum_all = @(x)sum(x,'all');
        s = sum_all(1:10);
    catch
        sum_all = @(x)sum(reshape(x,[1,numel(x)]));
    end
end

if numel(mask_array) ~= obj.num_pixels && isempty(npix)
    error('PIXELDATA:mask', ...
        ['Error masking pixel data.\nThe input mask_array must have ' ...
        'number of elements equal to the number of pixels or must ' ...
        ' be accompanied by the npix argument. Found ''%i'' ' ...
        'elements, ''%i'' or ''%i'' elements required.'], ...
        numel(mask_array), obj.num_pixels, obj.page_size);
elseif ~isempty(npix)
    if any(numel(npix) ~= numel(mask_array))
        error('PIXELDATA:mask', ...
            ['Number of elements in mask_array and npix must be equal.' ...
            '\nFound %i and %i elements'], numel(mask_array), numel(npix));
    elseif sum_all(npix) ~= obj.num_pixels
        error('PIXELDATA:mask', ...
            ['The sum of npix must be equal to number of pixels.\n' ...
            'Found sum(npix) = %i, %i pixels required.'], ...
            sum(npix, 'all'), obj.num_pixels);
    end
end

if ~isvector(mask_array)
    mask_array = mask_array(:);
end
if ~isa(mask_array, 'logical')
    mask_array = logical(mask_array);
end

if ~isempty(npix) && ~isvector(npix)
    npix = npix(:);
end
end
