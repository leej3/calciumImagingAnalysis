function [userInput,pairedImagingData] = MergeSubRuns(userInput)
pairedImagingData = userInput;

valuesToExtractForPairedImagingData = GetValuesToExtract;
userResponse = questdlg({'Merge sub runs?', '( by deleting b if a is present unless paired b is present with no paired a)'});
% onlyPairedDateChoice = questdlg('Keep only paired data?');
if strcmp(userResponse, 'Yes')
    %%
    elementsToKeep = zeros(length(userInput),1);
    elementsToKeepInPaired = zeros(length(userInput),1);
    [glomeruliGroupIndices,glomLabels] = grp2idx([userInput.glomerulus]);
    for glomeruliElement = 1:max(glomeruliGroupIndices)
        dataForThisGlom = userInput(glomeruliGroupIndices ==glomeruliElement);
        [flyGroupIndices,flyLabels] = grp2idx([dataForThisGlom.fly]);
        for flyElement = 1:max(flyGroupIndices)
            dataForThisFly = dataForThisGlom(flyGroupIndices== flyElement);
            [lobeLateralityGroupIndices,lateralityLabels] = grp2idx([dataForThisFly.glomSide]);
            for lateralElement = 1:max(lobeLateralityGroupIndices)
                lateralData = dataForThisFly(lobeLateralityGroupIndices == lateralElement);

                if sum(strcmp([lateralData.subRun],'a')) == 2
                       relevantIndices = ...
                            strcmp([userInput.glomerulus] , glomLabels(glomeruliElement))&...
                            strcmp([userInput.fly] , flyLabels(flyElement)) &...
                            strcmp([userInput.glomSide] , lateralityLabels(lateralElement)) &...
                            strcmp([userInput.subRun],'a');
                        elementsToKeep(relevantIndices) = 1;

                        [pairedImagingData, elementsToKeepInPaired] = AddElementToPairedImagingData(userInput,pairedImagingData,relevantIndices,valuesToExtractForPairedImagingData,elementsToKeepInPaired);

                elseif sum(strcmp([lateralData.subRun],'b')) == 2
                        relevantIndices = ...
                            strcmp([userInput.glomerulus] , glomLabels(glomeruliElement))&...
                            strcmp([userInput.fly] , flyLabels(flyElement)) &...
                            strcmp([userInput.glomSide] , lateralityLabels(lateralElement)) &...
                            strcmp([userInput.subRun],'b');
                        elementsToKeep(relevantIndices) = 1;

                      [pairedImagingData, elementsToKeepInPaired] = AddElementToPairedImagingData(userInput,pairedImagingData,relevantIndices,valuesToExtractForPairedImagingData,elementsToKeepInPaired);
%                         disp('b found')
%                         labelsAsIndividualCells = strcat({lateralData.glomerulus},{lateralData.glomSide},{lateralData.fly},{lateralData.run},{lateralData.subRun});
%                         mergedLabel= cellfun(@strjoin,labelsAsIndividualCells,'UniformOutput',false)
                           % [[pairedImagingData.genotype]' ,num2cell([pairedImagingData.meanBaselineValue]')]
                else
%                      keyboard
                        disp('no pairs found')
                        labelsAsIndividualCells = strcat({lateralData.glomerulus},{lateralData.glomSide},{lateralData.fly},{lateralData.run},{lateralData.subRun});
                        mergedLabel= cellfun(@strjoin,labelsAsIndividualCells,'UniformOutput',false)
                 end


                end
            end


        end
elementsToKeep = logical(elementsToKeep);
userInput = userInput(elementsToKeep);

elementsToKeepInPaired = logical(elementsToKeepInPaired);
pairedImagingData = pairedImagingData(elementsToKeepInPaired);
    end
