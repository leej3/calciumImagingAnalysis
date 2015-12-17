function [filenames] =                          FilterFiles(filenames)
filenames(~cellfun(@isempty , regexp(filenames,'MatFiles'))) = [];
[~,ind]  = intersect(filenames,{'groupsKey.mat','onsetChoices.mat','onsetChoice.mat','temporaryStackInfo.mat','analysisArgs.mat','filesForFurtherAnalysis.mat','fieldsStruct.mat'});
filenames(ind) = [];

try
filenames = SortMatFilesAccordingToDateThenFlyThenRun(filenames);
catch
    errordlg('Could not sort filenames, potentially due to a missing statistics toolbox.','Wee problem')
end

% Getting the screen size to display the list dialogue box
set(0,'Units','pixels');
scnsize = get(0,'ScreenSize');

userMatFileIndices= listdlg('ListString',filenames,'ListSize',[0.5*scnsize(3) 0.5*scnsize(4)],'PromptString','Choose the Mat Files to analyse');
filenames= reshape(filenames(userMatFileIndices), length(filenames(userMatFileIndices)), 1);

if isempty(filenames)
    error('no filenames selected')
end
