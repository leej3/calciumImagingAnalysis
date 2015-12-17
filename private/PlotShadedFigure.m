function []   = PlotShadedFigure(userInput,fieldsStruct,analysisArgs)
colourMat = {'b','r','g','y','m','c','k','v','w','x','s','p','o'};
  xlims = [-2 (analysisArgs.lengthOfCurveAnalysis+5)];
userDefinedYLims = GetYlims(analysisArgs);

[indicesForFirstCyclingVariable, labelsForFirstCyclingVariable] = grp2idx([userInput.(fieldsStruct.fieldForCycling2)]);
[indicesForSecondCyclingVariable, labelsForSecondCyclingVariable] = grp2idx([userInput.(fieldsStruct.fieldForCycling)]);
[indicesForVariableForComparison, labelsForVariableForComparison] = grp2idx([userInput.(fieldsStruct.fieldToCompare)]);

for ii = 1: length(labelsForFirstCyclingVariable)
    figure
    figPos =[-6        1262         428         568];
    set(gcf, 'Position', figPos);
    ha = tight_subplot(length(labelsForSecondCyclingVariable),1,[0.02 0.12],[.06 0.07],[.14 0.02]);

    for jj = 1: length(labelsForSecondCyclingVariable)
        labelsForLegend = labelsForVariableForComparison;
        axes(ha(jj))
        shadedPlotElement = 1;clear h_shadedPlot
        for kk = 1:length(labelsForVariableForComparison)
            indicesForThisGroup = indicesForFirstCyclingVariable==ii & indicesForSecondCyclingVariable==jj & indicesForVariableForComparison==kk;
            plotValues =  horzcat(userInput(indicesForThisGroup).outputPlotVals)';
            if sum(indicesForThisGroup)>2
            % h_shadedPlot(shadedPlotElement) = shadedErrorBar(userInput(1).tCroppedPlot,plotValues,{@median,@mad},colourMat{shadedPlotElement},0);
            h_shadedPlot(shadedPlotElement) = shadedErrorBar(userInput(1).tCroppedPlot,plotValues,{@mean,@GetSEM},colourMat{shadedPlotElement},0);
            hold on
            shadedPlotElement = shadedPlotElement+1;
            labelsForLegend{strcmp(labelsForLegend,labelsForVariableForComparison{kk})} = [labelsForLegend{strcmp(labelsForLegend,labelsForVariableForComparison{kk})} ', n = ' num2str(sum(indicesForThisGroup))];
            else
                disp([labelsForFirstCyclingVariable{ii} ', ' labelsForSecondCyclingVariable{jj} ', '   labelsForVariableForComparison{kk} ' has an insufficient number of datapoints to plot'])
                labelsForLegend(strcmp(labelsForLegend,labelsForVariableForComparison{kk})) = [];
            end
        end
        if jj == 1
            h_title = title([ labelsForFirstCyclingVariable{ii} ': Comparing ' fieldsStruct.fieldToCompare ' for each ' fieldsStruct.fieldForCycling ],'interpreter','latex','FontSize',15);hold on
            % set(h_title,'Units','Normalized')
            % cpos = get(h_title,'Position');
            % cpos(1) = cpos(1) - 0.7;
            % cpos(2) = cpos(2) + 0.1;
            % set(h_title,'Position',cpos)
        end
        if ~isempty(labelsForLegend)
            h_legend = legend([h_shadedPlot.mainLine],labelsForLegend,'Location','NorthEast');

            set(h_legend,'EdgeColor',[1 1 1],'FontSize',10)
            % cpos = get(h_legend,'Position');
            % cpos(2)=cpos(2) + 0.07; % Move it outside the plot
            % cpos(1)=cpos(1); % Move it outside the plot
%             set(h_legend,'Position',cpos,'color','none')
        else
            disp(['no legend for' labelsForSecondCyclingVariable(jj)])

        end

        if exist('xlims','var')
            xlim(xlims)
        end
        automaticYlims = get(gca,'YLim');
        if analysisArgs.semCurvesYlimManual
            if ~isempty(userDefinedYLims) && ~(automaticYlims(1)<userDefinedYLims(1))  && ~(automaticYlims(2)>userDefinedYLims(2))
                ylims =  userDefinedYLims;
            else
                disp(['Inappropriate limits set for plot, ignoring: ' labelsForFirstCyclingVariable{ii} ', ' labelsForSecondCyclingVariable{jj} ])
                ylims = automaticYlims;
            end
        else
            ylims = automaticYlims;
        end
        if ylims(2)>60
            yvalForStim = ylims(2)-8;
        else
            yvalForStim = ylims(2);
        end
        set(gca,'ylim',ylims)
        plot(0:10,repmat(yvalForStim,11,1),'Color',[0.55 0.55 0.55],'LineWidth',6)
        AddPlotLabel(analysisArgs,labelsForSecondCyclingVariable,jj)
        if jj ~=length(ha)
            set(ha(jj), 'xtick',[])
        else
            xlabel('Time (s)')
            %                     set(ha(jj), 'xtick',[0 10 20], 'xticklabel',treatmentLabel,'Position',[currentSubplotPosition(1)+0.05 0.1 currentSubplotPosition(3) 0.8],'box','off');
        end
    end
end


%% Saving file
saveFigures = 0;
if saveFigures
    set(gcf,'Units','centimeters')
    set(gcf,'position',[0 0 16 20])
    saveName = ['osnsVeryLow2014SeptRawLabelsWRONG'];
    %             saveDir = ['/Users/johnlee/Documents/Thesis/Thesis/images/sthsetup/firstexposure/summaryFigs'];
    saveDir =  ['/Users/johnlee/Documents/Thesis/Thesis/images/olfactometerDesign/imagingOnSystem/'];

    figSize = 0;
    SaveFigure(saveName,saveDir,figSize)

end
saveFigures = 0;
end

function AddPlotLabel(analysisArgs,labelsForSecondCyclingVariable,jj)
% plot type defined in SetupForFurtherAnalysisWithUserInput
outputValueLabel = GetOutputValueLabel(analysisArgs);
labelHandle =  ylabel({ labelsForSecondCyclingVariable{jj}, outputValueLabel },'interpreter', 'latex', 'FontSize',11, 'Rotation', 0);

set(labelHandle,'Units','centimeters')
pos = get(labelHandle,'Position');
pos(1) = pos(1) - 0.5;
set(labelHandle,'Position', pos)
end

function userDefinedYLims = GetYlims(analysisArgs)
if analysisArgs.semCurvesYlimManual
    userDefinedYLims = inputdlg('Enter the Y-limits for the graph containing the mean and SEM of the time-series (separated by commas)');
    eval(['userDefinedYLims = [' userDefinedYLims{1} '];'])

    if ~isempty(userDefinedYLims) && userDefinedYLims(1)>userDefinedYLims(2)
        userDefinedYLims = [userDefinedYLims(2) , userDefinedYLims(1)];
    end
else
    userDefinedYLims = [];
end
end

function [semVals] = GetSEM(inputMat)
    % Each row of inputMat is a time-series
    semVals = std(inputMat,0,1)/sqrt(size(inputMat,1));
end
