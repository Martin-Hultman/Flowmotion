function Flowmotion_PlotScalogram(t,f,Scalogram, varargin)
% Flowmotion_PlotScalogram plots a flowmotion scalogram and indicates the
% flowmotion frequency intervals. This function can be used standalone, but
% is also called by Flowmotion_PlotFlowmotion.
% 
% Inputs:
%    t - Time vector of the scalogram
%    f - Frequency vector of the scalogram, decreasing order
%    Scalogram - The flowmotion power scalogram
%
% Optional name-value inputs:
%    Parent        - Axis handle to plot in, will overwrite existing
%                    graphics (default uses curent active axis)
%    Colormap      - Colormap for the scalogram image, can be string or Nx3
%                    matrix (default "parula")
%    TextColor     - Color for the flowmotion freuency bounds and text, in
%                    any accepted color format (default white)
%    TextAlignment - Either "left" or "right" alignment for flowmotion
%                    names (defualt right)
%    COIAlpha      - Alpha value of the COI in range 0-1 (default 0.75)

% Parse inputs
Parser = inputParser();
Parser.addRequired("t");
Parser.addRequired("f");
Parser.addRequired("Scalogram");
Parser.addParameter("Parent", [], @(x) isempty(x) || isgraphics(x));
Parser.addParameter("Colormap", "parula", @(x) ischar(x) || isStringScalar(x) || (isnumeric(x) && (size(x,2) == 3)));
Parser.addParameter("TextColor", "w");
Parser.addParameter("TextAlignment", "right", @isStringScalar);
Parser.addParameter("COIAlpha", 0.75, @(x) isnumeric(x) && isscalar(x) && (x >= 0 && x <= 1));

Parser.parse(t,f,Scalogram, varargin{:});
Inputs = Parser.Results;

% ------------------------------------------------------------------------

% Get current axis if not provided, then clear axis
if isempty(Inputs.Parent)
    Ax = gca();
else
    Ax = Inputs.Parent;
end
cla(Ax);

% Get frequency bounds and names to show in plot
[fBounds,fNames] = Flowmotion_DefineFrequencyIntervals();
Nf = length(fBounds) - 1;

% Compute automatic color scaling to get decent contrast in scalogram
CLim = prctile(Scalogram, 95 ,"all");

% Plot scalogram
imagesc(Ax, t, f, Scalogram, [0,CLim]);
hold on;
colormap(Inputs.Colormap);

% Get and plot COI using a transparent fill over invalid values
COI = Flowmotion_GetCOI(t);
fill([t(:); flip(t(:))], [COI(:); f(end)*ones(length(t),1)], [1,1,1]*0.75, "EdgeColor", "none", "FaceAlpha", Inputs.COIAlpha);

% Plot bounds and labels for each flowmotion frequency interval
for i = 1:Nf+1
    % Plot bound
    plot([t(1),t(end)], fBounds(i)*[1,1], "--", "LineWidth", 1.5, "Color", Inputs.TextColor);

    % Plot name of interval except for last iteration which just closes the
    % final interval bounds. The text alignment is decided by function
    % inputs.
    if (i <= Nf)
        fText = clip(fBounds(i), min(f), max(f)) / 1.05;
        if (Inputs.TextAlignment == "left")
            r = 0.01;
        elseif (Inputs.TextAlignment == "right")
            r = 0.99;
        end
        text(r*t(end), fText, ...
            fNames(i), ...
            "HorizontalAlignment", Inputs.TextAlignment, "VerticalAlignment", "top", ...
            "FontSize", 10, "Color", Inputs.TextColor, "FontWeight", "bold");
    end
end

% Finilize by setting limits, scales, labels etc.
CB = colorbar("Location", "westoutside", "TickLength", 0.003);
ylabel(CB, "Power [-]");

xlim([t(1),t(end)]);
ylim([f(end), f(1)]);

Ax.YScale = "log";
Ax.YDir = "normal";
box on;

ylabel("Frequency [Hz]");

end

% Helper function, clip value between two limits
function Y = clip(X,L,U)
Y = min(U,max(L,X));
end