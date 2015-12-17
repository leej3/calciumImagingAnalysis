function [onsetChoices] = GetOnsetChoices
if exist('onsetChoices.mat','file')
    load('onsetChoices.mat')
elseif exist('onsetChoice.mat','file')
    load('onsetChoice.mat')
    onsetChoices = onsetChoice;
else
   onsetChoices = {}; save('onsetChoices.mat','onsetChoices')
end
