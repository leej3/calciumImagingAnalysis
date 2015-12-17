function [pairedImagingData,elementsToKeepInPaired] = AddElementToPairedImagingData(userInput,pairedImagingData,relevantIndices,valuesToExtractForPairedImagingData,elementsToKeepInPaired)
indexOfPre = find(relevantIndices,1,'First');
indexOfPost = find(relevantIndices,1,'Last');
for ii = 1 : length(valuesToExtractForPairedImagingData)
    pairedImagingData(indexOfPre).([ valuesToExtractForPairedImagingData{ii} 'Post']) = userInput(indexOfPost).(valuesToExtractForPairedImagingData{ii});
    pairedImagingData(indexOfPre).([valuesToExtractForPairedImagingData{ii} 'Change']) =   userInput(indexOfPost).(valuesToExtractForPairedImagingData{ii}) - userInput(indexOfPre).(valuesToExtractForPairedImagingData{ii}) ;
    pairedImagingData(indexOfPre).([valuesToExtractForPairedImagingData{ii} 'PercentChange']) =  100*pairedImagingData(indexOfPre).([valuesToExtractForPairedImagingData{ii} 'Change'])./ userInput(indexOfPre).(valuesToExtractForPairedImagingData{ii}) ;
end
elementsToKeepInPaired(indexOfPre) = 1;
