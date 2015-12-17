function [filesToDelete] = FilterSynapsinData(files)
% depreciated functionality. filtering for a specific dataset. 
	% input list of filenames. output logical array with ones for values to delete.

disp('Filtering out all runs but 1-2')
filesToDelete= cellfun(@isempty, regexp(files,'f\d\dr0[1-2][a-z]'));

filterOutliers = 0
if filterOutliers
    disp('filtering outliers')
try
    outliers = [];
outliers = readtable('outliers.txt');
outliers = outliers.Filename;
for outliersElement = 1:length(outliers)
    filesToDelete = filesToDelete | (strcmp(files,[outliers{outliersElement} '.mat']));
    filesToDelete = filesToDelete |(strcmp(files,[outliers{outliersElement}]));
end
catch
    if isempty('outliers.txt')
        h = msgbox('No outliers.txt file within folder to eliminate outliers'); % The first column of this csv is filenames to be eliminated
        pause(0.75)
        close(h)
    end
end
else
    disp('not filtering outliers')
end
