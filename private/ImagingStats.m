function [] = ImagingStats(pairedImagingData,fieldsStruct,analysisArgs)
if isempty(pairedImagingData)
    errordlg('Groups to compare must only have 2 levels for the paired analysis of the summary boxplot')
end
myPairedData = ExtractPairedImagingDataset(pairedImagingData);

% baseline effect on the percent change in evoked fluorescence:
% figure,gscatter([pairedImagingData.meanBaselineValuePercentChange]',[pairedImagingData.areaUnderCurve5PercentChange]',[pairedImagingData.glomerulus]','brgmck','',[30]),grid on,xlabel('Percent change in baseline fluorescence'),ylabel('Percent Change in Evoked Response')

% PlotGscatter(myPairedData)
%% stats for imaging
groupingVariables =  {fieldsStruct.fieldForCycling2, fieldsStruct.fieldForCycling};
statisticsExtracted = {'mean','meanci',@AdTestConcatenatedWithCellReturn, @median,@iqr};
% myDataUnpairedForThisNeuron = myDataUnpaired(myDataUnpaired.class == neuronClasses(neuronClassElement),:);

% values to analyseForEach neuron
    valuesToExtractForNeuron = {
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
        };
    try
neuronStats = grpstats(myPairedData,groupingVariables,statisticsExtracted,'DataVars',valuesToExtractForNeuron);
if analysisArgs.showDescriptiveStats
    disp(neuronStats)
end

    catch
        disp('failed to calculate statistics describing the groups')
        errordlg('could not calculate the statistics describing the different groups')
        return
    end


changeAsPercentOfNaive = GetChangeAsPercentOfNaive(myPairedData, groupingVariables);
[indicesForFirstCyclingVariable, labelsForFirstCyclingVariable] = grp2idx([pairedImagingData.(groupingVariables{1})]);
[indicesForSecondCyclingVariable, labelsForSecondCyclingVariable] = grp2idx([pairedImagingData.(groupingVariables{2})]);

for ii = 1:length(labelsForFirstCyclingVariable)
    disp(['Cycling through ' groupingVariables{1} ' : ' labelsForFirstCyclingVariable{ii}])
for jj = 1:length(labelsForSecondCyclingVariable)
  if sum(indicesForFirstCyclingVariable==ii&indicesForSecondCyclingVariable==jj)
    disp(['Cycling through: ' groupingVariables{2} ' : ' labelsForSecondCyclingVariable{jj}])
%     [~,p(jj),ci(:,jj),tstats(:,jj)] = ttest(myPairedData(indicesForFirstCyclingVariable==jj& indicesForSecondCyclingVariable == jj,:).(valuesToExtractForNeuron{kk}));
[~,p(jj),ci(:,jj),tstats(:,jj)] = ttest(myPairedData(indicesForFirstCyclingVariable==ii& indicesForSecondCyclingVariable == jj,:).('areaUnderCurveChange'));
  end
end
disp(['p values: ' ]),disp(p)
disp(['CI of difference: ' ]),disp(ci)
disp(['Changes as a percent of naive: ']), disp( changeAsPercentOfNaive{ii})
disp(tstats)

end
     
    
    
    saveStats = 0
    if saveStats
StatsDatasetToLatexTable(neuronStats,saveName)
    
    statsDir = '/Users/johnlee/Documents/Thesis/Thesis/stats/';
saveDir = char(strcat(statsDir, 'imaging/' ));
saveName = ['pairedStatsFirstExpsosure'  ];
cd(saveDir)
    end

% keyboard
% [p,anovaTable,statsFromAnovan,terms] = anovan(myPairedData.averageRateOverInterval,{myPairedData.treatment},'varnames',{'Treatment group'},'model','full');
% % [comparisons] = multcompare(statsFromAnovan);
%
% %Type 3 sum of squares(default) is the reduction in residual sum of squares obtained by adding that term to a model containing all other terms, but with their effects constrained to obey the usual "sigma restrictions" that make models estimable.
% statsTestSaveName = [myDataUnpairedForThisNeuron.type{1} concLabel lower(neuronClassLabels{neuronClassElement}) 'averagerateoverinterval' 'statstesting.mat'];
% %  cd(statsTestsDir),save(statsTestSaveName,'anovaTable','comparisons')
% %%
% % [p,tableOutput,kruskalStats]  = kruskalwallis(myDataUnpairedForThisNeuron.averageRateOverInterval,myDataUnpairedForThisNeuron.treatment)
% %      [c,m]= multcompare(kruskalStats,'dimension',1)
%
%
% %% paired neuron stats
%
% pairedDataForThisNeuron = pairedData(pairedData.class == neuronClasses(neuronClassElement),:);
% if size(pairedDataForThisNeuron,1) > 3
% saveDir = char(strcat(statsDir, pairedDataForThisNeuron(1,:).type, concLabel  ,lower(neuronClassLabels{neuronClassElement}) , '/' ));
% cd(saveDir)
% pairedGroupingVariables = {'treatmentTypeOfPost'};
% valuesToExtractForNeuronPaired = strcat(repmat('Change',length(valuesToExtractForNeuron),1) , valuesToExtractForNeuron' );
% pairedNeuronStats = grpstats(pairedDataForThisNeuron,pairedGroupingVariables,statisticsExtracted,'DataVars',valuesToExtractForNeuronPaired);
% replacementString = ['AverageRateFrom' num2str(startOfInterval) 'to' num2str(endOfInterval) 's '];
% saveName = [pairedDataForThisNeuron.type{1} concLabel lower(neuronClassLabels{neuronClassElement}) 'paired' ];
% if loopDataSetElement >3
% pairedNeuronStats(:,'AdTestConcatenated_ChangeaverageSteadyStateRate') = [];
% pairedNeuronStats(:,'meanci_ChangeaverageSteadyStateRate') = [];
% pairedNeuronStats(:,'mean_ChangeaverageSteadyStateRate') = [];
% pairedNeuronStats(:,'median_ChangeaverageSteadyStateRate') = [];
% pairedNeuronStats(:,'iqr_ChangeaverageSteadyStateRate') = [];
%
% end
% pairedNeuronStats(:,'mean_ChangePeakRate') = [];
% pairedNeuronStats(:,'AdTestConcatenated_ChangePeakRate') = [];
% pairedNeuronStats(:,'meanci_ChangePeakRate') = [];
%
%
% % pairedTreatments = unique(pairedDataForThisNeuron.treatmentTypeOfPost);
% % t2 = table(pairedDataForThisNeuron.treatmentTypeOfPost, pairedDataForThisNeuron.averageRateOverInterval, pairedDataForThisNeuron.averageRateOverIntervalPost,'VariableNames',{'Treatment','pre','post'});
% % Meas = dataset([1:length(pairedTreatments)]','VarNames',{'Measurements'});
% % rm2 = fitrm(t2,'pre-post~Treatment','WithinDesign',Meas);
% % [ranovatbl2,a,c,d] = ranova(rm2)
%
%
%
%   ConvertStatsDatasetToLatexTableWithStrings(pairedNeuronStats,saveName ,replacementString)
% treatmentsOfPost =unique(pairedDataForThisNeuron.treatmentTypeOfPost);
% for ii = 1:length(treatmentsOfPost)
%     disp([saveName ': ' treatmentsOfPost{ii}] )
% [h,p,ci,tteststats] = ttest(pairedDataForThisNeuron(strcmp(pairedDataForThisNeuron.treatmentTypeOfPost,treatmentsOfPost{ii}),: ).ChangeaverageRateOverInterval)
% save([saveName  treatmentsOfPost{ii} 'ttestStats.mat'],'h','p','ci','tteststats')
% end
% end
% pairedDataAsTable = dataset2table(pairedData);
% % [p,table] = friedman(pairedData(strcmp(pairedData.treatmentTypeOfPost,'2mins After')),2)

function pairedImagingDataset = ExtractPairedImagingDataset(pairedImagingData)
possibleFieldsToRemove = {'plot','timeVec', 'coOrdinates','binningLabel','croppedPlot','tCroppedPlot','binnedArea','baselinePlot','baselinePlotPost','baselinePlotChange','croppedPlotPost','tCroppedPlotPost','binnedAreaPost','croppedPlotChange','tCroppedPlotChange','binnedAreaChange','outputPlotValues','outputPlotValuesPost','outputPlotValuesChange'};
fieldsToRemove = intersect(possibleFieldsToRemove,fieldnames(pairedImagingData));

someFieldsRemoved = rmfield(pairedImagingData,   fieldsToRemove);
pairedImagingDataset = struct2dataset(someFieldsRemoved');

function [] = PlotGscatter(myDataUnpaired)
%%
figure
dataPointGroups  =gscatter(grp2idx([myDataUnpaired.glomerulus]),myDataUnpaired.areaUnderCurve20Change,myDataUnpaired.genotype);
for dataPointGroupsElement = 1: length(dataPointGroups)
                set(dataPointGroups(dataPointGroupsElement),'MarkerSize',30)
end
 xlabel('baseline')
 ylabel('curve 20')
%  set(gca, 'xtick',[1:length(groupLabels)], 'xticklabel',groupLabels);


function changeAsPercentOfNaive = GetChangeAsPercentOfNaive(pairedImagingData, groupingVariables)
[indicesForFirstCyclingVariable, labelsForFirstCyclingVariable] = grp2idx([pairedImagingData.(groupingVariables{1})]);
[indicesForSecondCyclingVariable, labelsForSecondCyclingVariable] = grp2idx([pairedImagingData.(groupingVariables{2})]);


for ii = 1:length(labelsForFirstCyclingVariable)
    disp(['Cycling through ' groupingVariables{1} ' : ' labelsForFirstCyclingVariable{ii}])
for jj = 1:length(labelsForSecondCyclingVariable)
  if sum(indicesForFirstCyclingVariable==ii&indicesForSecondCyclingVariable==jj)
    disp(['Cycling through: ' groupingVariables{2} ' : ' labelsForSecondCyclingVariable{jj}])
%     [~,p(jj),ci(:,jj),tstats(:,jj)] = ttest(myPairedData(indicesForFirstCyclingVariable==jj& indicesForSecondCyclingVariable == jj,:).(valuesToExtractForNeuron{kk}));
meanChanges = mean(pairedImagingData(indicesForFirstCyclingVariable==ii& indicesForSecondCyclingVariable == jj,:).('areaUnderCurveChange'));
meanNaiveResponses = mean(pairedImagingData(indicesForFirstCyclingVariable==ii& indicesForSecondCyclingVariable == jj,:).('areaUnderCurve'));
changeAsPercentOfNaive{ii}{jj} = 100*meanChanges/meanNaiveResponses;
  end
end
end

