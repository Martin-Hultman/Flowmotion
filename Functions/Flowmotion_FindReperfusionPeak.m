function [tPeak, idxPeak] = Flowmotion_FindReperfusionPeak(t,X,Fs,varargin)
% Flowmotion_FindReperfusionPeak estimates the time of the post-occlsuion
% perfusion peak by smoothing the signal to remove noise and influence of
% heart beats.
% 
% Inputs:
%   t  - Time vector
%   X  - Data vector
%   Fs - Sample frequency
%
% Optional name-value inputs:
%   OcclusionEndIdx - Sample index for end of occlusion (only signal
%                     after this index is considered if this is provided,
%                     else the whole signal is processed)
%
% Outputs:
%   tPeak   - Estimated time point of reperfusion peak
%   idxPeak - Corresponding sample index of the peak

% Parse inputs
Parser = inputParser();
Parser.addRequired("t");
Parser.addRequired("X");
Parser.addRequired("Fs", @(x) isnumeric(x) && isscalar(x));
Parser.addParameter("OcclusionEndIdx", 1, @(x) isnumeric(x) && isscalar(x));

Parser.parse(t, X, Fs, varargin{:});
Inputs = Parser.Results;

% ------------------------------------------------------------------------

% Two-step signal smoothing
% First apply a 5 second moving median to deal with large outliers (if any)
XSmooth = movmedian(X(Inputs.OcclusionEndIdx:end), Fs*5);
% Then apply a 10 second gaussian filter to smooth out any potential
% plateaus from the median filter
XSmooth = smoothdata(XSmooth, "gaussian", Fs * 10, "omitmissing");

% Estimate peak as max point of smoothed signal
[~, idxPeak] = max(XSmooth);
idxPeak = idxPeak + Inputs.OcclusionEndIdx - 1;
tPeak = t(idxPeak);

end
