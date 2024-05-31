function [XFit, optParams, gof] = Flowmotion_FitReperfusion(t,X)
% Flowmotion_FitReperfusion fits the model described in Ref 1 to the
% data X, and return the fit, optimal model parameters, and a summary of
% the fit performance.
% 
% Inputs:
%    t - Time vector
%    X - Data vector
%
% Outputs:
%    XFit      - Optimal model applied to the input time vector
%    OptParams - Optimal model paramters
%    GOF       - Goodness-of-fit struct returned from the fitting procedure
%
% Ref 1: [ Update when DOI available ]

% Save if X is a column or row
isRow = isrow(X);
X = X(:);
t = t(:);

% Zero-align time vector, necessary for the model to fit
t = t - t(1);

% Normalize the signal with its first sample point to enable a smaller
% search space in the fitting. Re-apply this scale factor to the fitted
% function.
X1 = X(1);
X = X / X1;

% Setup fit options
ft = fittype('a*exp(-(x/b)^c)+d', 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');
opts.Display = 'Off';
opts.Lower = [-10,   0,  0, -10];
opts.Upper = [ 10, 600,  4,  10];
opts.StartPoint = [0.1, 100, 1.5, 0.1];

% Fit model to data
[fitresult, gof] = fit(t, X, ft, opts);

% Re-apply scale factor
optParams = [fitresult.a, fitresult.b, fitresult.c, fitresult.d] .* [X1, 1, 1, X1];

% Use the optimal model parameters to compute the fitted model for the
% original time vector
fnc = @(x,p) p(1) * exp(-(x/p(2)).^p(3)) + p(4);
XFit = fnc(t,optParams);

% Transpose XFit if X was a row to match dimensiosns
if (isRow)
    XFit = XFit';
end

end

