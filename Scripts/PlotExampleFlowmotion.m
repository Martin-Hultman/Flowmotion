%% Load data

% Get path to this file
filepath = fileparts(mfilename('fullpath'));

% Load data from example folder
Data = load(filepath + "/../Example data/ExampleFullSignal.mat");

%% Process and plot baseline flowmotion

tBaseline = Data.t(1:Data.idxOcclusionStart);
XBaseline = Data.X(1:Data.idxOcclusionStart);
FMBaseline = Flowmotion_ProcessSignal(tBaseline, XBaseline, Data.Fs, "Type", "Baseline");

figure(101);
Flowmotion_PlotFlowmotion(FMBaseline);
sgtitle("Baseline flowmotion");

%% Process and plot reperfusion flowmotion

[~, idxPeak] = Flowmotion_FindReperfusionPeak(Data.t, Data.X, Data.Fs, "OcclusionEndIdx", Data.idxOcclusionEnd);
tReperfusion = Data.t(idxPeak:end);
tReperfusion = tReperfusion - tReperfusion(1);
XReperfusion = Data.X(idxPeak:end);
FMReperfusion = Flowmotion_ProcessSignal(tReperfusion, XReperfusion, Data.Fs, "Type", "Reperfusion");

figure(102);
Flowmotion_PlotFlowmotion(FMReperfusion);
sgtitle("Reperfusion flowmotion");
