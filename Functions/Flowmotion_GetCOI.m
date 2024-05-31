function COI = Flowmotion_GetCOI(t)
% Flowmotion_GetCOI returns, for each timepoint, the frequency indicating
% the boundary between the cone-of-influence (COI) and valid data.
%
% Any real data likely has a misalignment between the first and last sample
% in the signal, which can result in a high-power artifact at both the
% beginning and end of the scalogram time axis. The COI marks the time from
% either edge of the signal where this artifact has reduced in strength to
% 1/e^2 ~ 13.5% of its maximum. Removing the scalogram points within the
% COI prevents false conclusions about the true flowmotion activity.
%
% For more details, see:
% Matlab documentation:
%    Boundary Effects and the Cone of Influence
%    https://mathworks.com/help/wavelet/ug/boundary-effects-and-the-cone-of-influence.html
% Original publication:
%    A practical guide to wavelet analysis
%    Torrence and Compo, 1998
%    https://doi.org/10.1175/1520-0477(1998)079<0061:APGTWA>2.0.CO;2
%
% Note 1: There is a slight error in the Matlab documentation where they
% describe the COI as the 1/e decay line in the scalogram, which does not
% match the original publication where they define the COI at 1/e^2.
% However, the actual COI computed in the wavelet toolbox is correct at
% 1/e^2.
%
% Note 2: The wavelet toolbox uses a default 6-cycle wide Gaussian in the
% creation of the Morlet base function, i.e. the Gaussian function used to
% modulate the sine and cosine covers about 6 of the sine and cosine
% periods. To match this, the number of cycles paramter is hardcoded to 6
% in this function. This might be generalized in the future.
%
% Inputs:
%    t - Time vector
%
% Outputs:
%    COI - Cone-of-influence frequencies for each time point in t

% Make sure t is a row vector
t = t(:)';

% Hardcode number of cycles to match the defaults in 'cwtfilterbank'
numCycles = 6;

% Compute COI frequencies
COI = numCycles * sqrt(2) ./ (2 * pi * t);

% Compose final COI values by mirorring the above values (the if statement
% handles the slightly different cases of odd and even number of time
% points)
if (mod(length(t),2) == 1)
    % Odd
    COI = [ ...
             COI(1 : ceil(end/2)   ), ...
        flip(COI(1 : ceil(end/2)-1))
        ];
else
    % Even
    COI = [ ...
             COI(1 : end/2 ), ...
        flip(COI(1 : end/2))
        ];
end

% Replace any infinities with "large" values to prevent some issues with
% plotting the COI. Infinities happen if t=0.
COI(COI ==  inf) =  1e15;

end

