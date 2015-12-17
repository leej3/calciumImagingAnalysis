function [fullDataSet] = GetTimeSeriesInformation(fullDataSet,analysisArgs)
% returns croppedPlot, tCroppedPlot, outputPlotValues, meanBaselineVal, baselinePlot, curveLengthBeforeProcessing, areaUnderCurve, negativeCurveArea
disp('Processing curves... this may take a few seconds')
CheckDataSamplingIsAtTheSameFrequency(fullDataSet)
onsetChoices = GetOnsetChoices;
fullDataSet = GetBaselineAndCroppedPlot(fullDataSet, analysisArgs, onsetChoices);
fullDataSet = CalculateOutputPlotValues(fullDataSet,analysisArgs);
[fullDataSet]  = GetVariablesDescribingOutputPlotValues(fullDataSet  , analysisArgs);
end



function [fullDataSet] =   GetBaselineAndCroppedPlot(fullDataSet, analysisArgs, onsetChoices)
for ii = 1:length(fullDataSet)
    fullDataSet(ii) =                      GetBaselineAndCroppedPlotForThisROI(fullDataSet(ii),analysisArgs,onsetChoices);
end
fullDataSet = ConcatenateBaselineWithCroppedPlot(fullDataSet);
end
function fullDataSet = ConcatenateBaselineWithCroppedPlot(fullDataSet)
fullDataSet = ExtendBaselinesWhereNecessary(fullDataSet);
timeInterval = fullDataSet(1).tCroppedPlot(2);
numberOfSlicesForBaseline = GetNumberOfSlicesForBaseline(timeInterval);
numberOfSlicesForCroppedBaseline = numberOfSlicesForBaseline -1;

for userInputElement = 1:length(fullDataSet)
    fullDataSet(userInputElement).croppedPlot = [fullDataSet(userInputElement).baselinePlot(1:numberOfSlicesForCroppedBaseline) ; fullDataSet(userInputElement).croppedPlot];
%     necessary flip for older datasets
    fullDataSet(userInputElement).tCroppedPlot = reshape(fullDataSet(userInputElement).tCroppedPlot,1, length(fullDataSet(userInputElement).tCroppedPlot));
    fullDataSet(userInputElement).tCroppedPlot = [timeInterval*(-numberOfSlicesForCroppedBaseline:-1) fullDataSet(userInputElement).tCroppedPlot];
end
end
function fullDataSet = ExtendBaselinesWhereNecessary(fullDataSet)
timeInterval = fullDataSet(1).timeVec(2)-fullDataSet(1).timeVec(1);
numberOfSlicesForBaseline = GetNumberOfSlicesForBaseline(timeInterval);
indicesOfElementsWithBaselinesThatAreTooShort = find(cellfun(@(x) length(x)<numberOfSlicesForBaseline, {fullDataSet.baselinePlot}));

if ~isempty(indicesOfElementsWithBaselinesThatAreTooShort)
for ii = 1:length(indicesOfElementsWithBaselinesThatAreTooShort)
    while length(fullDataSet(indicesOfElementsWithBaselinesThatAreTooShort(ii)).baselinePlot)<numberOfSlicesForBaseline
        fullDataSet(indicesOfElementsWithBaselinesThatAreTooShort(ii)).baselinePlot = [fullDataSet(indicesOfElementsWithBaselinesThatAreTooShort(ii)).baselinePlot(1); fullDataSet(indicesOfElementsWithBaselinesThatAreTooShort(ii)).baselinePlot];
    end
end
end
end

function [glomStructure] =                      GetBaselineAndCroppedPlotForThisROI(glomStructure , analysisArgs,onsetChoices)
timeInterval = glomStructure.timeVec(2)-glomStructure.timeVec(1);
onsetVarSliceNumber = GetOnsetVarSliceNumber(glomStructure, analysisArgs, onsetChoices, timeInterval);

           %  background subtraction can be used by changing this value to 1. Such subtraction is implemented in Jayaraman, V. (2007) ‘Evaluating a genetically encoded optical sensor of neural activity using electrophysiology in intact adult fruit flies’
 if analysisArgs.subtractBackgroundFromPlotValues
    glomStructure.plot = glomStructure.plot - glomStructure.meanBackGround;
end
%%
[glomStructure] = GetBaseline(glomStructure , onsetVarSliceNumber); %Getting the baseline(value and plot):
[glomStructure] = GetTimeMatrixAndPartOfCurveDefinedByUserToBeAnalysed(glomStructure,analysisArgs,onsetVarSliceNumber);
end

function [glomStructure] =                      GetBaseline(glomStructure, onsetVarSliceNumber)
plotVals=glomStructure.plot;
timeInterval = glomStructure.timeVec(2)-glomStructure.timeVec(1);
numberOfSlicesForBaseline = GetNumberOfSlicesForBaseline(timeInterval);
% the baseline is subsequently concatenated with the main time-series. the
% index "onsetVarSliceNumber" is used in both. it is removed from the
% baseline values in the process of the concatenation.
    if onsetVarSliceNumber < numberOfSlicesForBaseline
        glomStructure.baselinePlot = plotVals(1:onsetVarSliceNumber);
        glomStructure.meanBaselineValue = mean(glomStructure.baselinePlot);
    else
glomStructure.baselinePlot = plotVals(onsetVarSliceNumber-(numberOfSlicesForBaseline-1):onsetVarSliceNumber);
glomStructure.meanBaselineValue = mean(glomStructure.baselinePlot);
    end
end

function [glomStructure] = GetTimeMatrixAndPartOfCurveDefinedByUserToBeAnalysed...
(glomStructure, analysisArgs, onsetVarSliceNumber)
plotVals=glomStructure.plot;
timeInterval = glomStructure.timeVec(2)-glomStructure.timeVec(1);
glomStructure.curveLengthBeforeProcessing = (length(plotVals(onsetVarSliceNumber:end))-1)*timeInterval;
lengthOfCurve = ceil(analysisArgs.lengthOfCurveAnalysis/timeInterval);
if lengthOfCurve  > length(plotVals(onsetVarSliceNumber:end)) % curve not long enough
    glomStructure.croppedPlot = plotVals(onsetVarSliceNumber : end);
    glomStructure.tCroppedPlot = (0:timeInterval:(length(glomStructure.croppedPlot)-1)*timeInterval);
else %relevant part of the curve taken
    glomStructure.croppedPlot = plotVals(onsetVarSliceNumber : onsetVarSliceNumber+ (lengthOfCurve));
    glomStructure.tCroppedPlot = 0:timeInterval:(length(glomStructure.croppedPlot)-1)*timeInterval;
    %     figure, plot(glomStructure.tCroppedPlot,glomStructure.croppedPlot,'--rs')%,hold on, plot(glomStructure.)
end
[glomStructure] = GetExtrapolatedTimeAndCurveMatrixIfNecessary...
    (glomStructure,analysisArgs);

if isempty(glomStructure.tCroppedPlot)
    error()
end
end

function [onsetVarSliceNumber] = GetOnsetVarSliceNumber(glomStructure, analysisArgs, onsetChoices, timeInterval)
if analysisArgs.triggerUsed
    onsetVarSliceNumber = floor(analysisArgs.timeOfStimulus/timeInterval);
elseif   ~isempty(onsetChoices) && sum(strcmp(onsetChoices(:,1), glomStructure.fileName))
        onsetVarSliceNumber = onsetChoices{strcmp(onsetChoices(:,1), glomStructure.fileName),2};
else
    disp('Onset choice not detected. Either set Trigger used = 1 or the files must be reconsolidated as such and onset times must be chosen manually')
    errordlg('See command line, most likely cause of error is that stimulus onset was not manually chosen during file consolidation')
    error('Time series onset not detected. See command line')
end
end

function [] =  CheckDataSamplingIsAtTheSameFrequency(fullDataSet)
% unique does not give 1 value for timeInterval because the time intervals
% are slightly different (on the order of nanoseconds apparently)
timeIntervals = cellfun(@(x) x(2),{fullDataSet.timeVec});
maximumDifferenceBetweenTimeIntervals = max(abs(diff(timeIntervals)));
if maximumDifferenceBetweenTimeIntervals>0.005% 5ms
    error('the time series have different time intervals. should not have occurred as time series are resampled if necessary during file consolidation in the ConsolidateMatFiles function.')
end
end

function [numberOfSlicesForBaseline] = GetNumberOfSlicesForBaseline(timeInterval)
numberOfSlicesForBaseline = ceil(2/timeInterval);
end
