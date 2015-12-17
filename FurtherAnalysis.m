function [] =                  FurtherAnalysis(dataConsolidationOutput)
%  this function uses the output from the  ConsolidateMatFiles function. 
% The time series for each ROI can be filtered by the user according to the
% name or descriptive variables for that file. User defined descriptive 
% variables are then used to output a number of plots and descriptive statistics
% Parameters for the output can be defined by the user.
% If the final choice for descriptive variables (fieldsStruct.groupsToCompare)
% has just two values (that correspond to two measurements within a fly) additional output is  generated specifically for paired data (using the pairedImagingData structure).
userChoiceToTerminate = 0;
[userFolder,userInput,analysisArgs,fieldsStruct,userChoiceToTerminate] = SetupForFurtherAnalysisWithUserInput;
if userChoiceToTerminate
    return
end

% calculating variables describing curves
[userInput] = GetTimeSeriesInformation(userInput,analysisArgs);
[userInput,pairedImagingData] = FilterDataAccordingToDataset(userInput,userFolder);
if isempty(pairedImagingData)
    [ pairedImagingData] = GetPairedImagingData(userInput, fieldsStruct);
end
CycleThroughUserDefinedGroupsForPlotting(userInput,pairedImagingData,fieldsStruct,analysisArgs);

WriteOutputToCSV(userInput);
end
