function [userInput] =   FilterUserInputAccordingToGlomConcPairingInConcentrationDataset(userInput)
%  depreciated functionality for handling different `batches' (see GetBatch). certain layers within the antennal lobe were imaged for any given batch. data from other layers was collected sometimes during the wrong batch depending on the orientation of the brain.
matFileNames = cellfun(@GetMatFileName , {userInput.fileName},'UniformOutput',false);
logicalOfRun1to8 = ~cellfun(@isempty , regexp(matFileNames,'f\d\dr0[1-8][a-z]'));
if sum(logicalOfRun1to8)>0
    disp('Filtering out all runs but 1-8')
    disp([{'Removing : '} ; matFileNames(~logicalOfRun1to8)'])
userInput= userInput(logicalOfRun1to8);
end

disp('Extracting round1-layer1 and round2-layer2')
h  = msgbox('Extracting round1-layer1 and round2-layer2');

layer1Batch1 = strcmp(vertcat(userInput.concentrationBatch),'01') & ...
(strcmp(vertcat(userInput.glomerulus),'DM6')...
    | strcmp(vertcat(userInput.glomerulus),'DM3'));

layer2Batch2 = strcmp(vertcat(userInput.concentrationBatch),'02') & ...
(strcmp(vertcat(userInput.glomerulus),'DM5')...
    | strcmp(vertcat(userInput.glomerulus),'DM2')...
    | strcmp(vertcat(userInput.glomerulus),'DM1'));
matFileNames = cellfun(@GetMatFileName , {userInput.fileName},'UniformOutput',false);
disp([{'Removing : '} ; strcat(matFileNames(~(layer1Batch1 | layer2Batch2))' ,deal('_') ,  vertcat(userInput(~(layer1Batch1 | layer2Batch2)).names))])
userInput = userInput(layer1Batch1 | layer2Batch2);

pause(0.5)
try
    close(h)
end
