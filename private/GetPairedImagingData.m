function [ pairedImagingData] = GetPairedImagingData(userInput,fieldsStruct)
if ~length(unique([userInput.(fieldsStruct.fieldToCompare)]))==2
    pairedImagingData = [];
    return
end
pairedImagingData = userInput;
valuesToExtractForPairedImagingData = GetValuesToExtract;
%%
elementsToKeep = zeros(length(userInput),1);
elementsToKeepInPaired = zeros(length(userInput),1);


[higherCycleGroupIndices,higherCycleGroupLabels] = grp2idx([userInput.(fieldsStruct.fieldForCycling2)]);
for higherCycleGroupElement = 1:max(higherCycleGroupIndices)
    dataForThisHigherCycleElement = userInput(higherCycleGroupIndices ==higherCycleGroupElement);
    
    
    [lowerCycleGroupIndices,   lowerCycleLabels] = grp2idx([   dataForThisHigherCycleElement.(fieldsStruct.fieldForCycling)]);
    for lowerCycleElement = 1:max(lowerCycleGroupIndices)
        dataForThisLowerCycleElement =    dataForThisHigherCycleElement(lowerCycleGroupIndices== lowerCycleElement);
        
        
        [lobeLateralityGroupIndices,lateralityLabels] = grp2idx([dataForThisLowerCycleElement.glomSide]);
        for lateralElement = 1:max(lobeLateralityGroupIndices)
            lateralData = dataForThisLowerCycleElement(lobeLateralityGroupIndices == lateralElement);
            
            [flyGroupIndices,flyLabels] = grp2idx([lateralData.fly]);
            for flyElement = 1:max(flyGroupIndices)
                dataForThisFly = lateralData(flyGroupIndices== flyElement);
                
                
                if length(dataForThisFly) == 2
                    relevantIndices = ...
                        strcmp([userInput.(fieldsStruct.fieldForCycling2)] , higherCycleGroupLabels(higherCycleGroupElement))&...
                        strcmp([userInput.(fieldsStruct.fieldForCycling)] ,    lowerCycleLabels(lowerCycleElement)) &...
                        strcmp([userInput.glomSide] , lateralityLabels(lateralElement)) &...
                        strcmp([userInput.fly] , flyLabels(flyElement));
                    elementsToKeep(relevantIndices) = 1;
                    
                    [pairedImagingData, elementsToKeepInPaired] = AddElementToPairedImagingData(userInput,pairedImagingData,relevantIndices,valuesToExtractForPairedImagingData,elementsToKeepInPaired);
                    
                else
                                          %%
                    disp(['no pairs found for ' dataForThisFly(1).names{1} 'in file' dataForThisFly(1).fileName ])
                    %%
                    labelsAsIndividualCells = strcat({lateralData.glomerulus},{lateralData.glomSide},{lateralData.fly},{lateralData.run},{lateralData.subRun});
                    mergedLabel= cellfun(@strjoin,labelsAsIndividualCells,'UniformOutput',false);
                end
            end
            
            
        end
    end
    
    
end
% elementsToKeep = logical(elementsToKeep);
% userInput = userInput(elementsToKeep);

elementsToKeepInPaired = logical(elementsToKeepInPaired);
pairedImagingData = pairedImagingData(elementsToKeepInPaired);
