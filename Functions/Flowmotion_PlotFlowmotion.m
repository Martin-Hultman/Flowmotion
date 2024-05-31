function Flowmotion_PlotFlowmotion(FM)
% Flowmotion_PlotFlowmotion plots a summary of the flowmotion analysis of
% a signal. The summary includes the cleaned signal, scalogram, power
% spectrum, and time-frequency-averaged flowmotion powers.
%
% Inputs:
%    FM - Flowmotion struct, returned from Flowmotion_ProcessSignal

% Get frequency bounds and names to show in plot
[fBounds,fNames] = Flowmotion_DefineFrequencyIntervals();
Nf = length(fBounds) - 1;

% Setup figure
clf;
tiledlayout(3,3, "TileSpacing", "compact", "Padding", "compact");

% ------------------------------------------------------------------------
% Plot signal

nexttile([1,2]);
hold on;
plot(FM.t, FM.XNorm , "--r", "LineWidth", 0.5, "DisplayName", "Removed artifacts");
plot(FM.t, FM.XClean, "-k" , "LineWidth", 1.0, "DisplayName", "Clean signal");

xlim([FM.t(1),FM.t(end)]);

xlabel("Time [seconds]");
ylabel("Pre-processed signal [-]");

legend("show", "Location", "northeast");

% ------------------------------------------------------------------------
% Plot time-frequency averages

nexttile([1,1]);
bar(FM.tfAverage, "BarWidth", 0.5, "EdgeColor","k");
xticklabels(fNames);
box on;
ylabel("Power [-]");
title("Time-frequency averaged flowmotion");

% ------------------------------------------------------------------------
% Plot scalogram

Ax = nexttile([2,2]);
Flowmotion_PlotScalogram(FM.t, FM.f, FM.Scalogram, "Parent", Ax);
xlabel("Time [seconds]");

% ------------------------------------------------------------------------
% Plot time-average spectrum

nexttile([2,1]);
XLim = [0, 1.05 * max(FM.tAverage, [], "all", "omitmissing")];
semilogy(FM.tAverage, FM.f, "-k", "LineWidth", 1.0);
hold on;

% Plot flowmotion frequency bounds
for i = 1:Nf+1
    plot(XLim, fBounds(i)*[1,1], "--", "LineWidth", 1.0, "Color", [1 1 1]*0.7);
end

ylim([FM.f(end), FM.f(1)]);
xlim(XLim);
xlabel("Power [-]");

end

