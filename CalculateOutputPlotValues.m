function fullDataSet = CalculateOutputPlotValues(fullDataSet,analysisArgs)
fluorescentTimeSeries = [fullDataSet.croppedPlot];
baselineValues = [fullDataSet.meanBaselineValue];

switch analysisArgs.plotType
    case 1 % F(t) , the raw fluorescent values
        % croppedPlot field already contains this value
        vals = fluorescentTimeSeries;
    case 2 % DF(t) , F(t) with the mean baseline value subtracted
        vals = bsxfun(@minus, fluorescentTimeSeries,baselineValues);
    case 3 %The %DF(t)/F(0) , 100X( DF(t) divided by the mean baseline value)
        vals = 100* bsxfun(@rdivide, bsxfun(@minus, fluorescentTimeSeries,baselineValues) , baselineValues);
end
vals = vals';
vals = cellfun(@(x) x' , mat2cell(vals,ones(size(vals,1),1)),'UniformOutput',0);
[fullDataSet(:).outputPlotVals] = vals{:};
