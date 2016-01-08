function [] = summaryBoxPlots(userInputSubset, fieldsStruct, analysisArgs)
%%
outputValueToUse = [];
while 1
[outputValueToUse] = GetMeasureToUseForPlot(analysisArgs);
if strcmp(outputValueToUse,'End summary plot analysis')
    break
end
userDefinedYLims = GetYlims(analysisArgs);

[indicesForFirstCyclingVariable, labelsForFirstCyclingVariable] = grp2idx([userInputSubset.(fieldsStruct.fieldForCycling2)]);
[indicesForSecondCyclingVariable, labelsForSecondCyclingVariable] = grp2idx([userInputSubset.(fieldsStruct.fieldForCycling)]);
% [indicesForVariableForComparison, labelsForVariableForComparison] = grp2idx([userInputSubset.(fieldsStruct.fieldToCompare)]);

for ii = 1:length(labelsForFirstCyclingVariable)
    for jj = 1:length(labelsForSecondCyclingVariable)
indicesForThisFigure = indicesForFirstCyclingVariable==ii & indicesForSecondCyclingVariable==jj;
if ~sum(indicesForThisFigure)
    disp(['No values for ' fieldsStruct.fieldForCycling2 ': ' labelsForFirstCyclingVariable{ii} ', ' fieldsStruct.fieldForCycling ': ' labelsForSecondCyclingVariable{jj}])
    continue
end
subStructForThisFigure = userInputSubset(indicesForThisFigure);
figure
[groups, groupsLabels] = grp2idx([subStructForThisFigure.(fieldsStruct.fieldToCompare)]);
[vectorForAllGroups] = [subStructForThisFigure.(outputValueToUse)]';
notBoxPlot(vectorForAllGroups',groups,0.6)
grid('on')

xlabel(['Groups: ' fieldsStruct.fieldToCompare])
 set(gca, 'xtick',[1:length(groupsLabels)], 'xticklabel',groupsLabels);

AddYLabelToSummaryPlot(analysisArgs, outputValueToUse)
if analysisArgs.summaryPlotYlimManual


automaticYlims = get(gca,'YLim');
if ~isempty(userDefinedYLims) && ~(automaticYlims(1)<userDefinedYLims(1))  && ~(automaticYlims(2)>userDefinedYLims(2))
    ylim(gca, userDefinedYLims)
else
    disp(['Inappropriate limits set for plot, ignoring: ' labelsForFirstCyclingVariable{ii} ', ' labelsForSecondCyclingVariable{jj} ])
end
end
% ylabel({'Change in AUC (0-5s)'},'FontSize',15)

title([ fieldsStruct.fieldForCycling2 ': ' labelsForFirstCyclingVariable{ii} ', ' fieldsStruct.fieldForCycling ': ' labelsForSecondCyclingVariable{jj}])
%% Save Figures
saveFigures = 0;
if saveFigures
    figure(boxplotFig)
    saveDir =  '/Users/johnlee/Documents/Thesis/Thesis/images/sthsetup/firstexposure/summaryFigs/boxplots/';


    if subplotFig
        figSize = 7
        saveName = ['mergedSummaryBoxPlotYlabelEdit']
    else
    figSize = 5;
    saveLabel = higherLevelGroupsForCycling{higherCyclingFieldElement}; saveLabel(regexp(saveLabel,'[> _]'))=[];
    saveName = ['notBoxPlot' saveLabel];
    end
    SaveFigure(saveName,saveDir,figSize)
end
end
saveFigures = 0;
end
if analysisArgs.useDefaultOutputValueForSummaryPlot==1
   break
end
end
end

function [outputValueToUse] = GetMeasureToUseForPlot(analysisArgs)
if analysisArgs.useDefaultOutputValueForSummaryPlot==1
    outputValueToUse = 'areaUnderCurve';
    return
end
potentialValuesToUse = {
    'meanBackGround'
    'meanBaselineValue'
    'negativeCurveArea'
    'areaUnderCurve'
    'End summary plot analysis'
        };
    userChoice = menu('Output for jittered plot:',potentialValuesToUse);
    outputValueToUse = potentialValuesToUse{userChoice};


end

function AddYLabelToSummaryPlot(analysisArgs, outputValueToUse)
% plot type defined in SetupForFurtherAnalysisWithUserInput
outputValueLabel = GetOutputValueLabel(analysisArgs);
 ylabel({outputValueToUse, outputValueLabel})
 labelHandle =  ylabel({ outputValueToUse, ['Integration of ' outputValueLabel] },'interpreter', 'latex', 'FontSize',13, 'Rotation', 90);

set(labelHandle,'Units','centimeters')
% pos = get(labelHandle,'Position');
% pos(1) = pos(1) - 0.5;
% set(labelHandle,'Position', pos)
end

function userDefinedYLims = GetYlims(analysisArgs)
if analysisArgs.summaryPlotYlimManual
    userDefinedYLims = inputdlg('Enter the Y-limits for the summary plots separated by commas');
eval(['userDefinedYLims = [' userDefinedYLims{1} '];'])
if isempty(userDefinedYLims)
    return
end
if userDefinedYLims(1)>userDefinedYLims(2)
    userDefinedYLims = [userDefinedYLims(2) , userDefinedYLims(1)];
end
else
    userDefinedYLims = [];
end
end
