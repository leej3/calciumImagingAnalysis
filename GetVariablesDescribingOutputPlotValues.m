function [fullDataSet]=                       GetVariablesDescribingOutputPlotValues(fullDataSet  , analysisArgs)

disp(['Finding area under the curve for ' num2str(analysisArgs.startForIntegration)  'to' num2str(analysisArgs.endForIntegration)  'seconds'])
for ii = 1: length(fullDataSet)
[interpedTime,interpedCurve] = GetInterpolatedTimeAndCurveOverUserDefinedRange(fullDataSet(ii),analysisArgs);
fullDataSet(ii) = GetPerSecondAreaWhenCurveIsNegativeOverTheRangeOfIntegration(fullDataSet(ii), interpedTime, interpedCurve);
fullDataSet(ii) = GetAreaUnderCurveForRangeDefinedByUser(fullDataSet(ii),interpedTime, interpedCurve);
 % [fullDataSet(ii)]= GetPeakAndFallingPhaseVariables(analysisArgs,fullDataSet(ii),interpedCurve,interpedTime);
end
disp('Done')
end


function [interpedTime,interpedCurve] = GetInterpolatedTimeAndCurveOverUserDefinedRange(glomStructure,analysisArgs)
interpedCurve = interp(glomStructure.outputPlotVals, analysisArgs.degreeOfInterpolation);
interpedTime = interp(glomStructure.tCroppedPlot , analysisArgs.degreeOfInterpolation);
indicesOfCurveForIntegration = interpedTime>analysisArgs.startForIntegration & interpedTime<analysisArgs.endForIntegration;
interpedCurve = interpedCurve(indicesOfCurveForIntegration);
interpedTime = interpedTime(indicesOfCurveForIntegration);
end

function [glomStructure] = GetPerSecondAreaWhenCurveIsNegativeOverTheRangeOfIntegration(glomStructure, interpedTime, interpedCurve)
if length(interpedCurve(interpedCurve<0)) >1
    totalNegativeCurveArea = abs(trapz(interpedTime(interpedCurve<0),interpedCurve(interpedCurve<0)));
    glomStructure.negativeCurveArea = totalNegativeCurveArea/(interpedTime(end)-interpedTime(1));
else
    glomStructure.negativeCurveArea = 0;
end
% interpedCurve(interpedCurve<0)=0; %to avoid confusion regarding positive and negative area cancelling each other out.
end

function [glomStructure] = GetAreaUnderCurveForRangeDefinedByUser(glomStructure,interpedTime, interpedCurve)
 totalAreaUnderCurve = trapz(interpedTime,interpedCurve);
 glomStructure.areaUnderCurve = totalAreaUnderCurve/(interpedTime(end)-interpedTime(1));
end

function [glomStructure]=                       GetPeakAndFallingPhaseVariables...
    (glomStructure,analysisArgs,onsetVarSliceNumber, interpedCurve,interpedTime)
% function does not work. would need to be rewritten somewhat
% not used. to get these variables they must be initialised in the InitialiseAdditionalFieldNames function in SetupForFurtherAnalysisWithUserInput.m
% if analysisArgs.startForIntegration<=0 && analysisArgs.endForIntegration>=10
timeInterval = glomStructure.timeVec(2)-glomStructure.timeVec(1);
timeByWhichPeakShouldHaveOccurred = analysisArgs.timeOfStimulus + 10;
[~,indexForTimeByWhichPeakShouldOccur] = min(abs(round(interpedTime)-timeByWhichPeakShouldHaveOccurred));
[glomStructure.peakOfInterpedCurve,glomStructure.peakIndxOfInterpedCurve] = max(interpedCurve(1:indexForTimeByWhichPeakShouldOccur));
glomStructure.timeToPeak = interpedTime(glomStructure.peakIndxOfInterpedCurve);
glomStructure.timeTo90 = GetTimeForFluorescenceX(0.9, interpedTime, interpedCurve,glomStructure.peakIndxOfInterpedCurve);
glomStructure.timeTo66 = GetTimeForFluorescenceX(0.66, interpedTime, interpedCurve,glomStructure.peakIndxOfInterpedCurve);
glomStructure.timeTo33 = GetTimeForFluorescenceX(0.33, interpedTime, interpedCurve,glomStructure.peakIndxOfInterpedCurve);
glomStructure.falltime = glomStructure.timeTo66 - glomStructure.timeTo90;
end

function [timeIndex]=                           GetCurveTimeIndex(time,timeVec)
[~, timeIndex] = min(abs(timeVec - time));
end

function [timeForX] =                           GetTimeForFluorescenceX(X, interpedTime, interpedCurve,peakIndxOfInterpedCurve)
%  finding the value that is closest to X% of peak(in the falling phase, after peakIndxOfInterpedCurve).
timeForPeak = interpedTime(peakIndxOfInterpedCurve);
peakOfInterpedCurve=interpedCurve(peakIndxOfInterpedCurve);
fluorescenceX = peakOfInterpedCurve * X;
% the curve is rounded so that the first value that is quite close is used.
[~,indexInFallingPhaseForX] = min(abs(round(interpedCurve(peakIndxOfInterpedCurve:end))-fluorescenceX));
    indexForFluorescenceX = indexInFallingPhaseForX + peakIndxOfInterpedCurve;
    timeForX = interpedTime(indexForFluorescenceX);
end
