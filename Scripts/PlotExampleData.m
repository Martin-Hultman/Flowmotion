%% Load data

% Get path to this file
filepath = fileparts(mfilename('fullpath'));

% Load data from example folder
Data = load(filepath + "/../Example data/ExampleFullSignal.mat");

%% Find reperfusion peak 

tPeak = Flowmotion_FindReperfusionPeak(Data.t, Data.X, Data.Fs, "OcclusionEndIdx", Data.idxOcclusionEnd);

%% Plot signal and events

figure(101);
clf;
hold on;

% Plot signal
plot(Data.t, Data.X, "-k", "LineWidth", 0.5, "DisplayName", "LDF perfusion");

% Plot events
xline(Data.tOcclusionStart, "-r" , "LineWidth", 1.5, "DisplayName", "Occlusion start");
xline(Data.tOcclusionEnd  , "--r", "LineWidth", 1.5, "DisplayName", "Occlusion end")
xline(tPeak               , "-b" , "LineWidth", 1.5, "DisplayName", "Peak (estimated)");

% Set limits, activate legend, etc.
xlim([Data.t(1), Data.t(end)]);
box on;
legend("show", "Location", "northwest");
xlabel("Time [s]");
ylabel("Perfusion [PU]");
