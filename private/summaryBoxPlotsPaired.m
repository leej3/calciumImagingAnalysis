function [] = summaryBoxPlotsPaired(pairedImagingData, fieldsStruct, analysisArgs)
%%
if isempty(pairedImagingData)
    errordlg('Groups to compare must only have 2 levels for the paired analysis of the summary boxplot')
end
outputValueToUse = [];
while 1
[outputValueToUse] = GetMeasureToUseForPlot(analysisArgs);
if strcmp(outputValueToUse,'End summary plot analysis')
    break
end
userDefinedYLims = GetYlims(analysisArgs);

higherLevelGroupsForCycling = unique([pairedImagingData.(fieldsStruct.fieldForCycling2)]);


for ii = 1:length(higherLevelGroupsForCycling)
figure
higherCyclingSubset = pairedImagingData(strcmp([pairedImagingData.(fieldsStruct.fieldForCycling2)],higherLevelGroupsForCycling{ii}));
[groups, groupsLabels] = grp2idx([higherCyclingSubset.(fieldsStruct.fieldForCycling)]);
[vectorForAllGroups] = [higherCyclingSubset.(outputValueToUse)]';

if 1
    notBoxPlot(vectorForAllGroups',groups,0.6)
    grid('on')
else
    [meanMatrix, semMatrix] = grpstats(vectorForAllGroups, groups,{'mean', @GetSEM})
    barPlot=bar(unique(groups),meanMatrix,'w','LineWidth',1);
    hold on
    errorbar(unique(groups), meanMatrix, semMatrix,'kx');
end

xlabel(['Groups: ' fieldsStruct.fieldForCycling])
 set(gca, 'xtick',[1:length(groupsLabels)], 'xticklabel',groupsLabels);

AddYLabelToSummaryPlot(analysisArgs, outputValueToUse)
%   ,'Interpreter','LaTex','FontSize',12);

if analysisArgs.summaryPlotYlimManual
automaticYlims = get(gca,'YLim');
if ~isempty(userDefinedYLims) && ~(automaticYlims(1)<userDefinedYLims(1))  && ~(automaticYlims(2)>userDefinedYLims(2))
    ylim(gca, userDefinedYLims)
else
    disp(['Inappropriate limits set for plot, ignoring: ' higherLevelGroupsForCycling{ii} ', '  outputValueToUse])
end
end

% ylabel({'Change in AUC (0-5s)'},'FontSize',15)

title([ fieldsStruct.fieldForCycling2 ': ' higherLevelGroupsForCycling{ii}])

end
%         title('$$\textbf{B}$$','interpreter','latex')
%         title([datasetLabel  neuronClassLabels{neuronClassElement}])

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
    saveLabel = higherLevelGroupsForCycling{ii}; saveLabel(regexp(saveLabel,'[> _]'))=[];
    saveName = ['notBoxPlot' saveLabel];
    end
    SaveFigure(saveName,saveDir,figSize)

end
saveFigures = 0;
if analysisArgs.useDefaultOutputValueForSummaryPlot==1
   break
end
end
end

function [outputValueToUse] = GetMeasureToUseForPlot(analysisArgs)
if analysisArgs.useDefaultOutputValueForSummaryPlot==1
    outputValueToUse = 'areaUnderCurveChange';
    return
end
potentialValuesToUse = {
    'meanBackGround'
    'meanBackGroundPost'
    'meanBackGroundChange'
    'meanBackGroundPercentChange'
    'meanBaselineValue'
    'meanBaselineValuePost'
    'meanBaselineValueChange'
    'meanBaselineValuePercentChange'
    'negativeCurveArea'
    'negativeCurveAreaPost'
    'negativeCurveAreaChange'
    'negativeCurveAreaPercentChange'
    'areaUnderCurve'
    'areaUnderCurvePost'
    'areaUnderCurveChange'
    'areaUnderCurvePercentChange'
    'End summary plot analysis'
        };
    userChoice = menu('Choose a measure to output',potentialValuesToUse);
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
    userDefinedYLims = inputdlg('Enter the Y-limits for the paired summary plots separated by commas');
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
