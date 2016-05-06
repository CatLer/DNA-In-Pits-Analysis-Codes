function [] = SampleVid( varargin )
%SAMPLEVID: Save or play sample video.
%   input args (in any order)
%   'video', video, 'play', 'new', full filename, 'frame start', first
%   frame, 'frame end', last frame, 'jump', jump
%   last frame can be 'inf', will pick the last frame

narginchk(2,9)

frame_start = 1;
frame_end = 100;
new_video = '';
Play = 0;
jump = 1;

for i=1:numel(varargin)
    if strcmpi(varargin{i},'frame start') && i<numel(varargin)
        frame_start = varargin{i+1};
    else
        if strcmpi(varargin{i},'frame end') && i<numel(varargin)
            frame_end = varargin{i+1};
        else
            if strcmpi(varargin{i}, 'new') && i<numel(varargin)
                new_video = varargin{i+1};
            else
                if strcmpi(varargin{i}, 'video') && i<numel(varargin)
                    video = varargin{i+1};
                else
                    if strcmpi(varargin{i}, 'play')
                        Play =1;
                    else
                        if strcmpi(varargin{i}, 'jump') && i<numel(varargin)
                            jump =varargin{i+1};
                        end
                    end
                end
            end
        end
    end
end

info = imfinfo(video);
numIm = numel(info);
mIm = info(1).Width;
nIm = info(1).Height;

if frame_end>numIm
    frame_end = numIm;
end


if ~isempty(new_video)
   tiff_obj =  Tiff(new_video,'w');
end

A = zeros(nIm, mIm, frame_end-frame_start+1, 'uint16');
for i=frame_start:jump:frame_end
    A(:,:,i-frame_start+1) = imread(video, i, 'Info',info);
end

if isempty(new_video) || Play==1
    implay(video)
end
end

