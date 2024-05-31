function Scalogram = Flowmotion_RemoveCOI(Scalogram,f,COI)
% Flowmotion_RemoveCOI sets the time-frequency pixels in the scalogram that
% are within the COI (too close to the signal edges to be valid) to NaN
% (not-a-number). This makes them simple to exclude from following analysis
% such as when computing the time-average power spectrum.
%
% Inputs:
%    Scalogram - The wavelet power scalogram
%    f         - Frequency vector for the scalogram, decreasing order
%    COI       - Frequency of COI boundary for each point of the scalogram
%                time axis, returned from e.g. cwt(...) or Flowmotion_GetCOI(...)
%
% Output:
%    Scalogram - Wavelet power scalogram with removed COI

% Vector with index for each time-point, where pixels with y-coordinate
% greater than this index fall within COI
[~,idx] = min(abs(COI(:)' - f(:)),[],1);

% Loop through each timepoint in the scalogram and set all pixels below
% the COI-line to NaN
for i = 1:size(Scalogram,2)
    Scalogram(idx(i):end,i) = NaN;
end

end
