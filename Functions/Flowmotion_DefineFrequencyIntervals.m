function [fBounds, fNames] = Flowmotion_DefineFrequencyIntervals()
% Flowmotion_DefineFrequencyIntervals is a utility function that defines
% the frequency intervals in which flowmotion should be computed. The other
% functions in the Flowmotion library relies on this as the sole definition
% of these bounds, making it easy to change the definitions as necessary.
% 
% Outputs:
%   fBounds - Boundaries of the flowmotion frequency intervals
%   fNames  - Corresponding names of the frequency intervals

fBounds = [1.6, 0.4, 0.15, 0.06, 0.02, 0.0095];
fNames = ["Cardiac", "Respiratory", "Myogenic", "Neurogenic", "Endothelial"];

end

