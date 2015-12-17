function [] = WriteOutputToCSV(fullDataSet)
outputPlotValuesTransposed = cellfun(@(x) x', {fullDataSet.outputPlotVals},'UniformOutput',0);
[fullDataSet.outputPlotVals] = outputPlotValuesTransposed{:};
[fullDataSet.timeInterval] = deal(fullDataSet(1).timeVec(2)-fullDataSet(1).timeVec(1));
fullDataSet = rmfield(fullDataSet,{'timeVec','tCroppedPlot','croppedPlot','plot'});
outputAsTable = struct2table(fullDataSet);
writetable(outputAsTable,'dataFromMostRecentAnalysis.csv');
end
