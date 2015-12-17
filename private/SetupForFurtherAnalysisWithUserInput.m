function [userFolder,userInputWithAddedFields,analysisArgs,fieldsStruct,userChoiceToTerminate] = SetupForFurtherAnalysisWithUserInput 
baseDir = cd;
[userFolder,userInputWithAddedFields,analysisArgs,fieldsStruct,userChoiceToTerminate,userChoiceForSetup,userInputRedefined,analysisParametersEdited] = deal(0);

[userFolder, userInput, fieldsStruct] = LoadPreviouslySavedSettings;


    while 1
      userChoiceForSetup=menu('Data loaded. Choose task',{
            'Change directory'
          'Reload data from default file in current directory'
          'Load data from file without default name'
          'Change the descriptive variables by which to filter the data'
          'Parameters for analysis'
          'Generate Output'
          });
    switch userChoiceForSetup
        case 1
            [userFolder] = uigetdir;
            cd(userFolder)
            [userFolder, userInput, fieldsStruct] = LoadPreviouslySavedSettings;
        case 2
            [userInput,userFolder] = LoadFluorescentTimeSeries;
            userInput = DefineSelectionForAnalysis(userFolder,userInput);
            [userInput, fieldsStruct] = DefineDescriptiveVariablesForAnalysis(userFolder,userInput);
            fieldStructEdited = 1;

        case 3
          disp('Must redefine data and descriptive variables when using alternative filename for consolidated data file')
          [userFolder, userInput] = LoadTimeSeriesWithUserInput;
          cd(userFolder), delete('filesForFurtherAnalysis.mat','fieldsStruct.mat')
          userInput = DefineSelectionForAnalysis(userFolder,userInput);
          [userInput,fieldsStruct] = DefineDescriptiveVariablesForAnalysis(userFolder,userInput);
          delete('filesForFurtherAnalysis.mat','fieldsStruct.mat')
          fieldStructEdited = 1;
        case 4
          [userInput,fieldsStruct] = DefineDescriptiveVariablesForAnalysis(userFolder,userInput);
          fieldStructEdited = 1;
        case 5
          [analysisArgs] = DefineAnalysisArgs(userFolder);
          analysisParametersEdited = 1;
        case 6
            break
            % while loop will be exited
        case 0
          userChoiceToTerminate =1;
          return
    end
    end



if ~analysisParametersEdited
  [analysisArgs] = LoadAnalysisArgs(userFolder);
end

% Sort files
mislabelledGloms =0;
if mislabelledGloms
[userInput] = SortDataByGlomerulusAndRelabelOldOnes(userInput);
else
    [~,permutationMat] = sort([userInput.glomerulus]);
    userInput = userInput(permutationMat);
end

userInputWithAddedFields = InitialiseAdditionalFieldNames(userInput);


end
%%
% [userInput,pairedImagingData] = FilterDataAccordingToDataset(userInput,userFolder);
% pairedImagingData is now created later if the groups to compare category has two entries
% listed (except in files containing subruns which is performed here. depracated functionality)...

function [userFolder, userInput, fieldsStruct] = LoadPreviouslySavedSettings
[userInput,userFolder] = LoadFluorescentTimeSeries;
[userInput] = LoadSelectionForAnalysis(userFolder,userInput);
[fieldsStruct] = LoadDescriptiveVariablesForAnalysis(userFolder);
if ~isempty(fieldsStruct)
userInput = RefineDataAccordingToEliminatedSubFields(fieldsStruct,userInput);
else
  [userInput, fieldsStruct] = DefineDescriptiveVariablesForAnalysis(userFolder,userInput);
end
    end

function [userInput] = LoadSelectionForAnalysis(userFolder,userInput)
cd(userFolder)
if exist('filesForFurtherAnalysis.mat','file')
    load('filesForFurtherAnalysis.mat')
end
if exist('outputElementNames','var')
    [~, iA] = intersect( GetOutputElementNames(userFolder, userInput),outputElementNames,'stable');
    userInput = userInput(iA);
else
    userInput = DefineSelectionForAnalysis(userFolder,userInput);
end
end

function [userDefinedOutput]=                   DefineSelectionForAnalysis(userFolder,userInput)
cd(userFolder)
[outputElementNames] = GetOutputElementNames(userFolder, userInput);
indicesForUIDefinedElements = listdlg('ListString',outputElementNames,'ListSize',[400 300]);
userDefinedOutput = userInput(indicesForUIDefinedElements);
outputElementNames = outputElementNames(indicesForUIDefinedElements);
save('filesForFurtherAnalysis.mat','outputElementNames')
end

function [outputElementNames] = GetOutputElementNames(userFolder, userInput)
matfileNames  = cellfun(@GetMatFileName,{userInput.fileName}','UniformOutput',0);
matfileNames =  cellfun(@(x) x(1:end-4),matfileNames,'UniformOutput',0);
roiNames = cellfun(@(x) [' ' x{1}],{userInput.names},'UniformOutput',0)';
if sum(~cellfun(@isempty , regexp(matfileNames,'atypical')))
    disp('some filenames do not use the correct format. see the DeltaF function...')
    outputElementNames = strcat(...
    cellfun(@(x) x(1:end-4),{userInput.fileName}','UniformOutput',0),...
    roiNames);
else
outputElementNames= strcat(matfileNames, roiNames);
end
end

function [userInput, userFolder] = LoadFluorescentTimeSeries
currentDirectory = cd;userInput = [];
    likelyMatFileName = [currentDirectory '.mat'];
    [~,b,c] = fileparts(likelyMatFileName);
    try
        load([b c]);
        userInput  = fullDataSet;
        CreatMatFileDirectoriesIfNecessary(currentDirectory)
        userFolder = currentDirectory;
    catch
      disp('Default filename not found')
    end
    if isempty(userInput)
      [userFolder, userInput] = LoadTimeSeriesWithUserInput
end
end

function [userFolder, userInput] = LoadTimeSeriesWithUserInput
[userDefinedAnalysisFile,userFolder] = uigetfile;
if userFolder==0
    error('no directory selected')
end
 CreatMatFileDirectoriesIfNecessary(userFolder)
load(userDefinedAnalysisFile);
userInput  = fullDataSet;
end


function [] = CreatMatFileDirectoriesIfNecessary(userFolder)
folderSeparatorVariable = filesep;
cd(userFolder)
if ~exist([userFolder folderSeparatorVariable 'MatFilesFromAnalysis'])
    mkdir('MatFilesFromAnalysis')
end

global matFolder
global figFolder
matFolder = [userFolder folderSeparatorVariable 'MatFilesFromAnalysis'];cd(matFolder);
if ~exist('Figs')
    mkdir('Figs')
end
figFolder = [matFolder folderSeparatorVariable 'Figs'];
cd(userFolder)
end

function [analysisArgs] = LoadAnalysisArgs(userFolder)
cd(userFolder)
if exist('analysisArgs.mat','file')
    load('analysisArgs.mat')
end
if ~exist('analysisArgs','var')
    analysisArgs = DefineAnalysisArgs(userFolder);
end
end
function [fieldsStruct] = LoadDescriptiveVariablesForAnalysis(userFolder);
fieldsStruct = struct([]);
cd(userFolder)
if exist('fieldsStruct.mat','file')
    load('fieldsStruct.mat')
end
end


function [analysisArgs] = DefineAnalysisArgs(userFolder)
cd(userFolder)
if exist('analysisArgs.mat','file')
    load('analysisArgs.mat')
else
    [analysisArgs] = GetDefaultAnalysisArgs;
end

dlg_title='Analysis arguements : ';
prompt={...
'Duration of curve'
'Degree of Interpolation'
'Extapolation (0 for NN, 1 for nan)'
'Start time for curve integration'
'End time for curve integration'
'Type of plot (1 =F(t), 2 =DF(t), 3 = %DF(t)/F(0))'
'Subtract background pixel intensity'
'Trigger used with stimulus'
'If trigger was used, time of stimulus (s)'
'Use default output measure for summary graphs'
'Set limits of the y-axis on summary graphs manually'
'Show descriptive statistics for paired data'
'Plot raw curves for each group of descriptive variables selected'
'Set limits of the y-axis graphs manually when plotting responses with SEMs'
};

answer=inputdlg(prompt,dlg_title,1,...
    {
    num2str(analysisArgs.lengthOfCurveAnalysis)
    num2str(analysisArgs.degreeOfInterpolation)
    num2str(analysisArgs.extrapolation)
    num2str(analysisArgs.startForIntegration)
    num2str(analysisArgs.endForIntegration)
    num2str(analysisArgs.plotType)
    num2str(analysisArgs.subtractBackgroundFromPlotValues)
    num2str(analysisArgs.triggerUsed)
    num2str(analysisArgs.timeOfStimulus)
    num2str(analysisArgs.useDefaultOutputValueForSummaryPlot)
    num2str(analysisArgs.summaryPlotYlimManual)
    num2str(analysisArgs.showDescriptiveStats)
    num2str(analysisArgs.plotRawCurves)
    num2str(analysisArgs.semCurvesYlimManual)
    });

analysisArgs.lengthOfCurveAnalysis = str2num(answer{1});
analysisArgs.degreeOfInterpolation = str2num(answer{2}); %this may throw up discrepancies in the data if its put too low
analysisArgs.extrapolation = str2num(answer{3});
analysisArgs.startForIntegration = str2num(answer{4});
analysisArgs.endForIntegration = str2num(answer{5});
analysisArgs.plotType = str2num(answer{6});
analysisArgs.subtractBackgroundFromPlotValues = str2num(answer{7});
analysisArgs.triggerUsed = str2num(answer{8});
analysisArgs.timeOfStimulus = str2num(answer{9});
analysisArgs.useDefaultOutputValueForSummaryPlot = str2num(answer{10});
analysisArgs.summaryPlotYlimManual = str2num(answer{11});
analysisArgs.showDescriptiveStats = str2num(answer{12});
analysisArgs.plotRawCurves = str2num(answer{13});
analysisArgs.semCurvesYlimManual = str2num(answer{14})

save('analysisArgs.mat','analysisArgs')
end

function [analysisArgs] = GetDefaultAnalysisArgs
analysisArgs.lengthOfCurveAnalysis = 30;
analysisArgs.degreeOfInterpolation = 100;
analysisArgs.extrapolation = 0;
analysisArgs.startForIntegration = 0;
analysisArgs.endForIntegration = 10;
analysisArgs.plotType = 2;
analysisArgs.subtractBackgroundFromPlotValues =0;
analysisArgs.triggerUsed = 1;
analysisArgs.timeOfStimulus = 8;
analysisArgs.useDefaultOutputValueForSummaryPlot = 0;
analysisArgs.summaryPlotYlimManual = 0;
analysisArgs.showDescriptiveStats = 1;
analysisArgs.plotRawCurves = 1;
analysisArgs.semCurvesYlimManual = 0;
end

function userInput = InitialiseAdditionalFieldNames(userInput)
fieldNamesThatAreAddedDuringAnalysis = {...
    'baselinePlot',...
    'meanBaselineValue',...
    'extrapolated',...
    'curveLengthBeforeProcessing',...
    'negativeCurveArea',...
    'areaUnderCurve',...
    'tCroppedPlot',...
    'croppedPlot',...
    'outputPlotVals'};
for ii = 1:length(fieldNamesThatAreAddedDuringAnalysis)
    [userInput.(fieldNamesThatAreAddedDuringAnalysis{ii})] = deal([]);
end
end

