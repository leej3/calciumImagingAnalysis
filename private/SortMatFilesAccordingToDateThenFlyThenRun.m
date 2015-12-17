function matFiles = SortMatFilesAccordingToDateThenFlyThenRun(matFiles)
indicesOfFilesWithStimID = ~cellfun(@isempty , regexp(matFiles,'f\d\dr\d\d[a-z]'));
indicesOfFilesWithoutStimID = cellfun(@isempty , regexp(matFiles,'f\d\dr\d\d[a-z]'));

filesWithoutStimID = reshape(matFiles(indicesOfFilesWithoutStimID),sum(indicesOfFilesWithoutStimID),1);
filesWithStimID = reshape(matFiles(indicesOfFilesWithStimID),sum(indicesOfFilesWithStimID),1);
filesWithStimID =  sortFilesWithStimID(filesWithStimID);

matFiles = [filesWithStimID ; filesWithoutStimID];

function [filesWithStimID] =  sortFilesWithStimID(filesWithStimID)
arrayWithDates = regexp(filesWithStimID, '201[1-9]\d\d\d\d', 'match');
arrayWithDates = [arrayWithDates{:}]';
arrayWithFlies = regexp(filesWithStimID, 'f\d\d', 'match');
arrayWithFlies = [arrayWithFlies{:}]';
arrayWithRuns = regexp(filesWithStimID, 'r\d\d[a-z]','match');
arrayWithRuns = [arrayWithRuns{:}]';
dataInDatasetFormat = cell2dataset([{'filesWithStimIDs','arrayWithDates','arrayWithFlies','arrayWithRuns'};[filesWithStimID, arrayWithDates,arrayWithFlies,arrayWithRuns]]);
datasetSorted = sortrows(dataInDatasetFormat, {'arrayWithDates','arrayWithFlies','arrayWithRuns'});
dataBackAsCell = dataset2cell(datasetSorted);
filesWithStimID = (dataBackAsCell(2:end,1));

