function PlotCurvesForEachGroupDefinedInFieldsStruct(userInputSubset, fieldsStruct, analysisArgs)
%% Plot Curves
if ~analysisArgs.plotRawCurves
    return
end
colourList= repmat({'blue','red','green','cyan','magenta','yellow','black'},1,10);
% useYlims=1;ylimits = [-100 500];
[indicesForFirstCyclingVariable, labelsForFirstCyclingVariable] = grp2idx([userInputSubset.(fieldsStruct.fieldForCycling2)]);
[indicesForSecondCyclingVariable, labelsForSecondCyclingVariable] = grp2idx([userInputSubset.(fieldsStruct.fieldForCycling)]);
[indicesForVariableForComparison, labelsForVariableForComparison] = grp2idx([userInputSubset.(fieldsStruct.fieldToCompare)]);

for ii =1:length(labelsForFirstCyclingVariable)
    for jj= 1:length(labelsForSecondCyclingVariable)
        %%
        figure, legendList = {}; hold on
        for kk = 1:length(labelsForVariableForComparison)
            els = indicesForFirstCyclingVariable==ii...
            & indicesForSecondCyclingVariable==jj...
            & indicesForVariableForComparison==kk;
       if sum(els)
            plot(userInputSubset(1).tCroppedPlot, [userInputSubset(els).outputPlotVals],colourList{kk})
            title([labelsForFirstCyclingVariable{ii} ', ' labelsForSecondCyclingVariable{jj} ', Comparing: ' fieldsStruct.fieldToCompare] )
            dataPointLabels = cellfun(@strjoin, ...
                                      strcat({userInputSubset(els).fly},...
                                             {userInputSubset(els).run},...
                                             {userInputSubset(els).(fieldsStruct.fieldToCompare)}),'UniformOutput',0); 
            legendList = [legendList dataPointLabels];
        end
        end
        if exist('useYlims','var')
           ylims(ylimits); 
        end
        try
        legend(legendList,'Location','EastOutside')
        catch
        end
%%
    end
end
end