function FM = Flowmotion_ComputeAndProcessScalogram(X,Fs)
% Flowmotion_ComputeAndProcessScalogram takes a pre-processed signal X and
% computes the wavelet power scalogram, removes the cone-of-influence, and
% computes the time-averaged power spectum and time-frequency-averaged
% flowmotion power values.
%
% Input:
%   X  - Signal
%   Fs - Sample rate of X
%
% Output:
%   FM - Struct containing the results of the flowmotion analysis.
%      : Scalogram    - The power scalogram
%      : f            - Frequency axis of the scalogram, decreasing order
%      : tAverage     - Time-averaged power spectrum
%      : tAverageNum  - Number of valid time points for each frequency of the power spectrum
%      : tfAverage    - Time-frequency-averaged flowmotion power for each frequency interval
%      : tfAverageNum - Number of valid points for each average in tfAverage
%
% Note 1: This function assumes that X is evenly sampled at rate Fs. Any
% necessary preprocessing such as resampling or filling in missing data
% must be done before using this function.
%
% Note 2: The time-frequency averages are *not* equivalent to taking the
% frequency average of the power spectum 'tAverage' in each interval. This
% is because a two-step time-fequency average give slightly higher weight
% to lower frequencies in the interval, since these contain fever valid
% points due to the COI, meaning each value gets a slightly higher
% influence on the final time-frequency average. The implemented method
% instad weighs each time-frequency 'pixel' in the frequency interval
% equally. However, the distinction is only really noticable for short
% signals.

% Wavelet transform using analytic Morlet base function
[WT,f,COI,~] = cwt(X, "amor", Fs);

% Compute the power scalogram, then remove edge effects by setting all
% pixels in the COI to NaN
Scalogram = abs(WT).^2;
ScalogramMasked = Flowmotion_RemoveCOI(Scalogram,f,COI);

% Time-average the scalogram to get power spectrum, and compute the number
% of valid points used for each frequency (this can be useful for later
% analysis)
tAverage = mean(ScalogramMasked, 2, "omitmissing");
tAverageNum = sum(~isnan(ScalogramMasked),2);

% Define frequeny limits for the flowmotion intervals
fBounds = Flowmotion_DefineFrequencyIntervals();
Nf = length(fBounds)-1;

% Compute the time-frequency average in each flowmotion interval
tfAverage = nan(1,Nf);
tfAverageNum = nan(1,Nf);

for i = 1:Nf
    fMask = f < fBounds(i) & f > fBounds(i+1);
    tfAverageNum(i)  = sum(~isnan(ScalogramMasked(fMask,:)), "all");
    if (tfAverageNum(i) > 0)
        tfAverage(i) = mean(ScalogramMasked(fMask,:), "all", "omitmissing");
    end
end

% Collect outputs in a struct to keep it organized
FM = struct( ...
    "Scalogram"   , single(Scalogram), ...
    "f"           , single(f), ...
    "tAverage"    , single(tAverage), ...
    "tAverageNum" , single(tAverageNum), ...
    "tfAverage"   , single(tfAverage), ...
    "tfAverageNum", single(tfAverageNum));

end

