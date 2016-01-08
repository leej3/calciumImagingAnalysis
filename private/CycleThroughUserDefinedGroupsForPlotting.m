function [] =                                   CycleThroughUserDefinedGroupsForPlotting(userInputSubset,pairedImagingData, fieldsStruct, analysisArgs)
% global matFolder;global figFolder;
disp(fieldsStruct)
PlotCurvesForEachGroupDefinedInFieldsStruct(userInputSubset, fieldsStruct, analysisArgs)
PlotShadedFigure(userInputSubset, fieldsStruct, analysisArgs)
if ~isempty(pairedImagingData)
    summaryBoxPlotsPaired( pairedImagingData, fieldsStruct, analysisArgs)
ImagingStats(pairedImagingData, fieldsStruct, analysisArgs)
else
    disp('no paired data... summary plot for unpaired data...')
end
    summaryBoxPlots(userInputSubset, fieldsStruct, analysisArgs)
end

