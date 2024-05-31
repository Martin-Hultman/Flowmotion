function FM = Flowmotion_ProcessSignal(t,X,Fs,varargin)
% Flowmotion_ProcessSignal performs flowmotion analysis of a signal X and
% returns a struct containing the results of the different processing steps
% and analysis.
%
% Inputs:
%    t  - Time vector
%    X  - Signal vector
%    Fs - Sample frequency
% 
% Optional name-value inputs:
%    Type - Either "Baseline" or "Reperfusion", determines the normalization
%           method used in the flowmotion analysis (defualt "Baseline")
%
% Outputs:
%    FM - Struct containing the following fields:
%       : t              - Time vector
%       : X              - Original data
%       : XNorm          - Normalized data
%       : XClean         - Normalized and artifact-filtered data (this is used in the wavelet tranform)
%       : Fs             - Sample frequency
%       : OutlierPercent - Fraction of samples affected by the artifact filtering
%       : OutlierIndex   - Index of filtered samples
%       : XFit           - Reperfusion model applied to times in 't' (reperfusion type only)
%       : ModelParams    - Optimal reperfusion model parameters (reperfusion type only)
%       : GOF            - Struct containing 'goodness-of-fit' information (reperfusion type only)
%       : Additionally, FM contains all fields described in Flowmotion_ComputeAndProcessScalogram

% Parse inputs
Parser = inputParser();
Parser.addRequired("t");
Parser.addRequired("X");
Parser.addRequired("Fs", @(x) isnumeric(x) && isscalar(x));
Parser.addParameter("Type", "Baseline", @isStringScalar);

Parser.parse(t, X, Fs, varargin{:});
Inputs = Parser.Results;

% ------------------------------------------------------------------------

% Just in case, replace any missing (NaN) values by linear interpolation
X = fillmissing(X, "linear");

% Resample signal to ensure equal time difference between samples
tNew = t(1):1/Fs:t(end);
X = interp1(t,X,tNew,"linear","extrap");
t = tNew;

% Normalize the signal, method depends on baseline of reperfusion phase
if (Inputs.Type == "Baseline")
    XNorm = X / mean(X,"omitmissing") - 1;
elseif (Inputs.Type == "Reperfusion")
    [XFit, ModelParams, GOF] = Flowmotion_FitReperfusion(t,X);
    XNorm = (X - XFit) / ModelParams(4);
else
    error("MATLAB:ValueNotSupportedError", "Signal type '" + Inputs.Type + "' is not supported");
end

% Filter motion artifacts and get outlier information
[XClean, OutlierPercent, OutlierIndex] = Flowmotion_FilterMotionArtifacts(XNorm, Fs, "Threshold", 5);

% Compute wavelet power scalogram and perform time and time-frequency
% averages
FM = Flowmotion_ComputeAndProcessScalogram(XClean,Fs);

% Add data to struct for later convenience
FM.t = t;
FM.X = X;
FM.XNorm = XNorm;
FM.XClean = XClean;
FM.Fs = Fs;
FM.OutlierPercent = OutlierPercent;
FM.OutlierIndex = OutlierIndex;

% If signal is reperfusion, also add model fit
if (Inputs.Type == "Reperfusion")
    FM.XFit = XFit;
    FM.ModelParams = ModelParams;
    FM.GOF = GOF;
end

end

