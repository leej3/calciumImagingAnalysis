function [userInput,pairedImagingData] = FilterDataAccordingToDataset(userInput,userFolder)
% for dataset specific filtering of data points...
pairedImagingData = [];
if strcmp(userFolder,'/Volumes/Waxwing/LargeDatasets/CalciumImagingData/Synapsin testEB 15EBexp IPA MatFiles/')
    [userInput,pairedImagingData] = MergeSubRuns(userInput);
    matFileNames = cellfun(@GetMatFileName, {userInput.fileName},'UniformOutput',false) ;
    filesToDelete = FilterSynapsinData(matFileNames);
    userInput(filesToDelete) = [];
end

if strcmp(userFolder,'/Volumes/Waxwing/LargeDatasets/CalciumImagingData/EBtest EB15exp MatFiles')
[userInput,pairedImagingData] = MergeSubRuns(userInput);
end
if strcmp(userFolder , '/Volumes/Waxwing/LargeDatasets/CalciumImagingData/All matlab files concentration data MatFiles/')
userInput =   FilterUserInputAccordingToGlomConcPairingInConcentrationDataset(userInput);
end