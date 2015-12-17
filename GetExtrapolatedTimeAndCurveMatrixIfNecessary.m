function [glomStructure] = GetExtrapolatedTimeAndCurveMatrixIfNecessary...
    (glomStructure,analysisArgs)
% Adding on a string of values if the curve is too short compared to the
% standard length of curve analysis
timeVec=glomStructure.tCroppedPlot;
timeInterval = timeVec(2)-timeVec(1);
try
if timeVec(end) < analysisArgs.lengthOfCurveAnalysis

    timeVecExt = timeVec;
    while timeVecExt(end) < analysisArgs.lengthOfCurveAnalysis
        extraTimeVecElement = timeVecExt(end) + timeInterval;
        timeVecExt = [timeVecExt extraTimeVecElement];
    end
    if analysisArgs.extrapolation % 1 is nan, 0 is nearest neighbour
        additionalValuesRequired = length(timeVecExt) - length(glomStructure.croppedPlot);
        glomStructure.croppedPlot = [glomStructure.croppedPlot ; repmat(nan,additionalValuesRequired,1)];
    else
        glomStructure.croppedPlot = interp1(timeVec,glomStructure.croppedPlot,timeVecExt,'nearest','extrap');
    end
    glomStructure.extrapolated = {'Yes'};

    glomStructure.tCroppedPlot = reshape(timeVecExt,1,length(timeVecExt)); glomStructure.croppedPlot= reshape(glomStructure.croppedPlot,length(glomStructure.croppedPlot),1);
else
    glomStructure.extrapolated = {'No'};
end
catch
    keyboard
end
