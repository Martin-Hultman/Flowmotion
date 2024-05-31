function [X, OLPercent, OLIndex] = Flowmotion_FilterMotionArtifacts(X, Fs, varargin)
% Flowmotion_FilterMotionArtifacts applies a Hampel filter to detect
% outliers in the signal, and replaces these by linear interpolation
% between the first preceding and succeeding valid samples. Optionally, a
% widening factor can be applied that also treats neighboring samples as
% outliers. This can make the outlier removal more robust to sustained
% motion artifacts. However, it should be used sparingly since linearly
% interpolating over many samples can cause undesired effects on the
% wavelet scalogram.
% 
% Inputs:
%   X  - The signal
%   Fs - Sample frequency
%
% Optional name-value inputs:
%   FilterLength - Length of the Hampel filter in seconds (default 20s)
%   Threshold    - Number of standard deviations from median for sample to be considered an outlier (default 4)
%   Widening     - Number of neighboring samples to either side of an outlier that is also replaced (default 4)
%
% Outputs:
%    X         - Filtered signal
%    OLPercent - Fraction replaced samples, in percent
%    OLIndex   - Indexes of replaced samples

% Parse inputs
Parser = inputParser();
Parser.addRequired("X");
Parser.addRequired("Fs");
Parser.addParameter("FilterLength", 20);
Parser.addParameter("Threshold", 4);
Parser.addParameter("Widening", 4);

Parser.parse(X, Fs, varargin{:});
Inputs = Parser.Results;

% ------------------------------------------------------------------------

% Find outliers using Hampel filter
winLength = ceil(Fs * Inputs.FilterLength / 2);
[~,idx] = filloutliers(X, "linear", "movmedian", [1,1] * winLength, "ThresholdFactor", Inputs.Threshold);

% Include neighbours as motion artifacts to fill "holes"
idx = movmax(idx, Inputs.Widening + 1);

% Fill extended outliers using linear interpolation
X = filloutliers(X, "linear", "OutlierLocations", idx);

% Find outlier indexes and calculate percentage
OLIndex   = find(idx);
OLPercent = mean(idx) * 100;

end
