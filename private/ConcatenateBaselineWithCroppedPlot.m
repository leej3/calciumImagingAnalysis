function userInput = ConcatenateBaselineWithCroppedPlot(userInput)
userInput = ExtendBaselinesWhereNecessary(userInput);
timeInterval = userInput(1).tCroppedPlot(2);


for userInputElement = 1:length(userInput)
userInput(userInputElement).croppedPlot = [userInput(userInputElement).baselinePlot ; userInput(userInputElement).croppedPlot]; 
userInput(userInputElement).tCroppedPlot = [timeInterval*(-6:-1) userInput(userInputElement).tCroppedPlot];
end


function userInput = ExtendBaselinesWhereNecessary(userInput)
[baselines, indicesOfElementsPresent] = padcat(userInput.baselinePlot);
columnsWithTooFewVals = find(~indicesOfElementsPresent(6,:));
for ii =  1:length(columnsWithTooFewVals)
   missingValsInColumn = find(~indicesOfElementsPresent(:,columnsWithTooFewVals(ii)) );
   baselines(missingValsInColumn,  columnsWithTooFewVals(ii))  = baselines(missingValsInColumn(1)-1,  columnsWithTooFewVals(ii)) ; 
end
for jj = 1:size(baselines,2)
userInput(jj).baselinePlot = baselines(:,jj);
end